#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Grant Compute + related roles to a service account (run as Owner)
# Authenticate with your USER account (not the deploy SA key), then:
#
#   export GCP_PROJECT_ID=tradetalkapp-492904
#   export GCP_IAM_MEMBER="serviceAccount:tradetalk-sa@tradetalkapp-492904.iam.gserviceaccount.com"
#   bash scripts/gcp-grant-compute-roles.sh
#
# Re-run is safe (GCP merges duplicate bindings).
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PROJECT="${GCP_PROJECT_ID:-tradetalkapp-492904}"
MEMBER="${GCP_IAM_MEMBER:-serviceAccount:tradetalk-sa@tradetalkapp-492904.iam.gserviceaccount.com}"

echo ""
echo "Binding IAM roles on $PROJECT for: $MEMBER"
echo "(must be project Owner or roles/resourcemanager.projectIamAdmin)"
echo ""

bind() {
    local role="$1"
    echo "  → $role"
    gcloud projects add-iam-policy-binding "$PROJECT" \
        --member="$MEMBER" \
        --role="$role" \
        --quiet
}

bind roles/compute.instanceAdmin.v1
bind roles/compute.networkAdmin
bind roles/iam.serviceAccountUser
bind roles/serviceusage.serviceUsageConsumer

echo ""
echo "✅ Done. Test with the SA key:"
echo "   gcloud auth activate-service-account --key-file=\"\$GOOGLE_APPLICATION_CREDENTIALS\""
echo "   bash scripts/gcp-credentials-doctor.sh"
echo ""
