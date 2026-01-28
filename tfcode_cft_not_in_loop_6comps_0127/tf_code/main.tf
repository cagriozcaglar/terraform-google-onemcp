# This Terraform module, named OneMCP, is designed to configure a foundational
# Google Cloud Platform (GCP) project. It handles the essential setup tasks,
# including enabling a core set of APIs and provisioning a secure, custom Virtual
# Private Cloud (VPC) network. By automating these initial steps, the module
# ensures a consistent and best-practice-based starting point for deploying
# further resources. It creates a VPC network, a subnet within a specified
# region, and a firewall rule to allow SSH access via Google's Identity-Aware
# Proxy (IAP), which is a security best practice over exposing SSH to the public
# internet.

# <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

locals {
  # A set of APIs to be enabled on the project.
  apis = toset(var.apis_to_enable)
}

# The google_project_service resource enables the specified APIs on the
# given project. A for_each loop is used to iterate over the set of APIs
# defined in the local variable, creating a resource for each one. This
# approach is idempotent and manages each API's state independently. Disabling
# project billing will also disable the service.
resource "google_project_service" "onemcp_apis" {
  # A for_each meta-argument to enable multiple APIs concurrently.
  for_each = local.apis

  # The ID of the project in which the service should be enabled. Defaults to the provider project if not set.
  project = var.project_id

  # The service identity of the API to enable (e.g., "compute.googleapis.com").
  service = each.key

  # If true, services that are enabled and which depend on this service should also
  # be disabled when this service is destroyed.
  disable_dependent_services = true

  # If true, the service can be disabled.
  disable_on_destroy = true
}

# The google_compute_network resource creates a new Virtual Private Cloud (VPC)
# network in the specified project. This module creates a custom-mode VPC,
# meaning that subnets must be created manually, providing greater control over
# the network topology.
resource "google_compute_network" "onemcp_vpc" {
  # The ID of the project in which the resource belongs. Defaults to the provider project if not set.
  project = var.project_id

  # The name of the network.
  name = var.network_name

  # When set to 'true', subnets are created automatically. When set to 'false',
  # the network is created in "custom subnet mode".
  auto_create_subnetworks = false

  # The network's routing mode. A 'REGIONAL' routing mode creates a regional
  # router in every region where there is a subnet. A 'GLOBAL' routing mode
  # will create a single global router.
  routing_mode = "REGIONAL"
}

# The google_compute_subnetwork resource creates a subnetwork within the VPC
# network. This defines a regional IP address range that resources like VM
# instances can use.
resource "google_compute_subnetwork" "onemcp_subnet" {
  # The ID of the project in which the resource belongs. Defaults to the provider project if not set.
  project = var.project_id

  # The name of the subnetwork.
  name = var.subnet_name

  # The network this subnetwork belongs to.
  network = google_compute_network.onemcp_vpc.id

  # The GCP region for this subnetwork.
  region = var.region

  # The an RFC 1918 IP address range for this subnetwork.
  ip_cidr_range = var.subnet_ip_cidr_range
}

# The google_compute_firewall resource creates a firewall rule to control
# traffic to and from VM instances. This rule specifically allows ingress TCP
# traffic on port 22 (SSH) only from Google's IAP (Identity-Aware Proxy)
# forwarding service. This is a security best practice for bastion hosts and
# other managed VMs.
resource "google_compute_firewall" "allow_ssh_via_iap" {
  # The ID of the project in which the resource belongs. Defaults to the provider project if not set.
  project = var.project_id

  # The name of the firewall rule.
  name = "${var.network_name}-allow-ssh-via-iap"

  # The network to which this rule applies.
  network = google_compute_network.onemcp_vpc.self_link

  # The list of target tags that this rule applies to. Instances with these tags
  # will be governed by this rule.
  target_tags = ["allow-ssh-via-iap"]

  # The list of IP address ranges in CIDR format that this rule applies to.
  # This specific range is for Google Cloud's IAP TCP forwarding.
  source_ranges = ["35.235.240.0/20"]

  # The list of allowed ports and protocols.
  allow {
    # The protocol that is allowed. This rule allows TCP traffic.
    protocol = "tcp"
    # The list of ports to which this rule applies. This rule opens port 22 for SSH.
    ports = ["22"]
  }
}
