# 1. Obtain GKE cluster endpoint and credentials
#----------------------------------------------
data "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
}

data "google_client_config" "current" {}

# 2. Configure the Kubernetes provider to talk to your GKE cluster
#----------------------------------------------------------------
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
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
