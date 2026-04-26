#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Print Cloud Shell / Console env snippet (no secrets)
# Run locally: bash scripts/gcp-print-cloudshell-env.sh
# Copy the output into Google Cloud Shell after uploading your SA JSON to $HOME.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PID="${GCP_PROJECT_ID:-tradetalkapp-492904}"

echo ""
echo "=== Paste into Google Cloud Shell (after uploading dreamrise-gcp-sa.json to \$HOME) ==="
echo ""
cat <<'SNIP'
chmod 600 "$HOME/dreamrise-gcp-sa.json"
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/dreamrise-gcp-sa.json"
export GOOGLE_API_KEY="PASTE_YOUR_API_KEY_HERE"
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
SNIP
echo "gcloud config set project ${PID}"
echo ""
echo "Console links (project ${PID}):"
echo "  Credentials:  https://console.cloud.google.com/apis/credentials?project=${PID}"
echo "  Service accts: https://console.cloud.google.com/iam-admin/serviceaccounts?project=${PID}"
echo "  Cloud Shell:   https://shell.cloud.google.com/?cloudshell=true&show=terminal&project=${PID}"
echo ""
echo "See docs/10-gcp-deployment.md → “Same credentials in the Google Cloud Console”."
echo ""
