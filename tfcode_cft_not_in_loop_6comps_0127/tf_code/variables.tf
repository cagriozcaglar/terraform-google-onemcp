variable "project_id" {
  description = "The unique identifier for the Google Cloud project where resources will be deployed. If not provided, the provider's project will be used."
  type        = string
  default     = null
}

variable "region" {
  description = "The Google Cloud region where network resources will be created."
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name for the custom VPC network."
  type        = string
  default     = "onemcp-vpc"
}

variable "subnet_name" {
  description = "The name for the subnetwork to be created within the VPC."
  type        = string
  default     = "onemcp-subnet"
}

variable "subnet_ip_cidr_range" {
  description = "The primary IPv4 address range for the subnetwork, specified in CIDR notation."
  type        = string
  default     = "10.10.10.0/24"
}

variable "apis_to_enable" {
  description = "A list of Google Cloud APIs to enable on the project."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iap.googleapis.com"
  ]
}
