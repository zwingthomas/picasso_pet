resource "google_redis_instance" "redis" {
  name                   = "${var.network_name}-redis"
  tier                   = "STANDARD_HA"
  memory_size_gb         = var.redis_memory_size_gb
  region                 = var.region
  alternative_location_id = var.region_secondary
  authorized_network     = google_compute_network.vpc.id
}