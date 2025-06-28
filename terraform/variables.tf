variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
}

variable "region_secondary" {
  description = "Secondary GCP region (for HA resources)"
  type        = string
}

variable "credentials_file" {
  description = "Path to GCP SA JSON key"
  type        = string
  sensitive   = true
}

variable "terraform_sa_email" {
  description = "Email of the CI/terraform service account"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Name of Cloud Storage bucket for images"
  type        = string
}

variable "db_name" {
  description = "Cloud SQL database name"
  type        = string
}

variable "db_user" {
  description = "Cloud SQL database user"
  type        = string
}

variable "db_password" {
  description = "Password for Cloud SQL user"
  type        = string
  sensitive   = true
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "VPC Subnetwork name"
  type        = string
}

variable "redis_memory_size_gb" {
  description = "Memory size for Memorystore Redis (GB)"
  type        = number
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "cluster_node_count" {
  description = "Initial node count for GKE cluster"
  type        = number
}

variable "stripe_api_key" {
  description = "API key for Stripe"
  type        = string
}

variable "stripe_webhook_secret" {
  description = "Webhook secret for Stripe"
  type        = string
}

variable "sendgrid_api_key" {
  description = "API key for SendGrid"
  type        = string
}

variable "printful_api_key" {
  description = "API key for printful"
  type        = string
}