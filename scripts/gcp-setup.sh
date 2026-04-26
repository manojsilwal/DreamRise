#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — GCP Phase 1: VM prerequisites (delegates to shared oci-setup.sh)
# Run ON the Compute Engine VM (Ubuntu 24.04) after SSH.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo ""
echo "☁️  DreamRise — GCP archive VM: Phase 1 (shared stack setup)"
echo "   (Node 22, pnpm, build tools, hostname dreamrise, user linger)"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/oci-setup.sh"
