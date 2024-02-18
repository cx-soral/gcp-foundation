module "applications" {
  source = "../../modules/gcp-module-project"

  source_file = "../../../config/landscape.yaml"
}
