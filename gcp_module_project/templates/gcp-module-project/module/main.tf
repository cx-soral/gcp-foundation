resource "local_file" "hello" {
  content  = "Project ${var.project_id} created"
  filename = "${path.module}/${var.project_id}.txt"
}