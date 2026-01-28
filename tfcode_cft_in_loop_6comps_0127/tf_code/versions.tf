terraform {
  # Specifies the minimum version of Terraform required to apply this configuration.
  required_version = ">= 1.3"

  required_providers {
    # Defines the required Google Cloud Platform provider and its version constraints.
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    # Defines the required Random provider for generating unique identifiers.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
