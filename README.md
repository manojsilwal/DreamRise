# 🏠 DreamRise — AI-Powered Real Estate Company

> A fully autonomous, no-human real estate company powered by [Paperclip](https://github.com/paperclipai/paperclip) AI agent orchestration.

## Vision

DreamRise is a real estate company where every employee is a specialized AI agent. Agents maintain long-term context, learn from past decisions, and operate autonomously within governance guardrails — all orchestrated through Paperclip's control plane.

## Architecture

```
┌─────────────────────────────────────────────┐
│            🏛️ Board Operator (You)           │
│        Strategic oversight & approvals       │
├─────────────────────────────────────────────┤
│              Paperclip Control Plane         │
│   Dashboard │ API │ Heartbeats │ Governance  │
├─────────────────────────────────────────────┤
│          DreamRise Digital Workforce          │
│                                             │
│  🤖 CEO ─── Strategic Vision & Planning     │
│    ├── 🤖 CTO ─── Tech & Data Architecture  │
│    │     ├── 🤖 Data Engineer ─── MLS/APIs  │
│    │     └── 🤖 Platform Engineer ─── Infra │
│    ├── 🤖 Head of Sales ─── Lead Pipeline   │
│    │     └── 🤖 Sales Agent ─── Outreach    │
│    ├── 🤖 Market Analyst ─── Research       │
│    └── 🤖 Content Strategist ─── Marketing  │
└─────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites
- **Node.js** v20+ (currently v22.16.0)
- **pnpm** v9.15+ (install: `npm install -g pnpm`)

### Start Paperclip
```bash
cd paperclip
pnpm install
pnpm paperclipai run
```

Dashboard opens at: **http://localhost:3100**

### What's Next
1. Create the "DreamRise" company in the dashboard
2. Define the company goal
3. Create the CEO agent and configure its adapter
4. Build out the org chart with specialized real estate agents
5. Set budgets and assign initial tasks
6. Hit go — agents start their heartbeats and the company runs

## Documentation

See the [docs/](./docs/) directory for complete documentation:

| Doc | Description |
|-----|-------------|
| [What is Paperclip?](./docs/01-what-is-paperclip.md) | Platform overview |
| [Quickstart](./docs/02-quickstart.md) | Setup guide |
| [Core Concepts](./docs/03-core-concepts.md) | Company, Agents, Issues, Heartbeats |
| [Architecture](./docs/04-architecture.md) | Technical stack & design |
| [Adapters](./docs/05-adapters.md) | Agent runtime adapters |
| [CLI Reference](./docs/06-cli-reference.md) | Command-line interface |
| [API Reference](./docs/07-api-reference.md) | REST API endpoints |
| [Company Design](./docs/08-company-design.md) | **DreamRise org blueprint** |
| [GCP deployment](./docs/10-gcp-deployment.md) | OpenClaw + Paperclip on Compute Engine (archive VM) |

## Repository Structure

```
DreamRise/
├── paperclip/           # Paperclip platform (git submodule)
├── docs/                # Organized documentation
├── config/              # Company & agent configurations
│   └── agents/          # Individual agent configs
├── scripts/             # Utility scripts
└── README.md            # This file
```

## License

DreamRise company configuration and documentation. Paperclip is licensed under its own terms — see [paperclip/LICENSE](./paperclip/LICENSE).
