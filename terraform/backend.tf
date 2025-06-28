terraform {
  backend "gcs" {
    bucket = "petscream-tfstate"
    prefix = "terraform/state"
  }
}