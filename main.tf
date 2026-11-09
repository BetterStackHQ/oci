terraform {
  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 9.0"
    }
  }
}

provider "oci" {
  region = var.region
}

locals {
  forwarder_version = "0.1.0"

  # Better Stack publishes the forwarder to a public repository in every region it supports.
  forwarder_image = coalesce(var.forwarder_image, "${lower(data.oci_identity_regions.current.regions[0].key)}.ocir.io/lr3km3hvmrwp/betterstack/oci-forwarder:${local.forwarder_version}")

  connector_principal = "where all {request.principal.type = 'serviceconnector', request.principal.compartment.id = '${oci_identity_compartment.betterstack.id}'}"

  # The form asks for the host without a scheme; a pasted URL still works.
  ingesting_host = trimsuffix(trimprefix(trimprefix(trimspace(var.betterstack_ingesting_host), "https://"), "http://"), "/")

  # OCID fields accept commas, spaces or one OCID per line.
  selected_compartment_ids = distinct(regexall("[^,\\s]+", var.metrics_compartment_ids))
  log_group_ids            = distinct(regexall("[^,\\s]+", var.log_group_ids))

  # Metrics are read tenancy-wide only when no compartments are chosen.
  metrics_statements = length(local.selected_compartment_ids) > 0 ? [
    for id in local.selected_compartment_ids : "Allow any-user to read metrics in compartment id ${id} ${local.connector_principal}"
  ] : ["Allow any-user to read metrics in tenancy ${local.connector_principal}"]
}

data "oci_identity_regions" "current" {
  filter {
    name   = "name"
    values = [var.region]
  }
}

data "oci_identity_region_subscriptions" "home" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

resource "oci_identity_compartment" "betterstack" {
  compartment_id = var.tenancy_ocid
  name           = "betterstack"
  description    = "Better Stack metric and log forwarding"
  enable_delete  = true

  lifecycle {
    precondition {
      condition     = var.region == data.oci_identity_region_subscriptions.home.region_subscriptions[0].region_name
      error_message = "Run the stack in your home region. It creates a compartment and policies, which OCI only accepts there."
    }
  }
}

resource "oci_identity_policy" "connectors" {
  compartment_id = var.tenancy_ocid
  name           = "betterstack-connectors"
  description    = "Lets the Better Stack connectors read metrics and logs and invoke the forwarder"
  statements = concat(local.metrics_statements, [
    "Allow any-user to read log-content in tenancy ${local.connector_principal}",
    "Allow any-user to use fn-function in compartment id ${oci_identity_compartment.betterstack.id} ${local.connector_principal}",
    "Allow any-user to use fn-invocation in compartment id ${oci_identity_compartment.betterstack.id} ${local.connector_principal}",
  ])
}

# The Function has no public IP, so it reaches Better Stack through a NAT gateway.
resource "oci_core_vcn" "betterstack" {
  compartment_id = oci_identity_compartment.betterstack.id
  display_name   = "betterstack"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "betterstack"
}

resource "oci_core_nat_gateway" "betterstack" {
  compartment_id = oci_identity_compartment.betterstack.id
  vcn_id         = oci_core_vcn.betterstack.id
  display_name   = "betterstack"
}

resource "oci_core_route_table" "forwarder" {
  compartment_id = oci_identity_compartment.betterstack.id
  vcn_id         = oci_core_vcn.betterstack.id
  display_name   = "forwarder"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.betterstack.id
  }
}

resource "oci_core_security_list" "forwarder" {
  compartment_id = oci_identity_compartment.betterstack.id
  vcn_id         = oci_core_vcn.betterstack.id
  display_name   = "forwarder"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # DNS goes to the VCN resolver only.
  egress_security_rules {
    destination = "169.254.169.254/32"
    protocol    = "17"

    udp_options {
      min = 53
      max = 53
    }
  }
}

resource "oci_core_subnet" "forwarder" {
  compartment_id             = oci_identity_compartment.betterstack.id
  vcn_id                     = oci_core_vcn.betterstack.id
  display_name               = "forwarder"
  cidr_block                 = "10.0.0.0/24"
  dns_label                  = "forwarder"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.forwarder.id
  security_list_ids          = [oci_core_security_list.forwarder.id]
}

resource "oci_functions_application" "betterstack" {
  compartment_id = oci_identity_compartment.betterstack.id
  display_name   = "betterstack"
  subnet_ids     = [oci_core_subnet.forwarder.id]
  shape          = "GENERIC_X86_ARM"
}

resource "oci_functions_function" "forwarder" {
  application_id     = oci_functions_application.betterstack.id
  display_name       = "forwarder"
  image              = local.forwarder_image
  memory_in_mbs      = 256
  timeout_in_seconds = 300

  config = {
    BETTERSTACK_INGESTING_HOST = local.ingesting_host
    BETTERSTACK_SOURCE_TOKEN   = var.betterstack_source_token
  }
}

# A monitoring source only covers its own compartment, not its children, so
# every compartment with metrics in a selected namespace becomes a source.
data "oci_identity_compartments" "all" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  access_level              = "ANY"
  state                     = "ACTIVE"
}

locals {
  metrics_compartment_ids = length(local.selected_compartment_ids) > 0 ? local.selected_compartment_ids : concat(
    [var.tenancy_ocid],
    [for compartment in data.oci_identity_compartments.all.compartments : compartment.id if compartment.name != "betterstack"],
  )
}

data "oci_monitoring_metrics" "namespaces" {
  for_each = toset(local.metrics_compartment_ids)

  compartment_id = each.value
  group_by       = ["namespace"]
}

locals {
  metric_sources = [
    for id in local.metrics_compartment_ids : {
      compartment_id = id
      namespaces     = sort(setintersection(var.metrics_namespaces, data.oci_monitoring_metrics.namespaces[id].metrics[*].namespace))
    } if length(setintersection(var.metrics_namespaces, data.oci_monitoring_metrics.namespaces[id].metrics[*].namespace)) > 0
  ]

  # A connector takes at most 5 compartments and 50 namespaces across them, so
  # compartments are packed with others that select as many namespaces: one
  # compartment with many namespaces doesn't shrink every other connector.
  metric_source_sizes = sort(distinct([for source in local.metric_sources : format("%02d", length(source.namespaces))]))
  metric_connectors = concat([], [
    for size in local.metric_source_sizes : chunklist(
      [for source in local.metric_sources : source if length(source.namespaces) == tonumber(size)],
      min(5, floor(50 / tonumber(size))),
    )
  ]...)
}

resource "oci_sch_service_connector" "metrics" {
  count = length(local.metric_connectors)

  compartment_id = oci_identity_compartment.betterstack.id
  display_name   = "betterstack-metrics-${count.index}"

  source {
    kind = "monitoring"

    dynamic "monitoring_sources" {
      for_each = local.metric_connectors[count.index]

      content {
        compartment_id = monitoring_sources.value.compartment_id

        namespace_details {
          kind = "selected"

          dynamic "namespaces" {
            for_each = monitoring_sources.value.namespaces

            content {
              namespace = namespaces.value

              metrics {
                kind = "all"
              }
            }
          }
        }
      }
    }
  }

  target {
    kind              = "functions"
    function_id       = oci_functions_function.forwarder.id
    batch_size_in_kbs = 5000
    batch_time_in_sec = 60
  }

  depends_on = [oci_identity_policy.connectors]
}

data "oci_logging_log_group" "selected" {
  for_each = toset(local.log_group_ids)

  log_group_id = each.value
}

resource "oci_sch_service_connector" "logs" {
  count = var.forward_audit_logs || length(local.log_group_ids) > 0 ? 1 : 0

  compartment_id = oci_identity_compartment.betterstack.id
  display_name   = "betterstack-logs"

  source {
    kind = "logging"

    dynamic "log_sources" {
      for_each = var.forward_audit_logs ? [var.tenancy_ocid] : []

      content {
        compartment_id = log_sources.value
        log_group_id   = "_Audit_Include_Subcompartment"
      }
    }

    dynamic "log_sources" {
      for_each = data.oci_logging_log_group.selected

      content {
        compartment_id = log_sources.value.compartment_id
        log_group_id   = log_sources.key
      }
    }
  }

  target {
    kind              = "functions"
    function_id       = oci_functions_function.forwarder.id
    batch_size_in_kbs = 5000
    batch_time_in_sec = 60
  }

  depends_on = [oci_identity_policy.connectors]
}
