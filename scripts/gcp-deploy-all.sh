#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Master deploy on a GCP Compute Engine VM
# Run ON the VM after copying gcp-*.sh and oci-*.sh into ~/.
#
# Usage (on the VM):
#   export GOOGLE_APPLICATION_CREDENTIALS="$HOME/dreamrise-gcp-sa.json"  # absolute path; copy JSON first
#   export GOOGLE_API_KEY="..."   # from ~/.zshrc (same project as ADC); GEMINI_API_KEY is optional alias
#   export TELEGRAM_BOT_TOKEN="your-token"   # optional; oci-telegram.sh may prompt
#   bash gcp-deploy-all.sh
#
# Oracle-only step oci-lockdown-vcn.sh is NOT used. Harden GCP firewall instead;
# see docs/10-gcp-deployment.md
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=gcp-require-app-credentials.sh
source "$SCRIPT_DIR/gcp-require-app-credentials.sh"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║   DreamRise — GCP archive VM — OpenClaw + Paperclip             ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

echo "🔍 Preflight checks..."

if [ -z "${GEMINI_API_KEY:-}" ] && [ -z "${GOOGLE_API_KEY:-}" ]; then
    echo ""
    echo "  ⚠️  GOOGLE_API_KEY / GEMINI_API_KEY not set."
    read -r -p "  Paste your Google API key (same as GOOGLE_API_KEY in .zshrc): " GOOGLE_API_KEY
    export GOOGLE_API_KEY
    export GEMINI_API_KEY="$GOOGLE_API_KEY"
fi

if [ -z "${GEMINI_API_KEY:-}" ] && [ -n "${GOOGLE_API_KEY:-}" ]; then
    export GEMINI_API_KEY="$GOOGLE_API_KEY"
fi
if [ -z "${GOOGLE_API_KEY:-}" ] && [ -n "${GEMINI_API_KEY:-}" ]; then
    export GOOGLE_API_KEY="$GEMINI_API_KEY"
fi

echo "  ✅ GOOGLE_API_KEY / GEMINI_API_KEY: set"
echo "  ✅ GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
echo "  ✅ Architecture: $(uname -m)"
echo ""

echo "═══════════════════════════════════════════"
echo " Phase 1/6: System Setup (GCP entrypoint)"
echo "═══════════════════════════════════════════"
bash "$SCRIPT_DIR/gcp-setup.sh"
echo ""

echo "═══════════════════════════════════════════"
echo " Phase 2/6: Tailscale VPN"
echo "═══════════════════════════════════════════"
bash "$SCRIPT_DIR/oci-tailscale.sh"
echo ""

echo "═══════════════════════════════════════════"
echo " Phase 3/6: OpenClaw Gateway"
echo "═══════════════════════════════════════════"
bash "$SCRIPT_DIR/oci-openclaw.sh"
echo ""

echo "═══════════════════════════════════════════"
echo " Phase 4/6: Telegram Channel"
echo "═══════════════════════════════════════════"
bash "$SCRIPT_DIR/oci-telegram.sh"
echo ""

echo "═══════════════════════════════════════════"
echo " Phase 5/6: Paperclip Orchestrator"
echo "═══════════════════════════════════════════"
bash "$SCRIPT_DIR/oci-paperclip.sh"
echo ""

echo "═══════════════════════════════════════════"
echo " Phase 6/6: DreamRise Company"
echo "═══════════════════════════════════════════"
bash "$SCRIPT_DIR/oci-create-company.sh"
echo ""

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║   DreamRise GCP deployment finished.                            ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "  Services:"
echo "    OpenClaw Gateway:  http://localhost:18789"
echo "    Paperclip UI:      http://localhost:3100"
echo ""
echo "  Tailscale:"
echo "    http://dreamrise:3100"
echo "    http://dreamrise:18789"
echo ""
echo "  GCP next steps (from your Mac):"
echo "    • Confirm firewall: no public ingress on 3100 / 18789"
echo "    • docs/10-gcp-deployment.md"
echo ""
echo "  Verify on this VM:"
echo "    bash $SCRIPT_DIR/gcp-verify.sh"
echo ""
echo "  (Ignore oci-create-company hint about oci-lockdown-vcn — that is Oracle-only.)"
echo ""
