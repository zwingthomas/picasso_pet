variable "redis_primary_zone" {
  description = "The primary zone for Redis (must be in var.region)"
  type        = string
  default     = "us-central1-c"
}

variable "redis_secondary_zone" {
  description = "The HA standby zone (must also be in var.region)"
  type        = string
  default     = "us-central1-b"
}

resource "google_redis_instance" "redis" {
  name                   = "${var.network_name}-redis"
  tier                   = "STANDARD_HA"
  memory_size_gb         = var.redis_memory_size_gb
  region                 = var.region
  alternative_location_id = var.region_secondary
  authorized_network     = google_compute_network.vpc.self_link
}