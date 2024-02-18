resource "google_project_iam_custom_role" "gcp_module_table_deployer_role" {
  for_each = local.environment_dict

  name = "${local.project_prefix}${each.key}"
  project_id = "${local.project_prefix}${each.key}"

  role_id     = "gcp_module_table_deployer_role"
  title       = "GCP Bigquery Table Deployer Role"
  description = "GCP Bigquery Table Deployer Role"
  permissions = [
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.get",
    "compute.networks.read",
    "storage.objects.list",
    "storage.objects.get"
  ]
}
