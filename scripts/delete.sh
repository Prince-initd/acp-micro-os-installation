#!/bin/bash
set -euo pipefail

# -----------------------------
# Defaults
# -----------------------------
S3_BUCKET=""
S3_REGION=""
S3_ENDPOINT=""
S3_ACCESS_KEY=""
S3_SECRET_KEY=""
STATE_KEY="terraform.tfstate"

# -----------------------------
# Logging
# -----------------------------
log() {
  local level="$1"; shift
  local ts
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "[$ts] [$level] $*"
}

# -----------------------------
# Usage
# -----------------------------
usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -b, --s3-bucket BUCKET      S3 bucket for Terraform state
  -r, --s3-region REGION     S3 region
  -e, --s3-endpoint URL      S3 / MinIO endpoint
  -a, --s3-access-key KEY    S3 access key
  -s, --s3-secret-key KEY    S3 secret key
  -k, --state-key KEY        Terraform state object key (default: terraform.tfstate)
  --help                     Show this help message
EOF
}

# -----------------------------
# Argument parsing
# -----------------------------
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--s3-bucket)      S3_BUCKET="$2"; shift 2 ;;
      -r|--s3-region)     S3_REGION="$2"; shift 2 ;;
      -e|--s3-endpoint)   S3_ENDPOINT="$2"; shift 2 ;;
      -a|--s3-access-key) S3_ACCESS_KEY="$2"; shift 2 ;;
      -s|--s3-secret-key) S3_SECRET_KEY="$2"; shift 2 ;;
      -k|--state-key)     STATE_KEY="$2"; shift 2 ;;
      --help)             usage; exit 0 ;;
      *)
        log ERROR "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
}

# -----------------------------
# Terraform backend init
# -----------------------------
terraform_backend_init() {
  log INFO "Initializing Terraform..."

  if [[ -n "$S3_BUCKET" && -n "$S3_REGION" && -n "$S3_ENDPOINT" ]]; then
    log INFO "Using S3 backend for Terraform state"

    export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY"
    export AWS_ENDPOINT_URL_S3="$S3_ENDPOINT"
    export AWS_S3_FORCE_PATH_STYLE=true
    export AWS_EC2_METADATA_DISABLED=true

    terraform init -upgrade -reconfigure \
      -backend-config="bucket=${S3_BUCKET}" \
      -backend-config="key=${STATE_KEY}" \
      -backend-config="region=${S3_REGION}" \
      -backend-config="use_path_style=true" \
      -backend-config="skip_credentials_validation=true" \
      -backend-config="skip_metadata_api_check=true" \
      -backend-config="skip_region_validation=true" \
      -backend-config="skip_requesting_account_id=true"
  else
    log INFO "Using local Terraform state"
    terraform init -upgrade
  fi
}

# -----------------------------
# Main
# -----------------------------
main() {
  parse_arguments "$@"

  terraform_backend_init

  log WARN "Destroying Terraform-managed infrastructure..."
  terraform destroy -auto-approve

  log SUCCESS "Infrastructure destroyed successfully"
}

main "$@"
