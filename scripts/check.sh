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
  echo "[$ts] [$level] $*"
}


# -----------------------------
# Environment diagnostics
# -----------------------------
log INFO "Checking environment variables"

check_env() {
  local name="$1"
  local value="${!name:-}"

  if [[ -z "$value" ]]; then
    log WARNING "$name is NOT set"
  else
    case "$name" in
      *SECRET*|*KEY*)
        log INFO "$name is set (hidden)"
        ;;
      *)
        log INFO "$name=$value"
        ;;
    esac
  fi
}

# -----------------------------
# Usage
# -----------------------------
usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -b, --s3-bucket BUCKET
  -r, --s3-region REGION
  -e, --s3-endpoint URL
  -a, --s3-access-key KEY
  -s, --s3-secret-key KEY
  -k, --state-key KEY

Examples:
  ./scripts/check.sh
  ./scripts/check.sh -b tf-state -r us-east-1 -e http://minio:9000
EOF
}

# -----------------------------
# Argument parsing
# -----------------------------
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--s3-bucket)     S3_BUCKET="$2"; shift 2 ;;
      -r|--s3-region)    S3_REGION="$2"; shift 2 ;;
      -e|--s3-endpoint)  S3_ENDPOINT="$2"; shift 2 ;;
      -a|--s3-access-key) S3_ACCESS_KEY="$2"; shift 2 ;;
      -s|--s3-secret-key) S3_SECRET_KEY="$2"; shift 2 ;;
      -k|--state-key)    STATE_KEY="$2"; shift 2 ;;
      --help)            usage; exit 0 ;;
      *)
        log ERROR "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
}

# -----------------------------
# Terraform init
# -----------------------------
terraform_init() {
  log INFO "Initializing Terraform (check mode)"

  if [[ -n "$S3_BUCKET" && -n "$S3_REGION" && -n "$S3_ENDPOINT" ]]; then
    log INFO "Using S3 backend"

    export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY"
    export AWS_ENDPOINT_URL_S3="$S3_ENDPOINT"
    export AWS_S3_FORCE_PATH_STYLE=true
    export AWS_EC2_METADATA_DISABLED=true
    export TF_VAR_admin_user="${SSH_USER:-admin}"
    export TF_VAR_remote_host="$JUMP_HOST"
    export TF_VAR_ssh_private_key="$JUMP_KEY"
    export TF_VAR_root_password="${ROOT_PASSWORD:-opensuse123}"
    export TF_VAR_student_password="${STUDENT_PASSWORD:-student123}"

    # Core AWS / S3 vars
    check_env S3_BUCKET
    check_env S3_REGION
    check_env S3_ENDPOINT
    check_env S3_ACCESS_KEY
    check_env S3_SECRET_KEY
    check_env STATE_KEY

    # AWS SDK behavior flags
    check_env AWS_ENDPOINT_URL_S3
    check_env AWS_S3_FORCE_PATH_STYLE
    check_env AWS_EC2_METADATA_DISABLED

    # Terraform automation flags
    check_env TF_IN_AUTOMATION
    check_env TF_INPUT
    
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
    terraform init -upgrade -reconfigure
  fi
}

# -----------------------------
# Main
# -----------------------------
main() {
  parse_arguments "$@"

  terraform_init

  log INFO "Running terraform plan"
  terraform plan -input=false -no-color

  log SUCCESS "Terraform plan completed successfully"
}

main "$@"
