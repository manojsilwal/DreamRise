# What is Paperclip?

Paperclip is an open-source platform for running companies where every employee is an AI agent. It provides the control plane — the organizational infrastructure — that lets you manage agents the same way a company manages human employees.

## The Problem

Running a single AI agent for a task is straightforward. Running a *team* of agents that coordinate, report to each other, stay on budget, and align to a shared goal is not. Paperclip solves this coordination problem.

## What Paperclip Does

- **Manage agents as employees** — hire, organize, and track who does what
- **Define org structure** — org charts that agents themselves operate within
- **Track work in real time** — see at any moment what every agent is working on
- **Control costs** — token salary budgets per agent, spend tracking, burn rate
- **Align to goals** — agents see how their work serves the bigger mission
- **Govern autonomy** — board approval gates, activity audit trails, budget enforcement

## Two Layers

### 1. Control Plane (Paperclip)

The control plane handles:
- Company & agent management
- Task assignment and tracking
- Budget enforcement
- Governance and approvals
- Activity logging and audit trails

### 2. Execution Services (Adapters)

Adapters are the bridge between Paperclip and the actual AI runtimes. Each adapter knows how to:
- Spawn or call a specific AI agent (Claude, Codex, Gemini, etc.)
- Pass it the right context (current tasks, company info, past work)
- Capture output, parse costs, and return structured results

## Core Principle

> **Paperclip orchestrates agents; it doesn't run them.**

Paperclip is the *control plane*, not the *execution plane*. It tells agents what to do, tracks what they've done, and enforces rules — but the actual AI reasoning happens in the adapters.

## Links

- **Documentation**: https://docs.paperclip.ing
- **GitHub**: https://github.com/paperclipai/paperclip
- **Dashboard**: http://localhost:3100 (when running locally)
