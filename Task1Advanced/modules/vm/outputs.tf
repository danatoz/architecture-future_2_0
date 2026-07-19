output "container_id" {
  description = "Container ID"
  value       = docker_container.this.id
}

output "container_name" {
  description = "Container name"
  value       = docker_container.this.name
}

output "network_data" {
  description = "Network data of the container"
  value       = docker_container.this.network_data
}

output "ports" {
  description = "Port mappings"
  value       = docker_container.this.ports
}
