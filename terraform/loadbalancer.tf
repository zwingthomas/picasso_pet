# Example: Domain mapping for Cloud Run services
resource "google_cloud_run_domain_mapping" "fastapi_domain" {
  name     = "api.your-domain.com"
  location = var.region
  project  = var.project_id

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_service.fastapi.name
  }
}

resource "google_cloud_run_domain_mapping" "flask_domain" {
  name     = "www.your-domain.com"
  location = var.region
  project  = var.project_id

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_service.flask.name
  }
}