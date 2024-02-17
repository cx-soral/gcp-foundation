locals {
  landscape = yamldecode(file(var.source_file))
  project_prefix = local.landscape["settings"]["project_prefix"]
  environment_dict = local.landscape["environments"]
}

resource "local_file" "projects" {
  for_each = local.environment_dict

  content  = "Project ${local.project_prefix}${each.key} created!"
  filename = "${local.project_prefix}${each.key}.txt"
}