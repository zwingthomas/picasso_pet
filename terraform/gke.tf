
# 1. Stand up main GKE cluster
#----------------------------------------------
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  initial_node_count = var.cluster_node_count

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# 2. Configure the Kubernetes provider to talk to your GKE cluster
#----------------------------------------------------------------
data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )
}

# 3. Deploy the Celery worker as a Kubernetes Deployment
#------------------------------------------------------
variable "worker_replicas" {
  description = "Number of worker replicas"
  type        = number
  default     = 1
}

resource "kubernetes_deployment" "worker" {

  depends_on = [ google_container_cluster.primary ]

  metadata {
    name      = "worker"
    namespace = "default"
    labels = {
      app = "worker"
    }
  }

  spec {
    replicas = var.worker_replicas
    selector {
      match_labels = {
        app = "worker"
      }
    }

    template {
      metadata {
        labels = {
          app = "worker"
        }
      }

      spec {
        container {
          name  = "worker"
          image = "gcr.io/${var.project_id}/worker:latest"
          resources {
            # optional resource requests/limits
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
          env {
            name  = "DATABASE_URL"
            value = var.database_url
          }
          env {
            name  = "GCS_BUCKET_NAME"
            value = var.gcs_bucket_name
          }
          # add any other required env vars here
        }
        # add service account reference if needed
        service_account_name = "${google_service_account.gke_node_sa.email}"
      }
    }
  }
}
