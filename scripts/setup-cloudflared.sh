#!/bin/bash
# Setup cloudflared tunnel as a systemd service
pkill -f cloudflared 2>/dev/null
sleep 2

cat > /tmp/cloudflared-tradetalk.service <<SVCEOF
[Unit]
Description=Cloudflare Tunnel for TradeTalk Backend
After=docker.service

[Service]
Type=simple
Restart=always
RestartSec=10
ExecStart=/usr/bin/cloudflared tunnel --url http://localhost:5050 --no-autoupdate

[Install]
WantedBy=multi-user.target
SVCEOF

sudo mv /tmp/cloudflared-tradetalk.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cloudflared-tradetalk
sudo systemctl start cloudflared-tradetalk
sleep 10
sudo journalctl -u cloudflared-tradetalk --no-pager -n 20 | grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' | tail -1
