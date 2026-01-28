output "network_name" {
  description = "The name of the created VPC network."
  value       = google_compute_network.onemcp_vpc.name
}

output "network_id" {
  description = "The unique ID of the created VPC network."
  value       = google_compute_network.onemcp_vpc.id
}

output "subnet_name" {
  description = "The name of the created subnetwork."
  value       = google_compute_subnetwork.onemcp_subnet.name
}

output "subnet_id" {
  description = "The unique ID of the created subnetwork."
  value       = google_compute_subnetwork.onemcp_subnet.id
}
