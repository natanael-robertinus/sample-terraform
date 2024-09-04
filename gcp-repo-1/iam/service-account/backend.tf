terraform {
  backend "gcs" {
    bucket = "terraform-gcp-repo-1"
    prefix = "iam/service-account"
  }
}
