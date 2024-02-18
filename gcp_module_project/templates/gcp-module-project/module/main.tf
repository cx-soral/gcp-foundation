locals {
  landscape = yamldecode(file(var.source_file))
  project_prefix = local.landscape["settings"]["project_prefix"]
  environment_dict = local.landscape["environments"]
}

data "google_billing_account" "available_accounts" {
  open         = true
}

resource "google_project" "env_projects" {
  for_each = local.environment_dict

  name = "${local.project_prefix}${each.key}"
  project_id = "${local.project_prefix}${each.key}"
  billing_account = local.landscape["settings"]["billing_account"]
}