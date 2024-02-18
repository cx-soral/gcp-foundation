locals {
  landscape = yamldecode(file(var.source_file))
  project_prefix = local.landscape["settings"]["project_prefix"]
  billing_account = local.landscape["settings"]["billing_account"]
  environment_dict = local.landscape["environments"]
}

resource "google_project" "env_projects" {
  for_each = local.environment_dict

  name = "${local.project_prefix}${each.key}"
  project_id = "${local.project_prefix}${each.key}"
  billing_account = local.billing_account
}