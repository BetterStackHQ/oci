mock_provider "oci" {
  override_data {
    target = data.oci_identity_region_subscriptions.home
    values = { region_subscriptions = [{ region_name = "uk-london-1" }] }
  }

  override_data {
    target = data.oci_functions_functions_runtimes.python
    values = { functions_runtime_collection = [{ items = [{ id = "runtime" }] }] }
  }

  override_data {
    target = data.oci_functions_functions_runtime_versions.python
    values = { functions_runtime_version_collection = [{ items = [{ id = "version" }] }] }
  }

  override_data {
    target = data.oci_limits_limit_values.connectors
    values = { limit_values = [{ value = 100 }] }
  }
}

variables {
  tenancy_ocid               = "ocid1.tenancy.oc1..root"
  region                     = "uk-london-1"
  betterstack_ingesting_host = "s1.eu-nbg-2.betterstackdata.com"
  betterstack_source_token   = "token"
}

run "compartments_1_namespaces_25" {
  command = plan

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 1
    error_message = "Expected 1 metrics connectors."
  }
}

run "compartments_2_namespaces_25" {
  command = plan

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 1
    error_message = "Expected 1 metrics connectors."
  }
}

run "compartments_3_namespaces_25" {
  command = plan

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 2
    error_message = "Expected 2 metrics connectors."
  }
}

run "compartments_10_namespaces_25" {
  command = plan

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }, { id = "ocid1.compartment.oc1..c3", name = "c3" }, { id = "ocid1.compartment.oc1..c4", name = "c4" }, { id = "ocid1.compartment.oc1..c5", name = "c5" }, { id = "ocid1.compartment.oc1..c6", name = "c6" }, { id = "ocid1.compartment.oc1..c7", name = "c7" }, { id = "ocid1.compartment.oc1..c8", name = "c8" }, { id = "ocid1.compartment.oc1..c9", name = "c9" }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 5
    error_message = "Expected 5 metrics connectors."
  }
}

run "compartments_1_namespaces_10" {
  command = plan

  variables {
    metrics_namespaces = ["oci_blockstore", "oci_computeagent", "oci_faas", "oci_lbaas", "oci_nat_gateway", "oci_nlb", "oci_objectstorage", "oci_oke", "oci_vcn", "oracle_oci_database"]
  }

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 1
    error_message = "Expected 1 metrics connectors."
  }
}

run "compartments_2_namespaces_10" {
  command = plan

  variables {
    metrics_namespaces = ["oci_blockstore", "oci_computeagent", "oci_faas", "oci_lbaas", "oci_nat_gateway", "oci_nlb", "oci_objectstorage", "oci_oke", "oci_vcn", "oracle_oci_database"]
  }

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 1
    error_message = "Expected 1 metrics connectors."
  }
}

run "compartments_3_namespaces_10" {
  command = plan

  variables {
    metrics_namespaces = ["oci_blockstore", "oci_computeagent", "oci_faas", "oci_lbaas", "oci_nat_gateway", "oci_nlb", "oci_objectstorage", "oci_oke", "oci_vcn", "oracle_oci_database"]
  }

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 1
    error_message = "Expected 1 metrics connectors."
  }
}

run "compartments_10_namespaces_10" {
  command = plan

  variables {
    metrics_namespaces = ["oci_blockstore", "oci_computeagent", "oci_faas", "oci_lbaas", "oci_nat_gateway", "oci_nlb", "oci_objectstorage", "oci_oke", "oci_vcn", "oracle_oci_database"]
  }

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }, { id = "ocid1.compartment.oc1..c3", name = "c3" }, { id = "ocid1.compartment.oc1..c4", name = "c4" }, { id = "ocid1.compartment.oc1..c5", name = "c5" }, { id = "ocid1.compartment.oc1..c6", name = "c6" }, { id = "ocid1.compartment.oc1..c7", name = "c7" }, { id = "ocid1.compartment.oc1..c8", name = "c8" }, { id = "ocid1.compartment.oc1..c9", name = "c9" }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 2
    error_message = "Expected 2 metrics connectors."
  }
}

run "logs_only" {
  command = plan

  variables {
    metrics_namespaces = []
  }

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 0 && length(oci_sch_service_connector.logs) == 1
    error_message = "Expected the logs connector only."
  }
}

run "over_the_connector_limit" {
  command = plan

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }, { id = "ocid1.compartment.oc1..c3", name = "c3" }] }
  }

  override_data {
    target = data.oci_limits_limit_values.connectors
    values = { limit_values = [{ value = 2 }] }
  }

  expect_failures = [oci_identity_policy.connectors]
}

# Root + 1 subcompartment: 1 metrics connector + logs = 2, exactly the free tier's limit.
run "at_the_connector_limit" {
  command = plan

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }] }
  }

  override_data {
    target = data.oci_limits_limit_values.connectors
    values = { limit_values = [{ value = 2 }] }
  }
}

# Root + 3 subcompartments without logs: 2 metrics connectors, no logs connector.
run "at_the_connector_limit_without_logs" {
  command = plan

  variables {
    forward_audit_logs = false
  }

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }, { id = "ocid1.compartment.oc1..c3", name = "c3" }] }
  }

  override_data {
    target = data.oci_limits_limit_values.connectors
    values = { limit_values = [{ value = 2 }] }
  }

  assert {
    condition     = length(oci_sch_service_connector.metrics) == 2 && length(oci_sch_service_connector.logs) == 0
    error_message = "Expected 2 metrics connectors and no logs connector."
  }
}

run "no_connector_limit_returned" {
  command = plan

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }, { id = "ocid1.compartment.oc1..c3", name = "c3" }] }
  }

  override_data {
    target = data.oci_limits_limit_values.connectors
    values = { limit_values = [] }
  }
}

# Root + 3 subcompartments with a log group but no audit logs: 2 metrics connectors + logs = 3.
run "over_the_connector_limit_with_log_groups_only" {
  command = plan

  variables {
    forward_audit_logs = false
    log_group_ids      = "ocid1.loggroup.oc1..g1"
  }

  override_data {
    target = data.oci_identity_compartments.all
    values = { compartments = [{ id = "ocid1.compartment.oc1..c1", name = "c1" }, { id = "ocid1.compartment.oc1..c2", name = "c2" }, { id = "ocid1.compartment.oc1..c3", name = "c3" }] }
  }

  override_data {
    target = data.oci_logging_log_group.selected
    values = { compartment_id = "ocid1.compartment.oc1..c1" }
  }

  override_data {
    target = data.oci_limits_limit_values.connectors
    values = { limit_values = [{ value = 2 }] }
  }

  expect_failures = [oci_identity_policy.connectors]
}
