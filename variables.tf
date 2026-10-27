variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

variable "betterstack_ingesting_host" {
  type        = string
  description = "Ingesting host of your Better Stack source, without https://."
}

variable "betterstack_source_token" {
  type      = string
  sensitive = true
}

variable "metrics_compartment_ids" {
  type        = string
  default     = ""
  description = "Comma-separated compartment OCIDs to forward metrics from. Leave empty for every compartment in the tenancy."
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
}

variable "forward_audit_logs" {
  type    = bool
  default = true
}

variable "log_group_ids" {
  type        = string
  default     = ""
  description = "Comma-separated log group OCIDs to forward logs from."
}

variable "forwarder_image" {
  type        = string
  default     = ""
  description = "Overrides the forwarder image Better Stack publishes in your region."
}
