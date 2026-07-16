terraform {
  required_providers {
    docker = {
      source = "registry.opentofu.org/kreuzwerker/docker"
    }
  }
}

resource "docker_image" "this" {
  name         = var.image
  keep_locally = var.keep_locally
}

resource "docker_container" "this" {
  name  = var.container_name
  image = docker_image.this.image_id

  memory     = var.memory
  cpu_shares = var.cpu_shares

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = ports.value.internal
      external = ports.value.external
      protocol = try(ports.value.protocol, "tcp")
    }
  }

  env = [for k, v in var.env_vars : "${k}=${v}"]

  restart = var.restart
}
