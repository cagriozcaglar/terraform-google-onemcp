output "log_sink_bucket_name" {
  description = "The name of the GCS bucket created for centralized logging."
  value       = try(google_storage_bucket.log_sink_bucket[0].name, null)
}

output "log_sink_writer_identity" {
  description = "The service account identity that writes logs to the GCS bucket."
  value       = try(google_logging_project_sink.log_sink[0].writer_identity, null)
}

output "management_project_id" {
  description = "The unique ID of the created OneMCP management project."
  value       = try(google_project.onemcp_project[0].project_id, null)
}

output "terraform_service_account_email" {
  description = "The email address of the service account created for Terraform automation."
  value       = try(google_service_account.terraform_sa[0].email, null)
}
