output "gcs_bucket_name" {
  description = "Name of the image bucket"
  value       = google_storage_bucket.images.name
}

output "cloudsql_instance_connection_name" {
  description = "Connection name for Cloud SQL instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = data.google_container_cluster.primary.endpoint
}

output "fastapi_service_url" {
  description = "URL for FastAPI Cloud Run service"
  value       = google_cloud_run_service.fastapi.status[0].url
}

output "flask_service_url" {
  description = "URL for Flask Cloud Run service"
  value       = google_cloud_run_service.flask.status[0].url
}

output "redis_host" {
  description = "Redis host IP"
  value       = google_redis_instance.redis.host
}