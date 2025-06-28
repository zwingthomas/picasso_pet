# Service account for Cloud Run services
data "google_project" "project" {}

resource "google_service_account" "cloudrun_runtime" {
  account_id   = "cloudrun-runtime"
  display_name = "Cloud Run Runtime Service Account"
}

resource "google_service_account_iam_member" "terraform_act_as_cloudrun" {
  service_account_id = google_service_account.cloudrun_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_sa_email}"
}

resource "google_project_iam_member" "cloudrun_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/cloudsql.client",
    "roles/storage.admin"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloudrun_runtime.email}"
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