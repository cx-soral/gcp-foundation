resource "google_project_iam_custom_role" "gcp_module_table_deployer_role" {
  role_id     = "myCustomRole"
  title       = "My Custom Role"
  description = "A custom role that combines specific permissions."
  permissions = [
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.get",
    "compute.networks.read",
    "storage.objects.list",
    "storage.objects.get"
  ]
}
