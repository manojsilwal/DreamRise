#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Configure Telegram on the GCP VM using TELEGRAM_BOT_TOKEN
#
# Reads TELEGRAM_BOT_TOKEN from the current environment. If it is unset, tries
# a login zsh (so a line in ~/.zshrc like: export TELEGRAM_BOT_TOKEN="..." is picked up).
#
# Usage (from your Mac, repo root or scripts/):
#   source ~/.zshrc    # if your token is only in zshrc and this shell is bash
#   bash scripts/gcp-run-telegram-on-vm.sh
#
# Requires: gcloud, oci-telegram.sh already on the VM (e.g. ~/oci-telegram.sh).
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

GCP_PROJECT_ID="${GCP_PROJECT_ID:-tradetalkapp-492904}"
GCP_ZONE="${GCP_ZONE:-us-central1-a}"
GCP_VM_NAME="${GCP_VM_NAME:-dreamrise-gcp}"

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] && command -v zsh >/dev/null 2>&1; then
  TELEGRAM_BOT_TOKEN="$(zsh -lic 'echo -n "${TELEGRAM_BOT_TOKEN:-}"' 2>/dev/null || true)"
fi

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
  echo "TELEGRAM_BOT_TOKEN is empty." >&2
  echo "Add to ~/.zshrc:  export TELEGRAM_BOT_TOKEN=\"...\"" >&2
  echo "Then run:  source ~/.zshrc && bash $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TG_B64="$(printf '%s' "$TELEGRAM_BOT_TOKEN" | base64 | tr -d '\n')"

echo "→ Ensuring oci-telegram.sh on ${GCP_VM_NAME}..."
gcloud compute scp "${SCRIPT_DIR}/oci-telegram.sh" "${GCP_VM_NAME}:~/" \
  --zone="$GCP_ZONE" --project="$GCP_PROJECT_ID" --quiet

echo "→ Running oci-telegram.sh on the VM..."
gcloud compute ssh "$GCP_VM_NAME" --zone="$GCP_ZONE" --project="$GCP_PROJECT_ID" \
  --command="export TELEGRAM_BOT_TOKEN=\$(printf '%s' '$TG_B64' | base64 -d) && export PATH=\"\$HOME/.npm-global/bin:\$HOME/.local/bin:\$HOME/.openclaw/bin:\$PATH\" && bash ~/oci-telegram.sh"

echo ""
echo "On the VM, finish pairing (after you message the bot):"
echo "  openclaw pairing list telegram"
echo "  openclaw pairing approve telegram <CODE>"
