container_name = "dev-web"
image          = "nginx:alpine"
memory         = 268435456
cpu_shares     = 512

ports = [
  { internal = 80, external = 8080 }
]

env_vars = {
  NGINX_HOST = "dev.local"
  NGINX_PORT = "80"
}
