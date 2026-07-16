#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$SCRIPT_DIR/logs"
ENV_NAME="${1:-dev}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

export AWS_ACCESS_KEY_ID=minioadmin
export AWS_SECRET_ACCESS_KEY=minioadmin

ENV_DIR="$SCRIPT_DIR/environments/$ENV_NAME"
if [ ! -d "$ENV_DIR" ]; then
  echo "Environment '$ENV_NAME' not found at $ENV_DIR"
  exit 1
fi

ACTION="${2:-apply}"

case "$ACTION" in
  apply)
    LOG_FILE="$LOGS_DIR/${ENV_NAME}_apply_${TIMESTAMP}.log"
    echo ">>> Deploying '$ENV_NAME' environment... (log: $LOG_FILE)"

    echo "--- setup minio ---" | tee -a "$LOGS_DIR/${ENV_NAME}_setup_${TIMESTAMP}.log"
    bash "$SCRIPT_DIR/setup-minio.sh" >> "$LOGS_DIR/${ENV_NAME}_setup_${TIMESTAMP}.log" 2>&1

    cd "$ENV_DIR"

    echo "--- terraform init ---" | tee -a "$LOG_FILE"
    terraform init >> "$LOG_FILE" 2>&1

    echo "--- terraform apply ---" | tee -a "$LOG_FILE"
    terraform apply -auto-approve -var-file=terraform.tfvars >> "$LOG_FILE" 2>&1

    echo "--- terraform output ---" | tee -a "$LOG_FILE"
    terraform output >> "$LOG_FILE" 2>&1

    echo ">>> Done! Log saved to $LOG_FILE"
    echo ">>> Container info:"
    terraform output
    ;;
  destroy)
    LOG_FILE="$LOGS_DIR/${ENV_NAME}_destroy_${TIMESTAMP}.log"
    echo ">>> Destroying '$ENV_NAME' environment... (log: $LOG_FILE)"

    echo "--- setup minio ---" | tee -a "$LOGS_DIR/${ENV_NAME}_setup_${TIMESTAMP}.log"
    bash "$SCRIPT_DIR/setup-minio.sh" >> "$LOGS_DIR/${ENV_NAME}_setup_${TIMESTAMP}.log" 2>&1

    cd "$ENV_DIR"

    echo "--- terraform init ---" | tee -a "$LOG_FILE"
    terraform init >> "$LOG_FILE" 2>&1

    echo "--- terraform destroy ---" | tee -a "$LOG_FILE"
    terraform destroy -auto-approve -var-file=terraform.tfvars >> "$LOG_FILE" 2>&1

    echo ">>> Done! Log saved to $LOG_FILE"
    ;;
  *)
    echo "Unknown action: $ACTION (use 'apply' or 'destroy')"
    exit 1
    ;;
esac
