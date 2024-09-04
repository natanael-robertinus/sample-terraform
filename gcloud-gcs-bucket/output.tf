output "bucket_name" {
  value = google_storage_bucket.gcs_bucket.name
}

output "bucket_location" {
  value = google_storage_bucket.gcs_bucket.location
}

output "service_account_name" {
  value = var.create_default_gcs_service_account ? google_service_account.gcs_service_account.0.name : "Default service account not created"
}

output "service_account_email" {
  value = var.create_default_gcs_service_account ? google_service_account.gcs_service_account.0.email : "Default service account not created"
}
