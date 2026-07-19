variable "container_name" {
  description = "Docker container name"
  type        = string
}

variable "image" {
  description = "Docker image"
  type        = string
}

variable "memory" {
  description = "Memory limit in bytes"
  type        = number
}

variable "cpu_shares" {
  description = "CPU shares"
  type        = number
}

variable "ports" {
  description = "Port mappings"
  type = list(object({
    internal = number
    external = number
    protocol = optional(string, "tcp")
  }))
}

variable "env_vars" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "restart" {
  description = "Restart policy"
  type        = string
  default     = "unless-stopped"
}
