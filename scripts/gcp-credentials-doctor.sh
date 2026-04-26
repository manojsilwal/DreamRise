#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Sanity-check GOOGLE_APPLICATION_CREDENTIALS vs target GCP project
# Run before gcp-create-instance.sh. Reads JSON client_email + project_id (if present).
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

KEY="${GOOGLE_APPLICATION_CREDENTIALS:-}"
TARGET="${GCP_PROJECT_ID:-tradetalkapp-492904}"

echo ""
echo "🔎 DreamRise — GCP credentials doctor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -z "$KEY" ] || [ ! -f "$KEY" ]; then
    echo "❌ GOOGLE_APPLICATION_CREDENTIALS unset or not a file."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "⚠️  Install jq for JSON checks: brew install jq"
    exit 1
fi

EMAIL=$(jq -r '.client_email // empty' "$KEY")
SA_PROJECT=$(jq -r '.project_id // empty' "$KEY")

echo "  Key file:     $KEY"
echo "  client_email: $EMAIL"
echo "  project_id:   ${SA_PROJECT:-"(not in JSON — older key format)"}"
echo "  Target (GCP_PROJECT_ID): $TARGET"
echo ""

if [ -n "$SA_PROJECT" ] && [ "$SA_PROJECT" != "$TARGET" ]; then
    echo "⚠️  The JSON’s project_id ($SA_PROJECT) differs from GCP_PROJECT_ID ($TARGET)."
    echo "   The service account must be granted IAM on **$TARGET** (or use a key from that project)."
    echo ""
fi

if ! command -v gcloud &>/dev/null; then
    echo "❌ gcloud not found."
    exit 1
fi

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
gcloud auth activate-service-account --key-file="$KEY" --quiet 2>/dev/null || true
gcloud config set project "$TARGET" --quiet 2>/dev/null || true

echo "── gcloud identity ──"
gcloud config get-value account 2>/dev/null || true
echo ""

echo "── Compute Engine API (list instances) ──"
LIST_OUT=$(gcloud compute instances list --project="$TARGET" --limit=5 2>&1) || true
if echo "$LIST_OUT" | grep -qiE "SERVICE_DISABLED|has not been used|PERMISSION_DENIED|compute\.instances\.list|Some requests did not succeed"; then
    echo "  ❌ Compute list failed or missing IAM. Output:"
    echo "$LIST_OUT" | head -8
    echo ""
    echo "  Fixes:"
    echo "     1. Billing + enable Compute API (Console)."
    echo "     2. Grant this SA Compute roles (as Owner, user gcloud — not this key):"
    echo "        bash scripts/gcp-grant-compute-roles.sh"
    exit 1
fi
echo "  ✅ Compute API + list permission OK; listing:"
echo "$LIST_OUT" | head -12

echo ""
echo "✅ Preflight OK for project $TARGET"
echo ""
