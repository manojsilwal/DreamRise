#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# DreamRise — Post-deploy checks for GCP (and any) VM
# Run ON the VM after gcp-deploy-all.sh. Optionally checks GCP firewall from a
# workstation with gcloud + project access (see bottom).
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo ""
echo "🔎 DreamRise — deploy verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FAIL=0

echo ""
echo "── Local Paperclip (http://localhost:3100/api/health) ──"
if curl -sf --max-time 5 http://localhost:3100/api/health >/dev/null; then
    echo "  ✅ Paperclip health OK"
else
    echo "  ❌ Paperclip health failed (is paperclip.service running?)"
    FAIL=1
fi

echo ""
echo "── Local OpenClaw gateway (http://127.0.0.1:18789) ──"
code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:18789/ || echo "000")
if [[ "$code" =~ ^(200|401|403|404)$ ]]; then
    echo "  ✅ OpenClaw responded (HTTP $code — token/auth may be required for full use)"
else
    echo "  ⚠️  OpenClaw HTTP $code (expected some response if gateway is up)"
    if [[ "$code" == "000" ]]; then FAIL=1; fi
fi

echo ""
echo "── User systemd units ──"
systemctl --user is-active openclaw-gateway.service &>/dev/null && echo "  ✅ openclaw-gateway: active" || { echo "  ❌ openclaw-gateway: not active"; FAIL=1; }
systemctl --user is-active paperclip.service &>/dev/null && echo "  ✅ paperclip: active" || { echo "  ❌ paperclip: not active"; FAIL=1; }

echo ""
echo "── Tailscale (optional) ──"
if command -v tailscale &>/dev/null; then
    tailscale status 2>/dev/null | head -8 || echo "  ⚠️  tailscale status unavailable"
else
    echo "  (tailscale not installed)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FAIL" -eq 0 ]; then
    echo "✅ Local verification passed."
else
    echo "❌ One or more local checks failed — see journalctl:"
    echo "   journalctl --user -u paperclip.service -n 80 --no-pager"
    echo "   journalctl --user -u openclaw-gateway.service -n 80 --no-pager"
    exit 1
fi

echo ""
echo "── GCP firewall (run on your Mac with gcloud configured) ──"
echo "  Ensure no rule exposes tcp:3100 or tcp:18789 to the world."
echo "  Example (set GCP_PROJECT_ID to override default):"
_proj="${GCP_PROJECT_ID:-tradetalkapp-492904}"
echo "    gcloud compute firewall-rules list --project=${_proj} \\"
echo "      --filter='direction:INGRESS' --format='table(name,allowed.map().ports.list():label=PORTS,sourceRanges.list():label=SRC)'"
echo ""
