module "gcp_module_project" {
  source = "../../modules/gcp-module-project"

  source_file = "../../../config/landscape.yaml"
}
