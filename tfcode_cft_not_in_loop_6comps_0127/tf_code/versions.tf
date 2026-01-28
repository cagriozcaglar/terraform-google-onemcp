terraform {
  # This block configures the Terraform version and the required providers.
  # It ensures that a compatible version of Terraform is used and specifies
  # the necessary cloud providers and their versions.
  required_version = ">= 1.3.0"

  required_providers {
    # The Google Cloud Platform provider is used to manage and provision
    # resources on GCP. The version constraint ensures that a compatible
    # version of the provider is used.
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
