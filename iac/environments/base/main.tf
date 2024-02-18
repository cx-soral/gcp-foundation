locals {
  landscape = yamldecode(file(var.landscape_file))
  applications = yamldecode(file(var.applications_file))
  modules = yamldecode(file(var.modules_file))
  environment_dict = local.landscape["environments"]
  modules_dict = local.landscape["modules"]
}