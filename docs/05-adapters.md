# Adapters Guide

Adapters are the bridge between Paperclip's control plane and the actual AI agent runtimes. They handle spawning agents, passing context, and capturing results.

## How Adapters Work

When Paperclip triggers a heartbeat:

1. Looks up the agent's `adapterType` and `adapterConfig`
2. Calls the adapter's `execute()` function with the execution context
3. The adapter spawns or calls the agent runtime
4. The adapter captures stdout, parses usage/cost data, and returns a structured result

## Built-in Adapters

| Adapter | Type Key | Best For |
|---------|----------|----------|
| **Claude Local** | `claude_local` | Coding agents using Anthropic's Claude Code CLI |
| **Codex Local** | `codex_local` | Coding agents using OpenAI's Codex CLI |
| **Gemini Local** | `gemini_local` | Coding/research agents using Google's Gemini CLI |
| **OpenCode Local** | `opencode_local` | Agents using OpenCode with any `provider/model` |
| **Cursor** | `cursor` | Agents using Cursor editor's AI |
| **OpenClaw Gateway** | `openclaw_gateway` | Agents via OpenClaw gateway |
| **Hermes Local** | `hermes_local` | Hermes runtime agents |
| **Pi Local** | `pi_local` | Pi runtime agents |
| **Process** | `process` | Run any shell script or command |
| **HTTP** | `http` | Call external services via HTTP |

## Adapter Architecture

Each adapter follows this directory structure:

```
packages/adapters/<name>/
  src/
    index.ts           # Shared metadata (type, label, models)
    server/
      execute.ts       # Core execution logic
      parse.ts         # Output parsing
      test.ts          # Environment diagnostics
    ui/
      parse-stdout.ts  # Stdout → transcript entries for run viewer
      build-config.ts  # Form values → adapterConfig JSON
    cli/
      format-event.ts  # Terminal output for `paperclipai run --watch`
```

## Choosing an Adapter

| Need | Recommended Adapter |
|------|-------------------|
| A coding agent | `claude_local`, `codex_local`, `gemini_local`, or `opencode_local` |
| Run a script or command | `process` |
| Call an external service | `http` |
| Something custom | [Create your own adapter](https://docs.paperclip.ing/adapters/creating-an-adapter) |

## For DreamRise Real Estate Company

Recommended adapter assignments:

| Agent Role | Adapter | Reasoning |
|------------|---------|-----------|
| CEO | `claude_local` | Best at strategic reasoning and planning |
| CTO | `claude_local` | Strong at architecture and code review |
| Data Engineer | `codex_local` or `gemini_local` | Good at data pipeline code |
| Platform Engineer | `claude_local` or `codex_local` | Infrastructure code |
| Market Analyst | `gemini_local` | Excellent at research & analysis |
| Head of Sales | `claude_local` | Communication, outreach drafting |
| Sales Agent | `http` or `process` | Can integrate with CRM APIs |
| Content Strategist | `gemini_local` | Content creation, SEO |
