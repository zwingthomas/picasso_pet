# FastAPI Cloud Run service
data "google_sql_database_instance" "postgres" {
  name = google_sql_database_instance.postgres.name
}

resource "google_cloud_run_service" "fastapi" {
  name     = "fastapi-app"
  location = var.region

  depends_on = [
    google_service_account_iam_member.ci_act_as_runtime,
    google_service_account_iam_member.ci_token_creator_runtime,
    google_project_iam_member.ci_project_roles,
  ]

  template {
    spec {
      service_account_name = google_service_account.cloudrun_runtime.email
      containers {
        image = "gcr.io/${var.project_id}/fastapi-app:latest"

        env {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_user}:${var.db_password}@${google_sql_database_instance.postgres.ip_address[0].ip_address}:5432/${var.db_name}"
        }
        env {
          name  = "STRIPE_API_KEY"
          value = var.stripe_api_key
        }
        env {
          name  = "STRIPE_WEBHOOK_SECRET"
          value = var.stripe_webhook_secret
        }
        env {
          name  = "SENDGRID_API_KEY"
          value = var.sendgrid_api_key
        }
        env {
          name  = "PRINTFUL_API_KEY"
          value = var.printful_api_key
        }
        env {
          name  = "GCS_BUCKET_NAME"
          value = var.gcs_bucket_name
        }
        env {
          name  = "CELERY_BROKER_URL"
          value = "redis://${google_redis_instance.redis.host}:6379"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "fastapi_invoker" {
  location = google_cloud_run_service.fastapi.location
  project  = var.project_id
  service  = google_cloud_run_service.fastapi.name

  role   = "roles/run.invoker"
  member = "allUsers"
}

# Flask Cloud Run service
data "google_cloud_run_service" "fastapi_ref" {
  name     = google_cloud_run_service.fastapi.name
  location = var.region
}

resource "google_cloud_run_service" "flask" {
  name     = "flask-app"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/flask-app:latest"
        env { 
            name = "API_URL"
            value = google_cloud_run_service.fastapi.status[0].url 
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "flask_invoker" {
  location = google_cloud_run_service.flask.location
  project  = var.project_id
  service  = google_cloud_run_service.flask.name

  role   = "roles/run.invoker"
  member = "allUsers"
}

resource "null_resource" "whoami" {
  provisioner "local-exec" {
    command = "gcloud auth list --filter=status:ACTIVE --format='value(account)'"
  }
}