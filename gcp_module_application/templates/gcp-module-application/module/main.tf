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

resource "github_repository" "app-repository" {
  for_each = local.applications

  name        = each.value["repository_name"]
  description = 'Application: ${each.value["repository_name"]}'

  visibility = each.value["visibility"]

  template {
    owner                = "cx-soral"
    repository           = "gcp-framework"
  }
}
