variable "project_id" {
  type = string
}

locals {
  yaml_content = yamldecode(file("${path.root}/../../config/landscape.yaml"))
}

module "project" {
  source = "../../modules/gcp-module-project"
  project_id = var.project_id
}
