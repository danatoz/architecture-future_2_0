variable "container_name" {
  description = "Docker container name"
  type        = string
}

variable "image" {
  description = "Docker image to use"
  type        = string
  default     = "nginx:latest"
}

variable "memory" {
  description = "Memory limit in bytes (e.g. 268435456 for 256MB)"
  type        = number
  default     = 268435456
}

variable "cpu_shares" {
  description = "CPU shares (relative weight)"
  type        = number
  default     = 512
}

variable "ports" {
  description = "Port mappings (internal/external)"
  type = list(object({
    internal = number
    external = number
    protocol = optional(string, "tcp")
  }))
  default = []
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

variable "keep_locally" {
  description = "Keep the image locally after destroy"
  type        = bool
  default     = false
}
