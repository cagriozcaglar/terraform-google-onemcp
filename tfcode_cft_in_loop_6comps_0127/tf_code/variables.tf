variable "admin_group_email" {
  description = "The email of the Google Group that will be granted administrative access to the management project. E.g., 'gcp-admins@example.com'. If not provided, no group will be granted access."
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "The ID of the billing account to associate with the management project. If not provided, the project will be created without a billing account."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "The ID of the folder to create the management project in. If not provided, `org_id` must be specified."
  type        = string
  default     = null
}

variable "force_destroy_log_bucket" {
  description = "If set to true, allows the deletion of the log GCS bucket even if it's not empty. This is useful for testing environments."
  type        = bool
  default     = false
}

variable "log_bucket_location" {
  description = "The location for the centralized log sink GCS bucket."
  type        = string
  default     = "US"
}

variable "log_retention_days" {
  description = "The number of days to retain logs in the GCS bucket before deletion."
  type        = number
  default     = 3650
}

variable "org_id" {
  description = "The organization ID where the management project will be created. Used only if `folder_id` is not specified."
  type        = string
  default     = null
}

variable "project_name_prefix" {
  description = "A prefix for the name and ID of the OneMCP management project. Must be 21 characters or less."
  type        = string
  default     = "onemcp-management"

  validation {
    condition     = length(var.project_name_prefix) <= 21
    error_message = "The project_name_prefix must be 21 characters or less to accommodate the random suffix."
  }
}

variable "terraform_service_account_id" {
  description = "The ID for the Terraform service account to be created. Must be between 6 and 30 characters."
  type        = string
  default     = "tf-onemcp-admin"

  validation {
    condition     = length(var.terraform_service_account_id) >= 6 && length(var.terraform_service_account_id) <= 30
    error_message = "The terraform_service_account_id must be between 6 and 30 characters."
  }
}
