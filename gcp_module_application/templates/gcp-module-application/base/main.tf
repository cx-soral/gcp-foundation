module "applications" {
  source = "../../modules/gcp-module-application"

  source_file = "../../../config/landscape.yaml"
}
