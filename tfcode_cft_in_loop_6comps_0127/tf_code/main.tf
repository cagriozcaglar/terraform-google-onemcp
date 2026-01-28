locals {
  # A flag to control resource creation based on whether an organization or folder ID is provided.
  create_project = var.org_id != null || var.folder_id != null

  # A set of administrative roles that provide broad control over the project.
  # This set follows the principle of least privilege by using granular service-level
  # admin roles instead of the overly permissive 'roles/editor' primitive role.
  admin_roles = toset([
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
    "roles/logging.admin",
    "roles/compute.admin",
    "roles/container.admin",
    "roles/cloudsql.admin",
    "roles/pubsub.admin",
    "roles/cloudfunctions.admin",
    "roles/run.admin",
    "roles/billing.projectManager"
  ])

  # A set of APIs to enable on the management project.
  apis_to_enable = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "storage.googleapis.com",
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "pubsub.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com"
  ])
}

# Used to generate a unique suffix for the project ID to avoid collisions.
resource "random_id" "project_suffix" {
  # Controls whether this resource is created. A suffix is only needed if a project is being created.
  count = local.create_project ? 1 : 0

  # The number of random bytes to produce. 4 bytes provides 8 hex characters for the suffix.
  byte_length = 4
}

# Creates the core OneMCP management project.
resource "google_project" "onemcp_project" {
  # Controls whether this resource is created, based on the presence of org_id or folder_id.
  count = local.create_project ? 1 : 0

  # The user-assigned unique ID of the project. Must be 6 to 30 lowercase letters, digits, or hyphens.
  project_id = "${var.project_name_prefix}-${random_id.project_suffix[0].hex}"
  # The human-readable name of the project.
  name = var.project_name_prefix
  # The ID of the billing account to link to the project.
  billing_account = var.billing_account
  # The ID of the folder to create the project in.
  folder_id = var.folder_id
  # The ID of the organization to create the project in. Only used if folder_id is not set.
  org_id = var.folder_id == null ? var.org_id : null
}

# Enables the necessary APIs on the management project.
# This is a best practice to explicitly manage service enablement.
resource "google_project_service" "apis" {
  # Iterates over a set of APIs to enable on the project. Conditionally empty if no project is created.
  for_each = local.create_project ? local.apis_to_enable : toset([])

  # The project ID to enable the service on.
  project = google_project.onemcp_project[0].project_id
  # The service to enable.
  service = each.key
  # If set to true, the service will not be disabled when the resource is destroyed. Set to false to support clean test runs.
  disable_on_destroy = false
}

# Creates a secure GCS bucket to act as the centralized log sink destination.
resource "google_storage_bucket" "log_sink_bucket" {
  # Controls whether this resource is created, based on the presence of org_id or folder_id.
  count = local.create_project ? 1 : 0

  # The project ID where the bucket will be created.
  project = google_project.onemcp_project[0].project_id
  # The name of the bucket. Must be globally unique.
  name = "${google_project.onemcp_project[0].project_id}-logs"
  # The location of the bucket.
  location = var.log_bucket_location
  # Enables Uniform Bucket-Level Access, which is a security best practice for consistent permission management.
  uniform_bucket_level_access = true
  # When set to true, allows the deletion of a non-empty bucket. This is useful for testing environments.
  force_destroy = var.force_destroy_log_bucket

  # Enables object versioning to protect against accidental deletion or overwrites.
  versioning {
    # Whether versioning is enabled for objects in this bucket.
    enabled = true
  }

  # The bucket's lifecycle configuration to automatically delete old logs.
  lifecycle_rule {
    # The condition that triggers the action.
    condition {
      # The number of days after object creation to take the action.
      age = var.log_retention_days
    }
    # The action to take when the condition is met.
    action {
      # The type of action to take. 'Delete' is used to remove old logs.
      type = "Delete"
    }
  }

  # Explicitly depends on the Storage API being enabled to avoid race conditions.
  depends_on = [google_project_service.apis["storage.googleapis.com"]]
}

# Creates a project-level log sink to export all logs from the management project to the GCS bucket.
resource "google_logging_project_sink" "log_sink" {
  # Controls whether this resource is created, based on the presence of org_id or folder_id.
  count = local.create_project ? 1 : 0

  # A descriptive name for the log sink.
  name = "central-gcs-log-sink"
  # The project ID for the log sink.
  project = google_project.onemcp_project[0].project_id
  # The destination for the log sink. Must be in the format 'storage.googleapis.com/[BUCKET_NAME]'.
  destination = "storage.googleapis.com/${google_storage_bucket.log_sink_bucket[0].name}"
  # The filter to apply when exporting logs. An empty filter exports all logs from the project.
  filter = ""
  # Ensures a unique service account is created for this sink, which is a security best practice.
  unique_writer_identity = true

  # Explicitly depends on the Logging API being enabled to avoid race conditions.
  depends_on = [google_project_service.apis["logging.googleapis.com"]]
}

# Grants the log sink's service account the necessary permissions on the destination GCS bucket.
resource "google_storage_bucket_iam_member" "log_sink_writer" {
  # Controls whether this resource is created, based on the presence of org_id or folder_id.
  count = local.create_project ? 1 : 0

  # The bucket to grant the role on.
  bucket = google_storage_bucket.log_sink_bucket[0].name
  # The IAM role to grant. `roles/logging.bucketWriter` is the principle of least privilege for this purpose.
  role = "roles/logging.bucketWriter"
  # The member to grant the role to. This is the unique service account created by the log sink.
  member = google_logging_project_sink.log_sink[0].writer_identity
}

# Creates a dedicated service account for Terraform automation.
resource "google_service_account" "terraform_sa" {
  # Controls whether this resource is created, based on the presence of org_id or folder_id.
  count = local.create_project ? 1 : 0

  # The project to create the service account in.
  project = google_project.onemcp_project[0].project_id
  # The account ID for the service account.
  account_id = var.terraform_service_account_id
  # A human-readable display name for the service account.
  display_name = "Terraform Admin for OneMCP"
  # A description for the service account.
  description = "Service account for Terraform to manage the OneMCP project."

  # Explicitly depends on the IAM API being enabled to avoid race conditions.
  depends_on = [google_project_service.apis["iam.googleapis.com"]]
}

# Grants administrative privileges to the specified admin group.
# This grants a set of specific administrative roles instead of the primitive owner role
# to follow the principle of least privilege.
resource "google_project_iam_member" "admin_group" {
  # Iterates over a set of IAM roles to grant to the admin group. This loop only runs if a project is created and an admin group email is provided.
  for_each = local.create_project && var.admin_group_email != "" ? local.admin_roles : toset([])

  # The project ID where the IAM policy will be applied.
  project = google_project.onemcp_project[0].project_id
  # The role to grant.
  role = each.key
  # The Google Group to grant the role to, prefixed with 'group:'.
  member = "group:${var.admin_group_email}"

  # Explicitly depends on all APIs being enabled to avoid race conditions when granting roles.
  depends_on = [google_project_service.apis]
}

# Grants the Terraform service account project administrative permissions on the management project.
# This allows it to manage all resources within this project.
# This grants a set of specific administrative roles instead of the primitive owner role
# to follow the principle of least privilege.
resource "google_project_iam_member" "terraform_sa_admin" {
  # Iterates over a set of IAM roles to grant to the Terraform service account.
  for_each = local.create_project ? local.admin_roles : toset([])

  # The project ID where the IAM policy will be applied.
  project = google_project.onemcp_project[0].project_id
  # The role to grant.
  role = each.key
  # The service account to grant the role to.
  member = "serviceAccount:${google_service_account.terraform_sa[0].email}"

  # Explicitly depends on all APIs being enabled and the SA being created to avoid race conditions.
  depends_on = [
    google_project_service.apis,
    google_service_account.terraform_sa,
  ]
}
