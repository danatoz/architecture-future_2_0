container_name = "prod-web"
image          = "nginx:alpine"
memory         = 1073741824
cpu_shares     = 2048

ports = [
  { internal = 80, external = 8082 }
]

env_vars = {
  NGINX_HOST = "prod.local"
  NGINX_PORT = "80"
}
