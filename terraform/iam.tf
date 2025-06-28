# Service account for Cloud Run services
data "google_project" "project" {}

# Bind 'Service Account User' on the terraform-ci SA to itself
resource "google_service_account_iam_member" "ci_act_as_self" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.terraform_sa_email}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_sa_email}"
}

# Bind 'Token Creator' on the terraform-ci SA to itself
resource "google_service_account_iam_member" "ci_token_creator" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.terraform_sa_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.terraform_sa_email}"
}

resource "google_project_iam_member" "cloudrun_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/cloudsql.client",
    "roles/storage.admin"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${var.terraform_sa_email}"
}

# Service account for GKE node pool
data "google_compute_network" "vpc" {
  name = var.network_name
}

resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/container.nodeServiceAccount"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}