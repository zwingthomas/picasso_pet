# Enable required APIs

resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "storage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])
  service = each.key
  disable_on_destroy = false
}