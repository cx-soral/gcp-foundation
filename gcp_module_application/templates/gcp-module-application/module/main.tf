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

locals {
  all_pool_settings = toset(flatten([
    for app_name, app in local.applications : [
      for env_name, env in local.environment_dict : {
        repository_owner  = app["repository_owner"]
        repository_name   = app["repository_name"]
        project_id        = "${local.project_prefix}${env_name}"
        match_branch      = env["match_branch"]
      }
    ]
  ]))
}

resource "github_repository" "app-repository" {
  for_each = local.applications

  name        = each.value["repository_name"]
  description = "Application: ${each.value["repository_name"]}"

  visibility = each.value["visibility"]

  template {
    owner                = "cx-soral"
    repository           = "gcp-framework"
  }
}

resource "google_iam_workload_identity_pool" "github_pool" {
  for_each = { for s in local.all_pool_settings : "${s.repository_owner}-${s.repository_name}-${s.project_id}" => s }

  workload_identity_pool_id = "github-pool-${each.value["repository_name"]}"
  project  = each.value["project_id"]

  # Workload Identity Pool configuration
  display_name = "github-pool-${each.value["repository_name"]}"
  description  = "Pool for GitHub Actions of ${each.value["repository_name"]}"

  # Make sure the pool is in a state to be used
  disabled = false
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  for_each = { for s in local.all_pool_settings : "${s.repository_owner}-${s.repository_name}-${s.project_id}" => s }

  workload_identity_pool_id = google_iam_workload_identity_pool.github_pool[each.key].workload_identity_pool_id
  workload_identity_pool_provider_id     = "github-provider-${each.value["repository_name"]}"
  project  = each.value["project_id"]

  # Provider configuration specific to GitHub
  display_name = "github-provider-${each.value["repository_name"]}"
  description  = "Provider for GitHub Actions of ${each.value["repository_name"]}"

   # Attribute mapping / condition from the OIDC token to Google Cloud attributes
  attribute_condition = "assertion.repository == '${each.value["repository_owner"]}/${each.value["repository_name"]}' && assertion.ref.matches('${each.value["match_branch"]}')"

  attribute_mapping = {
    "google.subject" = "assertion.sub",
    "attribute.actor" = "assertion.actor",
    "attribute.repository" = "assertion.repository",
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref" = "assertion.ref"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}