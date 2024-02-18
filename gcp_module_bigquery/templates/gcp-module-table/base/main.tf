module "gcp_module_application" {
  source = "../../modules/gcp-module-bigquery"

  landscape_file = "../../../config/landscape.yaml"
  applications_file = "../../../config/applications.yaml"

  depends_on = [module.gcp_module_project]
}
