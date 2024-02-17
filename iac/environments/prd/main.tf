variable "project_prefix" {
  type = string
}

locals {
  landscape = yamldecode(file("../../../config/landscape.yaml"))
}

module "projects" {
  source = "../../modules/gcp-module-project"

  project_prefix = var.project_prefix
  environment_dict = local.landscape["environments"]
}
