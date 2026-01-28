# Google Cloud Management Project Module

This module provisions a foundational Google Cloud management project with secure defaults, including centralized logging, a dedicated service account for automation, and IAM policies based on the principle of least privilege.

## Features

-   Creates a new Google Cloud project with a unique ID.
-   Associates the project with a billing account and places it in a specified folder or organization.
-   Enables a standard set of APIs required for common cloud operations.
-   Provisions a GCS bucket for centralized log storage with versioning and a configurable retention policy.
-   Configures a project-level log sink to export all logs to the GCS bucket.
-   Creates a dedicated service account for Terraform automation.
-   Assigns a curated set of administrative IAM roles to the Terraform service account and an optional admin group, avoiding the use of overly permissive primitive roles like `owner` or `editor`.

## Usage

Basic usage of this module is as follows:

```terraform
module "management_project" {
  source              = "path/to/module"
  org_id              = "123456789012"
  billing_account     = "012345-67890A-BCDEF1"
  admin_group_email   = "gcp-admins@example.com"
  project_name_prefix = "my-mgmt-proj"
  log_bucket_location = "US-CENTRAL1"
}
```

## Inputs

| Name                           | Description                                                                                                                              | Type     | Default             | Required |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------- | :------: |
| `admin_group_email`            | The email of the Google Group that will be granted administrative access to the management project. E.g., 'gcp-admins@example.com'. If not provided, no group will be granted access. | `string` | `""`                |    no    |
| `billing_account`              | The ID of the billing account to associate with the management project. If not provided, the project will be created without a billing account. | `string` | `null`              |    no    |
| `folder_id`                    | The ID of the folder to create the management project in. If not provided, `org_id` must be specified.                                     | `string` | `null`              |    no    |
| `force_destroy_log_bucket`     | If set to true, allows the deletion of the log GCS bucket even if it's not empty. This is useful for testing environments.                   | `bool`   | `false`             |    no    |
| `log_bucket_location`          | The location for the centralized log sink GCS bucket.                                                                                    | `string` | `"US"`              |    no    |
| `log_retention_days`           | The number of days to retain logs in the GCS bucket before deletion.                                                                     | `number` | `3650`              |    no    |
| `org_id`                       | The organization ID where the management project will be created. Used only if `folder_id` is not specified.                               | `string` | `null`              |    no    |
| `project_name_prefix`          | A prefix for the name and ID of the OneMCP management project. Must be 21 characters or less.                                              | `string` | `"onemcp-management"` |    no    |
| `terraform_service_account_id` | The ID for the Terraform service account to be created. Must be between 6 and 30 characters.                                               | `string` | `"tf-onemcp-admin"` |    no    |

## Outputs

| Name                            | Description                                                                    |
| ------------------------------- | ------------------------------------------------------------------------------ |
| `log_sink_bucket_name`          | The name of the GCS bucket created for centralized logging.                    |
| `log_sink_writer_identity`      | The service account identity that writes logs to the GCS bucket.               |
| `management_project_id`         | The unique ID of the created OneMCP management project.                        |
| `terraform_service_account_email` | The email address of the service account created for Terraform automation.     |

## Requirements

The following requirements are needed by this module:

-   Terraform `v1.3` or later
-   [Terraform Provider for Google Cloud Platform](https://github.com/hashicorp/terraform-provider-google) `~> 5.0`
-   [Terraform Provider for Random](https://github.com/hashicorp/terraform-provider-random) `~> 3.1`
