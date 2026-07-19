# Модуль контейнера

Terraform-модуль для создания Docker-контейнера с использованием провайдера `kreuzwerker/docker`.

## Параметры

| Имя             | Тип    | Обязательный | Описание                               |
|-----------------|--------|--------------|----------------------------------------|
| container_name  | string | да           | Имя контейнера                         |
| image           | string | нет          | Docker-образ (по умолчанию nginx:latest) |
| memory          | number | нет          | Лимит памяти в байтах (по умолчанию 256MB) |
| cpu_shares      | number | нет          | Относительный вес CPU (по умолчанию 512) |
| ports           | list   | нет          | Проброс портов                         |
| env_vars        | map    | нет          | Переменные окружения                   |
| restart         | string | нет          | Политика перезапуска (по умолчанию unless-stopped) |
| keep_locally    | bool   | нет          | Не удалять образ после destroy (по умолчанию false) |

## Выходные данные

| Имя            | Описание              |
|----------------|-----------------------|
| container_id   | ID контейнера         |
| container_name | Имя контейнера        |
| network_data   | Сетевые данные        |
| ports          | Проброшенные порты    |

## Использование

```hcl
module "container" {
  source = "../../modules/vm"

  container_name = "web-app"
  image          = "nginx:alpine"
  memory         = 536870912
  cpu_shares     = 1024

  ports = [
    { internal = 80, external = 8080 }
  ]

  env_vars = {
    NGINX_HOST = "example.com"
  }
}
```

## Развёртывание окружения

```bash
cd envs/dev
terraform init
terraform apply -auto-approve
```

Или через скрипт:

```bash
./deploy.sh dev apply     # развернуть
./deploy.sh dev destroy   # удалить
```
