locals {
  environment_prefix = var.environment == "production" ? "p" : var.environment == "staging" ? "s" : var.environment == "integration" ? "g" : "i"
  view_members = flatten([
    for view_set in var.view_table_set : [
      for member in view_set.members : {
        project  = view_set.project
        dataset_id = view_set.dataset_id
        table_id = view_set.table_id
        member  = member
      }
    ]
  ])
}
