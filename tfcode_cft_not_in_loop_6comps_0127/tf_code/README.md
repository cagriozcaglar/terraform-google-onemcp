# Terraform OneMCP GCP Project Foundation Module

This Terraform module, named OneMCP, is designed to configure a foundational Google Cloud Platform (GCP) project. It handles the essential setup tasks, including enabling a core set of APIs and provisioning a secure, custom Virtual Private Cloud (VPC) network.

By automating these initial steps, the module ensures a consistent and best-practice-based starting point for deploying further resources. It creates a VPC network, a subnet within a specified region, and a firewall rule to allow SSH access via Google's Identity-Aware Proxy (IAP), which is a security best practice over exposing SSH to the public internet.

## Usage

The following example shows how to use the module to set up a foundational project structure.

```hcl
module "onemcp_foundation" {
  source               = "./" # Or use a git source
  project_id           = "your-gcp-project-id"
  region               = "us-west1"
  network_name         = "my-app-vpc"
  subnet_name          = "my-app-subnet-us-west1"
  subnet_ip_cidr_range = "10.0.1.0/24"
  apis_to_enable = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iap.googleapis.com",
    "dns.googleapis.com" # Example of adding an extra API
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `apis_to_enable` | A list of Google Cloud APIs to enable on the project. | `list(string)` | <pre>[<br>  "compute.googleapis.com",<br>  "iam.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "serviceusage.googleapis.com",<br>  "iap.googleapis.com"<br>]</pre> | no |
| `network_name` | The name for the custom VPC network. | `string` | `"onemcp-vpc"` | no |
| `project_id` | The unique identifier for the Google Cloud project where resources will be deployed. If not provided, the provider's project will be used. | `string` | `null` | no |
| `region` | The Google Cloud region where network resources will be created. | `string` | `"us-central1"` | no |
| `subnet_ip_cidr_range` | The primary IPv4 address range for the subnetwork, specified in CIDR notation. | `string` | `"10.10.10.0/24"` | no |
| `subnet_name` | The name for the subnetwork to be created within the VPC. | `string` | `"onemcp-subnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `network_id` | The unique ID of the created VPC network. |
| `network_name` | The name of the created VPC network. |
| `subnet_id` | The unique ID of the created subnetwork. |
| `subnet_name` | The name of the created subnetwork. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

The following requirements are needed by this module:

- Terraform >= 1.3.0
- Terraform Provider for Google Cloud Platform >= 5.0
