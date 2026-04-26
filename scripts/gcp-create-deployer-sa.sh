#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Create deployer service account + IAM (idempotent)
# Run from your Mac with gcloud authenticated as a **project Owner** or other
# identity that can create service accounts and set project IAM.
#
# Environment:
#   GCP_PROJECT_ID          (default: tradetalkapp-492904)
#   GCP_DEPLOY_SA_ACCOUNT   short id, default: dreamrise-gcp-deployer (set to e.g.
#                           gemini-deployer to attach IAM to an existing SA)
#   GCP_CREATE_DEPLOYER_KEY set to 1 to also create a JSON key at the path in
#                           GOOGLE_APPLICATION_CREDENTIALS (file must not exist)
#
# Does not enable billing or APIs — see docs/10-gcp-deployment.md
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-tradetalkapp-492904}"
SA_SHORT="${GCP_DEPLOY_SA_ACCOUNT:-dreamrise-gcp-deployer}"
SA_EMAIL="${SA_SHORT}@${PROJECT_ID}.iam.gserviceaccount.com"

echo ""
echo "☁️  DreamRise — ensure deployer service account"
echo "    project=$PROJECT_ID"
echo "    account=$SA_EMAIL"
echo ""

if ! gcloud iam service-accounts describe "$SA_EMAIL" --project="$PROJECT_ID" &>/dev/null; then
    echo "Creating service account ${SA_SHORT}..."
    gcloud iam service-accounts create "$SA_SHORT" \
        --project="$PROJECT_ID" \
        --display-name="DreamRise GCP deployer"
else
    echo "Service account already exists."
fi

bind_role() {
    local role="$1"
    echo "  IAM: ${role}"
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:${SA_EMAIL}" \
        --role="$role" \
        --quiet
}

echo ""
echo "Binding roles (safe to re-run; duplicates are merged by GCP)..."
bind_role roles/compute.instanceAdmin.v1
bind_role roles/iam.serviceAccountUser
bind_role roles/serviceusage.serviceUsageConsumer
bind_role roles/compute.networkAdmin

echo ""
if [ "${GCP_CREATE_DEPLOYER_KEY:-0}" = "1" ]; then
    KEY_PATH="${GOOGLE_APPLICATION_CREDENTIALS:-}"
    if [ -z "$KEY_PATH" ]; then
        echo "Set GOOGLE_APPLICATION_CREDENTIALS to the absolute path for the new key file." >&2
        exit 1
    fi
    if [ -e "$KEY_PATH" ]; then
        echo "Refusing to overwrite existing file: $KEY_PATH" >&2
        echo "Unset GCP_CREATE_DEPLOYER_KEY or choose an empty path." >&2
        exit 1
    fi
    mkdir -p "$(dirname "$KEY_PATH")"
    echo "Creating key at $KEY_PATH ..."
    gcloud iam service-accounts keys create "$KEY_PATH" \
        --iam-account="$SA_EMAIL" \
        --project="$PROJECT_ID"
    chmod 600 "$KEY_PATH" || true
    echo ""
    echo "Add to ~/.zshrc (example):"
    echo "  export GOOGLE_APPLICATION_CREDENTIALS=$KEY_PATH"
else
    echo "Skipping key creation (set GCP_CREATE_DEPLOYER_KEY=1 to create JSON at GOOGLE_APPLICATION_CREDENTIALS)."
fi

echo ""
echo "Authenticate gcloud (Mac):"
echo "  gcloud auth activate-service-account --key-file=\"\$GOOGLE_APPLICATION_CREDENTIALS\""
echo "  gcloud config set project $PROJECT_ID"
echo ""
