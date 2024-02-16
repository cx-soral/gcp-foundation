variable "project_prefix" {
  type = string
}

locals {
  landscape = yamldecode(file("${path.root}/../../config/landscape.yaml"))
}

module "projects" {
  source = "../../modules/gcp-module-project"

  for_each = local.landscape["environments"]

  project_id = "${path.root}${each.key}"
}
