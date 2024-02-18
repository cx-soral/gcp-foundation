terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

locals {
  landscape = yamldecode(file(var.landscape_file))
  applications = yamldecode(file(var.applications_file))
  project_prefix = local.landscape["settings"]["project_prefix"]
  environment_dict = local.landscape["environments"]
}

resource "local_file" "applications" {
  for_each = local.environment_dict

  content  = "Project ${local.project_prefix}${each.key} created!"
  filename = "${local.project_prefix}${each.key}.txt"
}