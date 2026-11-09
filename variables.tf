variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

variable "betterstack_ingesting_host" {
  type        = string
  description = "Ingesting host of your Better Stack source, without https://."

  validation {
    condition     = can(regex("^\\s*(https?://)?[A-Za-z0-9.-]+(:[0-9]+)?/?\\s*$", var.betterstack_ingesting_host))
    error_message = "Use the ingesting host shown on your source's Ingest tab, for example s1234.eu-nbg-2.betterstackdata.com."
  }
}

variable "betterstack_source_token" {
  type      = string
  sensitive = true
}

variable "metrics_compartment_ids" {
  type        = string
  default     = ""
  description = "Compartment OCIDs to forward metrics from, separated by commas or new lines. Leave empty for every compartment in the tenancy."
}

variable "metrics_namespaces" {
  type = list(string)
  default = [
    "oci_autonomous_database",
    "oci_blockstore",
    "oci_compute_infrastructure_health",
    "oci_computeagent",
    "oci_computecontainerinstance",
    "oci_database",
    "oci_database_cluster",
    "oci_dynamic_routing_gateway",
    "oci_faas",
    "oci_fastconnect",
    "oci_filestorage",
    "oci_gpu_infrastructure_health",
    "oci_lbaas",
    "oci_mysql_database",
    "oci_nat_gateway",
    "oci_nlb",
    "oci_objectstorage",
    "oci_oke",
    "oci_queue",
    "oci_rdma_infrastructure_health",
    "oci_service_gateway",
    "oci_vcn",
    "oci_vpn",
    "oci_waf",
    "oracle_oci_database",
  ]

  validation {
    condition     = length(var.metrics_namespaces) <= 50
    error_message = "A connector takes at most 50 metric namespaces."
  }
}

variable "forward_audit_logs" {
  type    = bool
  default = true
}

variable "log_group_ids" {
  type        = string
  default     = ""
  description = "Log group OCIDs to forward logs from, separated by commas or new lines."
}
