module "gcp_module_application" {
  source = "../../modules/gcp-module-application"

  source_file = "../../../config/landscape.yaml"
}
