# Задание 2. Интеграция с CI/CD и удалённым хранением состояния

## Обзор

Terraform-инфраструктура с управлением Docker-контейнерами через провидер `kreuzwerker/docker`.

- **Удалённое состояние (remote state)** в MinIO (S3-совместимый backend)
- **CI/CD пайплайн** в GitHub Actions: `plan` (checkout → MinIO → init → validate → plan) → `apply` (checkout → MinIO → init → apply → verify)
- **Локальный запуск** через `deploy.sh` (apply / destroy)

## Remote State (MinIO Backend)

Конфигурация backend'а в `environments/dev/backend.tf` использует MinIO:

```hcl
terraform {
  backend "s3" {
    bucket   = "tfstate"
    key      = "environments/dev/terraform.tfstate"
    endpoint = "http://localhost:9000"
  }
}
```

MinIO запускается локально через `docker-compose.yml` или как service container в CI.

## CI/CD Pipeline (GitHub Actions)

Файл: `.github/workflows/terraform.yml`

| Job    | Триггер                           | Подтверждение | Шаги |
|--------|-----------------------------------|---------------|------|
| plan   | push (main/develop), PR           | авто          | checkout → Start MinIO + bucket → setup-terraform → init → validate → plan → upload artifact |
| apply  | push (main/develop)               | manual        | checkout → Start MinIO + bucket → setup-terraform → download artifact → init → apply → verify |

- **apply** требует ручного подтверждения через GitHub Environments (`production` / `development`).
- **verify** — step внутри apply: `docker ps` + curl к dev-web.

## Предварительные требования

- Docker и Docker Compose
- Terraform >= 1.0
- MinIO (запускается автоматически скриптами)

## Локальный запуск

```bash
# Apply
bash deploy.sh dev apply

# Destroy
bash deploy.sh dev destroy
```

Скрипт автоматически:
1. Запускает MinIO (docker compose)
2. Создаёт bucket `tfstate`
3. Выполняет `terraform init` + `apply` / `destroy`

### Пошагово вручную

```bash
# 1. Запустить MinIO
bash setup-minio.sh

# 2. Развернуть
cd environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Структура

```
Task2Advanced/
├── deploy.sh               # Универсальный скрипт apply/destroy
├── setup-minio.sh           # Запуск MinIO и создание bucket
├── docker-compose.yml       # MinIO service
├── environments/
│   └── dev/
│       ├── backend.tf       # S3 backend → MinIO
│       ├── main.tf          # Docker-контейнер через модуль vm
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars # Значения для dev
├── modules/
│   └── vm/                  # Модуль Docker-контейнера
└── logs/                    # Логи deploy.sh
```
