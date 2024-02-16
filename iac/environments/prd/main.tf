variable "project_prefix" {
  type = string
}

locals {
  landscape = yamldecode(file("${path.root}/../../config/landscape.yaml"))
}

module "project" {
  source = "../../modules/gcp-module-project"

  for_each = local.landscape["environments"]

  project_id = "${path.root}${each.key}"
}
