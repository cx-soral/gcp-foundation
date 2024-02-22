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
  for_each = local.environment_dict

  project = "${local.project_prefix}${each.key}"
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "pypi_official" {
  for_each = local.environment_dict

  project       = "${local.project_prefix}${each.key}"
  location      = local.landscape["settings"]["project_region"]
  repository_id = "pypi-official"
  format        = "PYTHON"
  mode          = "REMOTE_REPOSITORY"
  description   = "PyPI repository proxy"
  remote_repository_config {
    description = "Official Pypi Repository"
    python_repository {
      public_repository = "PYPI"
    }
  }

  depends_on = [google_project_service.artifact_registry_api]
}

resource "google_artifact_registry_repository" "pypi_custom" {
  for_each = local.environment_dict

  project       = "${local.project_prefix}${each.key}"
  location      = local.landscape["settings"]["project_region"]
  repository_id = "pypi-custom"
  format        = "PYTHON"
  description   = "Custom PyPI repository"

  depends_on = [google_project_service.artifact_registry_api]
}

resource "google_artifact_registry_repository" "pypi" {
  for_each = local.environment_dict

  location      = local.landscape["settings"]["project_region"]
  repository_id = "pypi"
  description   = "PyPI repository"
  format        = "PYTHON"
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id          = "pypi-official"
      repository  = google_artifact_registry_repository.pypi_official[each.key].id
      priority    = 20
    }
    upstream_policies {
      id          = "custom"
      repository  = google_artifact_registry_repository.pypi_custom[each.key].id
      priority    = 10
    }
  }
}