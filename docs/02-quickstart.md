# Quickstart Guide

## Prerequisites

| Requirement | Minimum Version | Check Command |
|------------|----------------|---------------|
| Node.js | v20+ | `node --version` |
| pnpm | v9.15+ | `pnpm --version` |

### Install pnpm (if not already installed)
```bash
npm install -g pnpm
```

## Quick Start (Recommended)

### One-Command Bootstrap
```bash
cd paperclip
pnpm paperclipai onboard --yes    # Accept all defaults
pnpm paperclipai run              # Start the server
```

This will:
1. Auto-configure with defaults (embedded PostgreSQL, local disk, default secrets)
2. Run `paperclipai doctor` to verify everything
3. Start the server at **http://localhost:3100**

### Interactive Setup
```bash
pnpm paperclipai onboard          # Choose your own settings
```

Options:
- **Quickstart** — local defaults (embedded database, no LLM provider, local disk storage)
- **Advanced setup** — full interactive configuration

## Local Development

```bash
pnpm install
pnpm dev
```

Dashboard available at: http://localhost:3100

## What's Next

1. **Create your first company** in the web UI
2. **Define a company goal** — the north star all agents align to
3. **Create a CEO agent** and configure its adapter
4. **Build out the org chart** with more agents
5. **Set budgets** and assign initial tasks
6. **Hit go** — agents start their heartbeats and the company runs

## Troubleshooting

```bash
# Run diagnostics
pnpm paperclipai doctor

# Auto-repair common issues
pnpm paperclipai doctor --repair

# Reconfigure settings
pnpm paperclipai configure --section server
pnpm paperclipai configure --section secrets
pnpm paperclipai configure --section storage
```

## Local Storage Paths

| Path | Purpose |
|------|---------|
| `~/.paperclip/instances/default/config.json` | Configuration |
| `~/.paperclip/instances/default/db` | Embedded PostgreSQL data |
| `~/.paperclip/instances/default/logs` | Application logs |
| `~/.paperclip/instances/default/data/storage` | File storage |
| `~/.paperclip/instances/default/secrets/master.key` | Encryption key |

### Custom Data Directory
```bash
pnpm paperclipai run --data-dir ./tmp/paperclip-dev
```

### Named Instances
```bash
PAPERCLIP_INSTANCE_ID=dev pnpm paperclipai run
```
