container_name = "stage-web"
image          = "nginx:alpine"
memory         = 536870912
cpu_shares     = 1024

ports = [
  { internal = 80, external = 8081 }
]

env_vars = {
  NGINX_HOST = "stage.local"
  NGINX_PORT = "80"
}
