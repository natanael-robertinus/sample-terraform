terraform {
  backend "gcs" {
    bucket = "terraform-gcp-repo-1"
    prefix = "gcs/service-a-prd"
  }
}
