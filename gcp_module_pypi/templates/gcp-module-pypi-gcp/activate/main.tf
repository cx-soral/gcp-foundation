locals {
  landscape = yamldecode(file(var.landscape_file))
  applications = yamldecode(file(var.applications_file))
  project_prefix = local.landscape["settings"]["project_prefix"]
  environment_dict = local.landscape["environments"]
  application_list = local.landscape["modules"]["gcp_module_table"]["applications"]
}

locals {
  all_role_attribution = toset(flatten([
    for env_name, env in local.environment_dict : [
      for app_name in local.application_list : {
        app_name          = app_name
        env_name          = env_name
        project_id        = "${local.project_prefix}${env_name}"
      }
    ]
  ]))
}

resource "google_project_service" "artifact_registry_api" {
  service = "artifactregistry.googleapis.com"
  project = local.landscape["settings"]["realm_project"]
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "pypi_remote" {
  project       = local.landscape["settings"]["realm_project"]
  location      = local.landscape["settings"]["project_region"]
  repository_id = pypi-remote
  format        = "PYTHON"
  description   = "PyPI repository of foundation ${local.landscape["settings"]["foundation_name"]}"
  remote_repository_config {
    description = "Official Pypi Repository"
    python_repository = "PYPI"
  }

  depends_on = [google_project_service.artifact_registry_api]
}

resource "google_artifact_registry_repository" "pypi_local" {
  project       = local.landscape["settings"]["realm_project"]
  location      = local.landscape["settings"]["project_region"]
  repository_id = local.landscape["settings"]["foundation_name"]
  format        = "PYTHON"
  description   = "PyPI repository of foundation ${local.landscape["settings"]["foundation_name"]}"

  depends_on = [google_project_service.artifact_registry_api]
}
