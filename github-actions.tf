terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.5.0"
    }
  } 
}

provider "google" {
  project     = var.project_id
  region      = "us-east1"
  zone        = "us-east1-c"
}

# Variables for dynamic values
variable "repo" {
  description = "The GitHub repository to bind to the Workload Identity Pool. Format: owner/repo"
}

variable "project_id" {
  description = "The project ID where resources will be created."
  type        = string
}

variable "service_account" {
  default     = "github-actions"
  description = "Github Actions Service Account"
}

variable "workload_identity_pool" {
  default     = "github-actions-pool"
  description = "Name of the workload identity pool."
}

variable "workload_identity_provider" {
  default     = "github"
  description = "Name of the workload identity provider."
}

# 1. Create Service Account and assign IAM roles
resource "google_service_account" "github_actions_sa" {
  account_id   = var.service_account
  display_name = "Github Actions Service Account"
}

resource "google_project_iam_member" "artifact_registry_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# 2. Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_actions_pool" {
  provider                  = google
  workload_identity_pool_id = var.workload_identity_pool
  display_name              = var.workload_identity_pool
}

# 3. Bind the Service Account to the Workload Identity Pool
resource "google_service_account_iam_binding" "workload_identity_user" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id}/attribute.repository/${var.repo}"
  ]
}

# 4. Create the OIDC Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_actions_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider
  display_name                       = "GitHub Provider"
  attribute_mapping = {
    "google.subject"        = "assertion.sub"
    "attribute.actor"       = "assertion.actor"
    "attribute.repository"  = "assertion.repository"
  }
  # attribute_condition = "assertion.repository == \"${var.repo}\""
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
