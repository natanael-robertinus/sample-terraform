module "gcp_predefined_iam" {
  source = "git::ssh://gcloud-predefined-iam.git?ref=v1.10.5"

  project = var.project
  viewer_iam_members = []

  gcr_editor_iam_members = []

  gke_cluster_upgrader_iam_members = []

  compute_operator_iam_members = []

  tech_support_editor_iam_members = []

  compute_interconnect_members = []
}
