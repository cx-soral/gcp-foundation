resource "local_file" "projects" {
  for_each = var.environment_dict

  content  = "Project ${var.project_prefix}${each.key} created!"
  filename = "${var.project_prefix}${each.key}.txt"
}