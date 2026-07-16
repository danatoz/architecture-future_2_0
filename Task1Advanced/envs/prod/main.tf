terraform {
  required_providers {
    docker = {
      source = "registry.opentofu.org/kreuzwerker/docker"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {}

module "container" {
  source = "../../modules/vm"

  container_name = var.container_name
  image          = var.image
  memory         = var.memory
  cpu_shares     = var.cpu_shares
  ports          = var.ports
  env_vars       = var.env_vars
  restart        = var.restart
}
