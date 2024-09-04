resource "google_storage_bucket" "gcs_bucket" {
  name                        = var.gcs_bucket_name
  location                    = var.gcs_bucket_location
  storage_class               = var.gcs_bucket_storage_class
  uniform_bucket_level_access = var.enable_uniform_bucket_level_access
  force_destroy               = var.enable_force_destroy

  labels = merge({
    app_name    = var.app_name
    pod         = var.pod
    stream      = var.stream
    environment = var.environment
  }, var.gcs_additional_labels)

  versioning {
    enabled = var.gcs_bucket_versioning_enabled
  }

  dynamic "cors" {
    for_each = var.gcs_cors_options
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }

  # Specific for delete action to avoid nested dynamic block
  dynamic "lifecycle_rule" {
    for_each = var.gcs_lifecycle_rule_delete_action_age_condition_options
    content {
      condition {
        age = lifecycle_rule.value.age
      }
      action {
        type = "Delete"
      }
    }
  }

  dynamic "soft_delete_policy" {
    for_each = var.gcs_soft_delete_policy_options
    content {
      retention_duration_seconds = soft_delete_policy.value.retention_duration_seconds
    }
  }

  lifecycle {
    ignore_changes = [
      # Labels are handled by resource tagging service
      labels,
    ]
  }
}

# Default Service Accounts
resource "google_service_account" "gcs_service_account" {
  count        = var.create_default_gcs_service_account ? 1 : 0
  account_id   = "${var.gcs_bucket_name}-gcs"
  display_name = "${var.gcs_bucket_name} gcs bucket service account"
  description  = "Service account to newly created bucket. Permission for each bucket shoud be set from bucket perspective"
}

resource "google_service_account_iam_member" "gcs_service_account_key_admins" {
  for_each           = toset(var.gcs_service_account_key_admins)
  service_account_id = google_service_account.gcs_service_account.0.name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = each.value
}

# Read-Only Service Accounts
resource "google_service_account" "gcs_ro_service_account" {
  count        = var.create_read_only_gcs_service_account ? 1 : 0
  account_id   = "${var.gcs_bucket_name}-ro-gcs"
  display_name = "${var.gcs_bucket_name} gcs bucket read-only service account"
  description  = "Service account for read-only purpose to newly created bucket. Permission for each bucket shoud be set from bucket perspective"
}

resource "google_service_account_iam_member" "gcs_service_account_ro_key_admins" {
  for_each           = toset(var.gcs_service_account_ro_key_admins)
  service_account_id = google_service_account.gcs_ro_service_account.0.name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = each.value
}

# Default access to bucket
resource "google_storage_bucket_iam_member" "gcs_bucket_default_iam_object_admin" {
  count  = var.create_default_gcs_service_account ? 1 : 0
  bucket = google_storage_bucket.gcs_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.gcs_service_account.0.email}"
}

resource "google_storage_bucket_iam_member" "gcs_bucket_default_iam_object_admin_legacy" {
  count  = var.create_default_gcs_service_account ? 1 : 0
  bucket = google_storage_bucket.gcs_bucket.name
  role   = "roles/storage.legacyBucketOwner"
  member = "serviceAccount:${google_service_account.gcs_service_account.0.email}"
}

# Default access for read-only Service Account to bucket
resource "google_storage_bucket_iam_member" "gcs_bucket_ro_iam_object_admin" {
  count  = var.create_read_only_gcs_service_account ? 1 : 0
  bucket = google_storage_bucket.gcs_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gcs_ro_service_account.0.email}"
}

# Default access for read-only Service Account to bucket, this is to fix old client
# that relies on getting buckets
resource "google_storage_bucket_iam_member" "gcs_bucket_ro_iam_object_admin_legacy" {
  count  = var.create_read_only_gcs_service_account ? 1 : 0
  bucket = google_storage_bucket.gcs_bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.gcs_ro_service_account.0.email}"
}

# Additional Admin Access to The Bucket
resource "google_storage_bucket_iam_member" "gcs_bucket_iam_object_admin" {
  for_each = toset(var.gcs_bucket_iam_object_admins)
  bucket   = google_storage_bucket.gcs_bucket.name
  role     = "roles/storage.objectAdmin"
  member   = each.value
}

resource "google_storage_bucket_iam_member" "gcs_bucket_iam_object_admin_legacy" {
  for_each = toset(var.gcs_bucket_iam_object_admins)
  bucket   = google_storage_bucket.gcs_bucket.name
  role     = "roles/storage.legacyBucketOwner"
  member   = each.value
}

# Additional Viewer Access to The Bucket
resource "google_storage_bucket_iam_member" "gcs_bucket_iam_object_viewer" {
  for_each = toset(var.gcs_bucket_iam_object_viewers)
  bucket   = google_storage_bucket.gcs_bucket.name
  role     = "roles/storage.objectViewer"
  member   = each.value
}

# Additional Legacy Viewer Access to The Bucket, this is to fix old client
# that relies on getting buckets
resource "google_storage_bucket_iam_member" "gcs_bucket_iam_object_legacy_viewer" {
  for_each = toset(var.gcs_bucket_iam_object_viewers)
  bucket   = google_storage_bucket.gcs_bucket.name
  role     = "roles/storage.legacyBucketReader"
  member   = each.value
}

resource "google_storage_bucket_iam_member" "gcs_bucket_iam_object_creator" {
  for_each = toset(var.gcs_bucket_iam_object_creators)
  bucket   = google_storage_bucket.gcs_bucket.name
  role     = "roles/storage.objectCreator"
  member   = each.value
}

# Public read access
resource "google_storage_bucket_access_control" "public_rule" {
  count  = var.public_read_access ? 1 : 0
  bucket = google_storage_bucket.gcs_bucket.name
  role   = "READER"
  entity = "allUsers"
}
