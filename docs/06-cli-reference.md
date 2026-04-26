# CLI Reference

The Paperclip CLI (`paperclipai`) is the primary tool for setup, diagnostics, and control-plane operations.

## Usage

```bash
pnpm paperclipai --help
```

## Global Options

| Option | Description |
|--------|-------------|
| `--data-dir <path>` | Override data directory (default: `~/.paperclip`) |
| `--api-base <url>` | API server URL |
| `--api-key <token>` | Authentication token |
| `--context <path>` | Context file path |
| `--profile <name>` | Named profile to use |
| `--json` | Output in JSON format |
| `--company-id <id>` | Target company ID |

## Setup Commands

### `paperclipai run`

Start the Paperclip server. This is the main entry point:

```bash
pnpm paperclipai run
pnpm paperclipai run --instance dev
```

Automatically:
1. Auto-onboards if config is missing
2. Runs `paperclipai doctor` with repair enabled
3. Starts the server when checks pass

### `paperclipai onboard`

First-time setup wizard:

```bash
pnpm paperclipai onboard          # Interactive
pnpm paperclipai onboard --yes    # Accept all defaults
pnpm paperclipai onboard --run    # Onboard and start server
```

Options:
- **Quickstart** — embedded DB, no LLM provider, local disk storage
- **Advanced** — full interactive configuration

### `paperclipai doctor`

Health check and diagnostics:

```bash
pnpm paperclipai doctor
pnpm paperclipai doctor --repair
```

Checks: server config, database, secrets adapter, storage, missing key files.

### `paperclipai configure`

Modify configuration sections:

```bash
pnpm paperclipai configure --section server
pnpm paperclipai configure --section secrets
pnpm paperclipai configure --section storage
```

### `paperclipai env`

Display current environment variables:

```bash
pnpm paperclipai env
```

### `paperclipai allowed-hostname`

Add a trusted hostname (for Tailscale/network access):

```bash
pnpm paperclipai allowed-hostname my-tailscale-host
```

## Context Profiles

Manage connection profiles for different environments:

```bash
# Set defaults
pnpm paperclipai context set --api-base http://localhost:3100 --company-id <id>

# View current context
pnpm paperclipai context show

# List profiles
pnpm paperclipai context list

# Switch profile
pnpm paperclipai context use default

# Set API key via env var
pnpm paperclipai context set --api-key-env-var-name PAPERCLIP_API_KEY
export PAPERCLIP_API_KEY=...
```

Context stored at: `~/.paperclip/context.json`

## Control-Plane Commands

For managing issues, agents, approvals, and activity — see the [Paperclip CLI docs](https://docs.paperclip.ing/cli/control-plane-commands).

## Local Storage Paths

| Path | Purpose |
|------|---------|
| `~/.paperclip/instances/default/config.json` | Instance config |
| `~/.paperclip/instances/default/db` | Embedded PostgreSQL |
| `~/.paperclip/instances/default/logs` | Server logs |
| `~/.paperclip/instances/default/data/storage` | File storage |
| `~/.paperclip/instances/default/secrets/master.key` | Encryption key |

### Custom Paths
```bash
PAPERCLIP_HOME=/custom/home PAPERCLIP_INSTANCE_ID=dev pnpm paperclipai run
pnpm paperclipai run --data-dir ./tmp/paperclip-dev
```
