#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Print Console URLs to enable APIs (first-time project setup)
# Run when gcloud reports SERVICE_DISABLED for compute.googleapis.com or similar.
# A project Owner must click through in a browser once; the service account used
# for deploy often cannot enable APIs until Service Usage is active.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PID="${GCP_PROJECT_ID:-tradetalkapp-492904}"
PNUM="${GCP_PROJECT_NUMBER:-933081724691}"

echo ""
echo "Project: $PID (number $PNUM)"
echo ""
echo "If Compute Engine API cannot be enabled until billing is on:"
echo "  Link a billing account (payment method on file; Always Free may still be \$0):"
echo "    https://console.cloud.google.com/billing?project=${PID}"
echo ""
echo "Then enable these APIs (click Enable, wait 2–5 minutes, retry gcp-create-instance.sh):"
echo ""
echo "  Compute Engine:"
echo "    https://console.developers.google.com/apis/api/compute.googleapis.com/overview?project=${PID}"
echo ""
echo "  Service Usage (often needed before gcloud services enable works):"
echo "    https://console.developers.google.com/apis/api/serviceusage.googleapis.com/overview?project=${PNUM}"
echo ""
echo "  Cloud Resource Manager:"
echo "    https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview?project=${PNUM}"
echo ""
