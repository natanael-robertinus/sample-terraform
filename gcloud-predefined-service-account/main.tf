# Compute image SA service account
resource "google_project_iam_member" "compute_image_user_service_account_roles" {
  for_each = toset(var.compute_image_user_service_accounts)
  project  = var.project
  role     = local.compute_image_service_account_role
  member   = "serviceAccount:${each.value}"
}

# GCR admin service account
resource "google_service_account" "gcr_admin" {
  count        = var.create_gcr_admin_service_account ? 1 : 0
  account_id   = "gcr-admin"
  display_name = "gcr-admin"
  description  = "Service account to administrate images on GCR"
}

resource "google_project_iam_member" "gcr_admin_service_account_roles" {
  count  = var.create_gcr_admin_service_account ? 1 : 0
  project  = var.project
  role   = local.gcr_admin_service_account_role
  member = "serviceAccount:${google_service_account.gcr_admin[0].email}"
}

resource "google_storage_bucket_iam_member" "gcr_bucket_admin_members_us" {
  for_each = { for v in local.gcr_bucket_admin_members["us"] : v => v }
  bucket   = local.gcr_bucket_us
  role     = local.gcr_admin_service_account_role
  member   = each.key
}

resource "google_storage_bucket_iam_member" "gcr_bucket_admin_members_asia" {
  for_each = { for v in local.gcr_bucket_admin_members["asia"] : v => v }
  bucket   = local.gcr_bucket_asia
  role     = local.gcr_admin_service_account_role
  member   = each.key
}

resource "google_storage_bucket_iam_member" "gcr_bucket_admin_members_eu" {
  for_each = { for v in local.gcr_bucket_admin_members["eu"] : v => v }
  bucket   = local.gcr_bucket_eu
  role     = local.gcr_admin_service_account_role
  member   = each.key
}

resource "google_service_account_iam_member" "gcr_admin_service_account_key_admins" {
  count              = var.create_gcr_admin_service_account ? length(var.gcr_admin_service_account_key_admins) : 0
  service_account_id = google_service_account.gcr_admin[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.gcr_admin_service_account_key_admins[count.index]
}

# GCR read service account
resource "google_service_account" "gcr_read" {
  count        = var.create_gcr_read_service_account ? 1 : 0
  account_id   = "gcr-read"
  display_name = "gcr-read"
  description  = "Service account to pull images on GCR"
}

resource "google_project_iam_member" "gcr_read_service_account_roles" {
  count  = var.create_gcr_read_service_account ? 1 : 0
  project  = var.project
  role   = local.gcr_read_service_account_role
  member = "serviceAccount:${google_service_account.gcr_read[0].email}"
}

resource "google_storage_bucket_iam_member" "gcr_bucket_read_members_us" {
  for_each = { for v in local.gcr_bucket_read_members["us"] : v => v }
  bucket   = local.gcr_bucket_us
  role     = local.gcr_read_service_account_role
  member   = each.key
}

resource "google_storage_bucket_iam_member" "gcr_bucket_read_members_asia" {
  for_each = { for v in local.gcr_bucket_read_members["asia"] : v => v }
  bucket   = local.gcr_bucket_asia
  role     = local.gcr_read_service_account_role
  member   = each.key
}

resource "google_storage_bucket_iam_member" "gcr_bucket_read_members_eu" {
  for_each = { for v in local.gcr_bucket_read_members["eu"] : v => v }
  bucket   = local.gcr_bucket_eu
  role     = local.gcr_read_service_account_role
  member   = each.key
}

resource "google_service_account_iam_member" "gcr_read_service_account_key_admins" {
  count              = var.create_gcr_read_service_account ? length(var.gcr_read_service_account_key_admins) : 0
  service_account_id = google_service_account.gcr_read[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.gcr_read_service_account_key_admins[count.index]
}

# Custom kubernetes deployer service account
resource "google_service_account" "kubernetes_deployer" {
  count        = var.create_kubernetes-deployer ? 1 : 0
  account_id   = "kubernetes-deployer"
  display_name = "kubernetes-deployer"
  description  = "Service account to deploy resources to GKE."
}

resource "google_project_iam_custom_role" "custom_kubernetes_deployer" {
  count       = var.create_custom_kubernetes_deployer ? 1 : 0
  role_id     = "custom_kubernetes_deployer"
  title       = "custom_kubernetes_deployer"
  description = "Role as an extension for kubernetes-deployer service account"
  permissions = [
    "container.clusterRoles.create",
    "container.clusterRoles.update",
    "container.clusterRoles.delete",
    "container.clusterRoleBindings.create",
    "container.clusterRoleBindings.update",
    "container.clusterRoleBindings.delete",
    "container.roleBindings.create",
    "container.roleBindings.update",
    "container.roleBindings.delete",
    "container.roles.bind",
    "container.roles.create",
    "container.roles.delete",
    "container.roles.escalate",
    "container.roles.update",
    "container.podSecurityPolicies.create",
    "container.podSecurityPolicies.delete",
    "container.podSecurityPolicies.update",
    "container.validatingWebhookConfigurations.create",
    "container.validatingWebhookConfigurations.get",
    "container.validatingWebhookConfigurations.update",
    "container.validatingWebhookConfigurations.delete",
    "container.mutatingWebhookConfigurations.create",
    "container.mutatingWebhookConfigurations.get",
    "container.mutatingWebhookConfigurations.update",
    "container.mutatingWebhookConfigurations.delete"
  ]
}

resource "google_project_iam_member" "kubernetes_deployer_custom_service_account_roles" {
  count    = var.create_custom_kubernetes_deployer ? 1 : 0
  project  = var.project
  role     = google_project_iam_custom_role.custom_kubernetes_deployer[count.index].id
  member   = "serviceAccount:${google_service_account.kubernetes_deployer[count.index].email}"
}

resource "google_project_iam_member" "kubernetes_deployer_service_account_roles" {
  for_each = var.create_kubernetes_deployer_service_account_roles == true ? toset(local.kubernetes_deployer_service_account_roles) :toset([])
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.kubernetes_deployer[0].email}"
}

resource "google_service_account_iam_member" "kubernetes_deployer_service_account_key_admins" {
  for_each           = var.create_kubernetes_deployer_service_account_key_admins == true ? toset(var.kubernetes_deployer_service_account_key_admins) :toset([])
  service_account_id = google_service_account.kubernetes_deployer[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = each.value
}

# SCP Custom Role
resource "google_project_iam_custom_role" "scp_server_custom_role" {
  count       = var.create_scp_server_custom_role ? 1 : 0
  role_id     = "custom_scp_server"
  title       = "SCP Server"
  description = "Role required by SCP (Gopay.sh Database Addon) to manage compute and storage"
  permissions = [
    "compute.snapshots.delete",
    "compute.snapshots.get",    
    "compute.snapshots.list",
    "compute.instances.create",
    "compute.subnetworks.use",
  ]
}

resource "google_project_iam_member" "scp_server_custom_role_service_account_roles" {
  for_each    = toset(var.scp_server_custom_role_service_accounts)
  project     = var.project  
  role        = google_project_iam_custom_role.scp_server_custom_role[0].id
  member      = "serviceAccount:${each.value}"  
}

# End of SCP Custom Role

# Packer service account
resource "google_service_account" "packer" {
  count        = var.create_packer_service_account ? 1 : 0
  account_id   = "packer"
  display_name = "packer"
  description  = "Service account to generate packer image. Might be temporary and replaced with machine-owned service account."
}

resource "google_project_iam_member" "packer_service_account_roles" {
  count  = var.create_packer_service_account ? length(local.packer_service_account_roles) : 0
  project  = var.project
  role   = local.packer_service_account_roles[count.index]
  member = "serviceAccount:${google_service_account.packer[0].email}"
}

resource "google_service_account_iam_member" "packer_service_account_key_admins" {
  count              = var.create_packer_service_account ? length(var.packer_service_account_key_admins) : 0
  service_account_id = google_service_account.packer[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.packer_service_account_key_admins[count.index]
}

# Prometheus service account
resource "google_service_account" "prometheus" {
  count        = var.create_prometheus_service_account ? 1 : 0
  account_id   = "prometheus"
  display_name = "prometheus"
  description  = "Service account to allow prometheus collect metrics and read API(s)"
}

resource "google_project_iam_member" "prometheus_service_account_roles" {
  count  = var.create_prometheus_service_account ? length(local.prometheus_service_account_roles) : 0
  project  = var.project
  role   = local.prometheus_service_account_roles[count.index]
  member = "serviceAccount:${google_service_account.prometheus[0].email}"
}

resource "google_service_account_iam_member" "prometheus_service_account_key_admins" {
  count              = var.create_prometheus_service_account ? length(var.prometheus_service_account_key_admins) : 0
  service_account_id = google_service_account.prometheus[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.prometheus_service_account_key_admins[count.index]
}

# SSO GSuite Group Fetcher service account
# This service accounts will need Domain Wide Delegation access. Unfortunately, this can only be done
# manually by using cloud console once the service account created.
# https://github.com/terraform-providers/terraform-provider-google/issues/1959
resource "google_service_account" "sso_group_fetcher" {
  count        = var.create_sso_group_fetcher_service_account ? 1 : 0
  account_id   = "sso-group-fetcher"
  display_name = "sso-group-fetcher"
  description  = "Service account to be used for SSO purpose. This SA has access to fetch gsuite group owned by a user"
}

resource "google_service_account_iam_member" "sso_group_fetcher_service_account_key_admins" {
  count              = var.create_sso_group_fetcher_service_account ? length(var.sso_group_fetcher_service_account_key_admins) : 0
  service_account_id = google_service_account.sso_group_fetcher[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.sso_group_fetcher_service_account_key_admins[count.index]
}

# Big Query service account
resource "google_service_account" "bigquery_admin" {
  count        = var.create_bigquery_admin_service_account ? 1 : 0
  account_id   = "bigquery-admin"
  display_name = "bigquery-admin"
  description  = "Service account to deploy  bigquery-admin Dataset for exporting billing and metering usage."
}

resource "google_project_iam_member" "bigquery_admin_service_account_roles" {
  count  = var.create_bigquery_admin_service_account ? length(local.bigquery_admin_service_account_roles) : 0
  project  = var.project
  role   = local.bigquery_admin_service_account_roles[count.index]
  member = "serviceAccount:${google_service_account.bigquery_admin[0].email}"
}

resource "google_service_account_iam_member" "bigquery_admin_service_account_key_admins" {
  count              = var.create_bigquery_admin_service_account ? length(var.bigquery_admin_service_account_key_admins) : 0
  service_account_id = google_service_account.bigquery_admin[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.bigquery_admin_service_account_key_admins[count.index]
}

# AWS Gopay SA
resource "google_service_account" "aws_gopay" {
  count        = var.create_aws_gopay_service_account ? 1 : 0
  account_id   = "aws-gopay"
  display_name = "aws-gopay"
  description  = "Service account for deploying any AWS-GCP related resources (e.g. site-to-site tunnel)."
}

resource "google_service_account_iam_member" "aws_gopay_service_account_key_admins" {
  count              = var.create_aws_gopay_service_account ? length(var.aws_gopay_service_account_key_admins) : 0
  service_account_id = google_service_account.aws_gopay[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.aws_gopay_service_account_key_admins[count.index]
}

resource "google_project_iam_member" "oauth_brand_editor_roles" {
  for_each = toset(var.oauth_brand_editor_service_accounts)
  project  = var.project
  role     = local.oauth_brand_editor_role
  member   = "serviceAccount:${each.value}"
}

#Snaphot Viewer
resource "google_project_iam_custom_role" "snapshot_viewer" {
  count       = var.create_snapshot_viewer ? 1 : 0
  role_id     = "snapshot_viewer"
  title       = "snapshot_viewer"
  description = "Role as an snapshot viewer from other projects"
  permissions = [
    "compute.snapshots.useReadOnly"
  ]
}

resource "google_project_iam_member" "snapshot_viewer" {
  for_each = toset(var.snapshot_viewer_service_accounts)
  project  = var.project
  role     = google_project_iam_custom_role.snapshot_viewer[0].id
  member   = "serviceAccount:${each.value}"
}

#VPN Gateway remote access for HA VPN setup
resource "google_project_iam_custom_role" "vpn_gateway_use" {
  count       = var.create_vpn_gateway_use ? 1 : 0
  role_id     = "vpn_gateway_use"
  title       = "vpn_gateway_use"
  description = "Temporary role for getting the specified VPN gateway. Gets a list of available VPN gateways by making a list() request."
  permissions = [
    "compute.vpnGateways.use"
  ]
}

resource "google_project_iam_member" "vpn_gateway_use" {
  for_each = toset(var.vpn_gateway_use_service_accounts)
  project  = var.project
  role     = google_project_iam_custom_role.vpn_gateway_use[0].id
  member   = "serviceAccount:${each.value}"
}

#Cloud Task access
resource "google_project_iam_member" "task_enqueuer_role" {
  for_each = toset(var.task_enqueuer_service_accounts)
  project  = var.project
  role     = "roles/cloudtasks.enqueuer"
  member   = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "task_viewer_role" {
  for_each = toset(var.task_enqueuer_service_accounts)
  project  = var.project
  role     = "roles/cloudtasks.viewer"
  member   = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "task_service_account_user_role" {
  for_each = toset(var.task_enqueuer_service_accounts)
  project  = var.project
  role     = "roles/iam.serviceAccountUser"
  member   = "serviceAccount:${each.value}"
}

# GKE Upgrade Service Account

## Create the specific role
resource "google_project_iam_custom_role" "svc_acct_gke_cluster_upgrader" {
  count       = var.create_svc_acct_gke_cluster_upgrader ? 1 : 0
  role_id     = "svc_acct_gke_cluster_upgrader"
  title       = "svc_acct_gke_cluster_upgrader"
  description = "Role for upgrading GKE clusters for service account only"
  permissions = [
    "container.clusters.update",
  ]
}

## Create the service account
resource "google_service_account" "gke_cluster_upgrader" {
  count        = var.create_gke_cluster_upgrader_service_account ? 1 : 0
  account_id   = "gke-cluster-upgrader"
  display_name = "gke-cluster-upgrader"
  description  = "Service account for GKE cluster upgrade"
}

## Assign some people as the key custodian for the service account
resource "google_service_account_iam_member" "gke_cluster_upgrader_key_admins" {
  for_each           = toset(var.gke_cluster_upgrader_service_account_key_admins)
  service_account_id = google_service_account.gke_cluster_upgrader[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = "serviceAccount:${each.value}"
}

## Assign the upgrader role to the service account
resource "google_project_iam_member" "gke_cluster_upgrader_roles" {
  count  = var.create_gke_cluster_upgrader_service_account ? 1 : 0
  project  = var.project
  role   = google_project_iam_custom_role.svc_acct_gke_cluster_upgrader[0].id
  member = "serviceAccount:${google_service_account.gke_cluster_upgrader[0].email}"
}

## Compute Viewer 
resource "google_project_iam_member" "compute_viewer_iam_role_members" {
  for_each = toset(var.compute_viewer_service_accounts)
  project = var.project
  role    = "roles/compute.viewer"
  member   = "serviceAccount:${each.value}"
}

## Compute Operator
resource "google_project_iam_member" "compute_operator_iam_role_members" {
  for_each = toset(var.compute_operator_service_accounts)
  project = var.project
  role    = "projects/${var.project}/roles/compute_operator"
  member   = "serviceAccount:${each.value}"
}

## DNS Viewer 
resource "google_project_iam_member" "dns_viewer_iam_role_members" {
  for_each = toset(var.dns_viewer_service_accounts)
  project = var.project
  role    = "roles/dns.reader"
  member   = "serviceAccount:${each.value}"
}

## Cloud Functions Admin
resource "google_project_iam_member" "cloud_functions_admin_iam_role_members" {
  for_each = toset(var.cloud_functions_admin_service_accounts)
  project = var.project
  role    = "roles/cloudfunctions.admin"
  member   = "serviceAccount:${each.value}"
}

## GCP Vault Auth Service Account
resource "google_service_account" "vault_auth_backend" {
  count        = var.create_vault_auth_backend_service_account ? 1 : 0
  account_id   = "vault-auth-backend"
  display_name = "vault-auth-backend"
  description  = "Service account to authenticate vault with gcp credentials (iam/gce)"
}

resource "google_project_iam_member" "vault_auth_backend_service_account_roles" {
  count  = var.create_vault_auth_backend_service_account ? length(local.vault_auth_backend_service_account_roles) : 0
  project  = var.project
  role   = local.vault_auth_backend_service_account_roles[count.index]
  member = "serviceAccount:${google_service_account.vault_auth_backend[0].email}"
}

resource "google_service_account_iam_member" "vault_auth_backend_service_account_key_admins" {
  count              = var.create_vault_auth_backend_service_account ? length(var.vault_auth_backend_service_account_key_admins) : 0
  service_account_id = google_service_account.vault_auth_backend[0].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = var.vault_auth_backend_service_account_key_admins[count.index]
}
