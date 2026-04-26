#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Create a small Ubuntu VM for OpenClaw + Paperclip on GCP
# Run from your Mac (or any machine with gcloud installed and authenticated).
#
# If you keep the JSON key path in GOOGLE_APPLICATION_CREDENTIALS (e.g. in ~/.zshrc),
# run: gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
#
# Required:
#   export GCP_PROJECT_ID="your-project-id"
# Optional:
#   GCP_ZONE (default: us-central1-a)
#   GCP_VM_NAME (default: dreamrise-gcp)
#   GCP_MACHINE_TYPE (default: e2-micro)
#   GCP_BOOT_DISK_SIZE (default: 30GB)
#   GCP_NETWORK_TAG (default: dreamrise-gcp) — match your firewall target tags
#   GCP_ARCHIVE_DISK_GB — if set, adds a second PD (e.g. 50) for archive space
#   GCP_VM_SERVICE_ACCOUNT — email of a VM service account (for Secret Manager, etc.)
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

if [ -z "${GCP_PROJECT_ID:-}" ]; then
    echo "Set GCP_PROJECT_ID to your Google Cloud project id." >&2
    exit 1
fi

GCP_ZONE="${GCP_ZONE:-us-central1-a}"
GCP_VM_NAME="${GCP_VM_NAME:-dreamrise-gcp}"
GCP_MACHINE_TYPE="${GCP_MACHINE_TYPE:-e2-micro}"
GCP_BOOT_DISK_SIZE="${GCP_BOOT_DISK_SIZE:-30GB}"
GCP_NETWORK_TAG="${GCP_NETWORK_TAG:-dreamrise-gcp}"

echo ""
echo "☁️  Creating Compute Engine VM"
echo "    project=$GCP_PROJECT_ID zone=$GCP_ZONE name=$GCP_VM_NAME type=$GCP_MACHINE_TYPE"
echo ""

CREATE_ARGS=(
    compute instances create "$GCP_VM_NAME"
    --project="$GCP_PROJECT_ID"
    --zone="$GCP_ZONE"
    --machine-type="$GCP_MACHINE_TYPE"
    --network-interface=network-tier=PREMIUM,subnet=default
    --maintenance-policy=MIGRATE
    --provisioning-model=Standard
    --tags="$GCP_NETWORK_TAG"
    --image-family=ubuntu-2404-lts-amd64
    --image-project=ubuntu-os-cloud
    --boot-disk-size="$GCP_BOOT_DISK_SIZE"
    --boot-disk-type=pd-balanced
    --boot-disk-device-name="${GCP_VM_NAME}-boot"
    --shielded-secure-boot
    --shielded-vtpm
    --shielded-integrity-monitoring
)

if [ -n "${GCP_VM_SERVICE_ACCOUNT:-}" ]; then
    CREATE_ARGS+=(--service-account="$GCP_VM_SERVICE_ACCOUNT" --scopes=https://www.googleapis.com/auth/cloud-platform)
fi

if [ -n "${GCP_ARCHIVE_DISK_GB:-}" ]; then
    CREATE_ARGS+=(
        --create-disk="auto-delete=yes,name=${GCP_VM_NAME}-archive,size=${GCP_ARCHIVE_DISK_GB},type=pd-standard,mode=rw"
    )
    echo "    extra disk: ${GCP_VM_NAME}-archive (${GCP_ARCHIVE_DISK_GB} GB pd-standard)"
fi

gcloud "${CREATE_ARGS[@]}"

echo ""
echo "✅ Instance created."
echo ""
echo "SSH:"
echo "  gcloud compute ssh ubuntu@${GCP_VM_NAME} --zone=${GCP_ZONE} --project=${GCP_PROJECT_ID}"
echo ""
echo "Then copy scripts + service account JSON to the VM and run:"
echo "  gcloud compute scp --recurse --zone=${GCP_ZONE} --project=${GCP_PROJECT_ID} \\"
echo "    scripts/gcp-*.sh scripts/oci-*.sh ubuntu@${GCP_VM_NAME}:~/"
echo "  gcloud compute scp --zone=${GCP_ZONE} --project=${GCP_PROJECT_ID} \\"
echo "    \"\$GOOGLE_APPLICATION_CREDENTIALS\" ubuntu@${GCP_VM_NAME}:~/dreamrise-gcp-sa.json"
echo "  export GOOGLE_APPLICATION_CREDENTIALS=\$HOME/dreamrise-gcp-sa.json GOOGLE_API_KEY=... \\"
echo "    && bash ~/gcp-deploy-all.sh"
echo ""
echo "Firewall: create restricted rules for SSH (and optional Tailscale UDP);"
echo "see docs/10-gcp-deployment.md"
