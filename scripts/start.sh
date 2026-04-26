#!/bin/bash
# DreamRise — Start Paperclip Server with Gemini 3.1 Pro
# Usage: ./scripts/start.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PAPERCLIP_DIR="$REPO_DIR/paperclip"

# Ensure PATH includes node/pnpm/gemini
export PATH="$HOME/.npm-global/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

# Load API keys from .zshrc or set directly
source ~/.zshrc 2>/dev/null || true
export GEMINI_API_KEY="${GEMINI_API_KEY:-${GOOGLE_API_KEY:-}}"

echo "🏠 DreamRise — Starting Paperclip Server..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check prerequisites
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install Node.js v20+"
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm not found. Installing..."
    npm install -g pnpm
fi

if ! command -v gemini &> /dev/null; then
    echo "⚠️  Gemini CLI not found. Installing..."
    npm install -g @google/gemini-cli
fi

echo "✅ Node.js: $(node --version)"
echo "✅ pnpm: $(pnpm --version)"
echo "✅ Gemini CLI: $(gemini --version)"
echo "✅ GEMINI_API_KEY: ${GEMINI_API_KEY:+SET}"
echo ""

if [ -z "${GEMINI_API_KEY:-}" ]; then
    echo "❌ GEMINI_API_KEY not set. Export it or add GOOGLE_API_KEY to ~/.zshrc"
    exit 1
fi

# Start Paperclip
cd "$PAPERCLIP_DIR"
pnpm paperclipai run
