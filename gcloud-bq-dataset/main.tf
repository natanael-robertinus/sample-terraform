#========================================= Dataset =========================================#

resource "google_bigquery_dataset" "bq_dataset" {
  count = var.enable_gke_dataset ? 1 : 0
  dataset_id                  = "${local.environment_prefix}_${var.country}_${var.focus_area}_bq_dataset"
  description                 = var.description
  location                    = var.location

  labels = {
    country       = var.country,
    environment   = var.environment,
    focus_area    = var.focus_area,
    is_temporary  = var.is_temporary,
    managed       = var.managed,
    product_group = var.product_group,
    state         = var.resource_state,
    team          = var.team
  }
}

resource "google_bigquery_dataset_iam_member" "data_viewer" {
  for_each = var.enable_gke_dataset ? toset(var.gke_dataset_viewer): []
  dataset_id = google_bigquery_dataset.bq_dataset[0].dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = each.value
}

resource "google_bigquery_dataset_iam_member" "data_editor" {
  for_each = var.enable_gke_dataset ? toset(var.gke_dataset_editor): []
  dataset_id = google_bigquery_dataset.bq_dataset[0].dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = each.value
}

resource "google_bigquery_dataset_iam_member" "billing_data_viewer" {
  for_each = var.enable_gke_dataset ?  [] : toset(var.billing_dataset_viewer)
  dataset_id = "gopay_group_billing_export_dataset"
  role       = "roles/bigquery.dataViewer"
  member     = each.value
}

resource "google_bigquery_dataset_iam_member" "billing_data_editor" {
  for_each = var.enable_gke_dataset ?  [] : toset(var.billing_dataset_editor)
  dataset_id = "gopay_group_billing_export_dataset"
  role       = "roles/bigquery.dataEditor"
  member     = each.value
}

#=========================================View Table=========================================#

resource "google_bigquery_table" "customized_view_table" {
  for_each   = {for view_table in var.view_table_set: view_table.table_id => view_table}
  dataset_id = each.value.dataset_id
  table_id   = each.value.table_id
  labels = {
      environment   = each.value.environment,
      focus_area    = each.value.focus_area,
      product_group = each.value.product_group,
      team          = each.value.team
  }

  view {
    query = each.value.query
    use_legacy_sql = each.value.use_legacy_sql
  }
}

resource "google_bigquery_dataset_access" "authorized_view_table_access" {
  for_each = {for view_table in var.view_table_set: view_table.table_id => view_table}
  dataset_id    = each.value.dataset_id
  view {
    project_id = each.value.project
    dataset_id = each.value.dataset_id
    table_id   = each.value.table_id
  }
}

resource "google_bigquery_table_iam_member" "customized_view_table_role" {
  for_each = {for view_member in local.view_members: "${view_member.member}.${view_member.table_id}" => view_member}
  project = each.value.project
  dataset_id = each.value.dataset_id
  table_id = each.value.table_id
  role = "roles/bigquery.dataViewer"
  member   = each.value.member
}