#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Require GOOGLE_APPLICATION_CREDENTIALS for GCP app deploy
# Sourced by gcp-deploy-all.sh. Validates the JSON key exists on THIS machine
# (the VM), fixes permissions, and exports an absolute path for child scripts.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

if [ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]; then
    echo "Set GOOGLE_APPLICATION_CREDENTIALS to the absolute path of your" >&2
    echo "service account JSON on this host (copy the key to the VM first)." >&2
    exit 1
fi

if [[ "${GOOGLE_APPLICATION_CREDENTIALS}" != /* ]]; then
    echo "GOOGLE_APPLICATION_CREDENTIALS must be an absolute path (got: ${GOOGLE_APPLICATION_CREDENTIALS})" >&2
    exit 1
fi

if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Key file not found: $GOOGLE_APPLICATION_CREDENTIALS" >&2
    echo "Example from your Mac: gcloud compute scp --project=... --zone=... \\" >&2
    echo '  "$GOOGLE_APPLICATION_CREDENTIALS" ubuntu@VM:~/dreamrise-gcp-sa.json' >&2
    echo "Then on the VM: export GOOGLE_APPLICATION_CREDENTIALS=\$HOME/dreamrise-gcp-sa.json" >&2
    exit 1
fi

chmod 600 "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null || true
export GOOGLE_APPLICATION_CREDENTIALS
echo "  ✅ GOOGLE_APPLICATION_CREDENTIALS → $GOOGLE_APPLICATION_CREDENTIALS (ADC for apps)"
