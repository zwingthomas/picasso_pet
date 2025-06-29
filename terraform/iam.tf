data "google_project" "project" {}

// ---------------------------------------------
// Permissions for the Terraform CI Service Account
// ---------------------------------------------

// 1) Create a dedicated runtime SA for your Cloud Run services
resource "google_service_account" "cloudrun_runtime" {
  account_id   = "cloudrun-runtime"
  display_name = "Cloud Run Runtime Service Account"
}

// 2) Let terraform-ci@… actAs that runtime SA
resource "google_service_account_iam_member" "ci_act_as_runtime" {
  service_account_id = google_service_account.cloudrun_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_sa_email}"
  
  lifecycle {
    prevent_destroy = true
  }
}

// 3) Let terraform-ci@… mint tokens for that runtime SA
resource "google_service_account_iam_member" "ci_token_creator_runtime" {
  service_account_id = google_service_account.cloudrun_runtime.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.terraform_sa_email}"
  
  lifecycle {
    prevent_destroy = true
  }
}

// ---------------------------------------------
// Project-level roles for Terraform CI
// ---------------------------------------------
resource "google_project_iam_member" "ci_project_roles" {
  for_each = toset([
    "roles/run.admin",                         // create & manage Cloud Run services
    "roles/serviceusage.serviceUsageConsumer", // invoke enabled APIs
    "roles/cloudsql.client",                  // manage Cloud SQL connections
    "roles/storage.admin"                     // manage GCS for images & artifacts
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${var.terraform_sa_email}"

  lifecycle {
    prevent_destroy = true
  }
}

// ---------------------------------------------
// GKE Node Pool Service Account & Roles
// ---------------------------------------------
resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_service_account_iam_member" "nodepool_actas" {
  service_account_id = google_service_account.gke_node_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_sa_email}"

  lifecycle {
    prevent_destroy = true
  }
}