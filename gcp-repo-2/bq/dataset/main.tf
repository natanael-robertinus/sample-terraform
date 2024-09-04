 module "bq-dataset" {
   source = "git::ssh:///gcloud-bq-dataset.git?ref=v3.2.0"

   providers = {
    "google" = "google"
  }

  description    = "BigQuery dataset for gcp-repo-1 project"
  location       = "asia-southeast1"
  country        = "id"
  environment    = "production"
  is_temporary   = false
  managed        = true
  resource_state = "active"

  enable_gke_dataset = true
 }
