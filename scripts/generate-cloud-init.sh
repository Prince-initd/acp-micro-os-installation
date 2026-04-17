#!/bin/bash
set -euo pipefail

SSH_KEY_PATH="${1:-$HOME/.ssh/swarm_key.pub}"
OUT_DIR="cloud-init-output"
TMP_DIR=$(mktemp -d)

mkdir -p "$OUT_DIR"

SSH_PUB_KEY=$(<"$SSH_KEY_PATH")

ISO_CMD=$(command -v mkisofs || echo "xorriso -as mkisofs")

generate_iso() {
    local NODE_NAME=$1

    echo "🔧 Generating cloud-init for $NODE_NAME"

    WORK_DIR=$(mktemp -d)

    export SSH_PUB_KEY
    export HOSTNAME="$NODE_NAME"
    export INSTANCE_ID="$NODE_NAME"

    envsubst < templates/user-data.tpl > "$WORK_DIR/user-data"
    envsubst < templates/meta-data.tpl > "$WORK_DIR/meta-data"

    $ISO_CMD \
        -o "$OUT_DIR/${NODE_NAME}.iso" \
        -V cidata \
        -J -r \
        "$WORK_DIR" > /dev/null 2>&1

    rm -rf "$WORK_DIR"

    echo "✅ Created $OUT_DIR/${NODE_NAME}.iso"
}

# Generate masters
while read -r node; do
    [[ -z "$node" ]] && continue
    generate_iso "$node"
done < inventory/masters.txt

# Generate workers
while IFS= read -r node || [[ -n "$node" ]]; do
    node=$(echo "$node" | tr -d '\r' | xargs)
    [[ -z "$node" ]] && continue
    generate_iso "$node"
done < inventory/workers.txt

echo "🚀 All cloud-init ISOs generated in $OUT_DIR"