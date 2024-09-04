module "gcp_predefined_service_account" {
  source = "git::ssh://gcloud-predefined-service-account.git?ref=v0.28.2"

  create_custom_kubernetes_deployer                = true
  create_kubernetes-deployer                       = true
  create_kubernetes_deployer_service_account_roles = true


  
  project                                        = var.project
  kubernetes_deployer_service_account_key_admins = []
  create_prometheus_service_account              = true
  prometheus_service_account_key_admins          = []
  create_bigquery_admin_service_account          = true
  bigquery_admin_service_account_key_admins      = []
  
  create_snapshot_viewer           = true
  snapshot_viewer_service_accounts = []
  
  create_kubecost_viewer_permission     = true
  create_kubecost_turndown_iam_permission = true
  kubecost_service_account = []

  compute_viewer_service_accounts = []
}
