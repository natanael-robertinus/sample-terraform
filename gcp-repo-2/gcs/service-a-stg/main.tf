module "gcs_gopay_em_id_prod_db_backup" {
  source = "git::ssh://gcloud-gcs-bucket.git?ref=v0.3.1"

  gcs_bucket_name = "service-a-bucket"
  gcs_service_account_key_admins = []
  gcs_service_account_additional_roles = []
}
