# Architecture

## Stack Overview

```
┌─────────────────────────────────────┐
│         React UI (Vite)             │
│  Dashboard, org management, tasks   │
├─────────────────────────────────────┤
│    Express.js REST API (Node.js)    │
│  Routes, services, auth, adapters   │
├─────────────────────────────────────┤
│     PostgreSQL (Drizzle ORM)        │
│  Schema, migrations, embedded mode  │
├─────────────────────────────────────┤
│           Adapters                  │
│  Claude, Codex, Gemini, Cursor,     │
│  OpenCode, OpenClaw, Hermes,        │
│  Process, HTTP                      │
└─────────────────────────────────────┘
```

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React + Vite | Dashboard UI |
| Backend | Express.js (Node.js) | REST API |
| Database | PostgreSQL (Drizzle ORM) | Data persistence |
| Adapters | Plugin architecture | Agent execution bridges |
| CLI | Node.js | Setup & control commands |

## Repository Structure

```
paperclip/
├── ui/                          # React frontend
│   ├── src/pages/               # Route pages
│   ├── src/components/          # React components
│   ├── src/api/                 # API client
│   └── src/context/             # React context providers
│
├── server/                      # Express.js API
│   ├── src/routes/              # REST endpoints
│   ├── src/services/            # Business logic
│   ├── src/adapters/            # Agent execution adapters
│   └── src/middleware/          # Auth, logging
│
├── packages/
│   ├── db/                      # Drizzle schema + migrations
│   ├── shared/                  # API types, constants, validators
│   ├── adapter-utils/           # Adapter interfaces and helpers
│   └── adapters/
│       ├── claude-local/        # Claude Code adapter
│       ├── codex-local/         # OpenAI Codex adapter
│       ├── gemini-local/        # Gemini CLI adapter
│       ├── cursor-local/        # Cursor CLI adapter
│       ├── opencode-local/      # OpenCode CLI adapter
│       └── openclaw-gateway/    # OpenClaw gateway adapter
│
├── skills/                      # Agent skills
│   └── paperclip/               # Core Paperclip skill (heartbeat protocol)
│
├── cli/                         # CLI client
│   └── src/                     # Setup and control-plane commands
│
└── doc/                         # Internal documentation
```

## Request Flow

When a heartbeat triggers an agent:

1. **Trigger** — Scheduler, manual invoke, or event (assignment, mention) triggers a heartbeat
2. **Adapter invocation** — Server calls the configured adapter's `execute()` function
3. **Agent process** — Adapter spawns the agent (e.g., Claude Code CLI) with Paperclip env vars and a prompt
4. **Agent work** — The agent calls Paperclip's REST API to check assignments, checkout tasks, do work, and update status
5. **Result capture** — Adapter captures stdout, parses usage/cost data, extracts session state
6. **Run record** — Server records the run result, costs, and any session state for next heartbeat

## Adapter Model

Each adapter has three modules:

| Module | Location | Purpose |
|--------|----------|---------|
| **Server** | `server/execute.ts` | Core `execute()` function + env diagnostics |
| **UI** | `ui/parse-stdout.ts` | Stdout parser for run viewer + config form |
| **CLI** | `cli/format-event.ts` | Terminal formatter for `paperclipai run --watch` |

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Control plane, not execution plane** | Paperclip orchestrates agents; it doesn't run them |
| **Company-scoped** | All entities belong to exactly one company; strict data boundaries |
| **Single-assignee tasks** | Atomic checkout prevents concurrent work on the same task |
| **Adapter-agnostic** | Any runtime that can call an HTTP API works as an agent |
| **Embedded by default** | Zero-config local mode with embedded PostgreSQL |
