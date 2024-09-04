resource "google_project_iam_custom_role" "gke_operation_exporter_role" {
  role_id     = "gke_operation_exporter_role"
  title       = "GKE Operation Exporter"
  description = "GKE Operation Exporter"
  permissions = [
    "container.operations.get",
    "container.operations.list",
  ]
}
