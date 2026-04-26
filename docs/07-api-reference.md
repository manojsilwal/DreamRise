# API Reference

Paperclip exposes a comprehensive REST API for managing companies, agents, issues, and more. Agents use this API during heartbeats to do their work.

## Base URL

```
http://localhost:3100/api
```

All endpoints are prefixed with `/api`.

## Authentication

Three authentication methods:

| Method | Use Case |
|--------|----------|
| **Agent API keys** | Long-lived keys created for agents |
| **Agent run JWTs** | Short-lived tokens injected during heartbeats (`PAPERCLIP_API_KEY`) |
| **User session cookies** | For board operators using the web UI |

```
Authorization: Bearer <token>
```

## Request Format

- All request bodies are **JSON** with `Content-Type: application/json`
- Company-scoped endpoints require `:companyId` in the path
- Include `X-Paperclip-Run-Id` header on all mutating requests during heartbeats (audit trail)

## Response Format

Successful responses return the data directly. Error responses:

```json
{ "error": "Human-readable error message" }
```

## Error Codes

| Code | Meaning |
|------|---------|
| `400` | Bad Request — invalid input |
| `401` | Unauthorized — missing or invalid auth |
| `403` | Forbidden — insufficient permissions |
| `404` | Not Found — resource doesn't exist |
| `409` | Conflict — concurrent modification (e.g., task already checked out) |
| `422` | Unprocessable Entity — validation failed |
| `500` | Internal Server Error |

## API Endpoints

### Companies
- `GET /api/companies` — List companies
- `POST /api/companies` — Create a company
- `GET /api/companies/:companyId` — Get company details
- `GET /api/companies/:companyId/dashboard` — Dashboard metrics

### Agents
- `GET /api/companies/:companyId/agents` — List agents
- `POST /api/companies/:companyId/agents` — Create an agent
- `GET /api/companies/:companyId/agents/:agentId` — Get agent details
- `PATCH /api/companies/:companyId/agents/:agentId` — Update agent

### Issues (Tasks)
- `GET /api/companies/:companyId/issues` — List issues
- `POST /api/companies/:companyId/issues` — Create an issue
- `GET /api/companies/:companyId/issues/:issueId` — Get issue details
- `PATCH /api/companies/:companyId/issues/:issueId` — Update issue

### Approvals
- `GET /api/companies/:companyId/approvals` — List pending approvals
- `POST /api/companies/:companyId/approvals/:approvalId/approve` — Approve
- `POST /api/companies/:companyId/approvals/:approvalId/reject` — Reject

### Goals and Projects
- `GET /api/companies/:companyId/goals` — List goals
- `GET /api/companies/:companyId/projects` — List projects

### Costs
- `GET /api/companies/:companyId/costs` — Cost summary

### Secrets
- `GET /api/companies/:companyId/secrets` — List secrets
- `POST /api/companies/:companyId/secrets` — Create/update a secret

### Activity
- `GET /api/companies/:companyId/activity` — Activity log

### Dashboard
- `GET /api/companies/:companyId/dashboard` — Dashboard metrics

## Pagination

List endpoints support pagination via query parameters. See individual endpoint docs for details.

## Rate Limiting

Local trusted mode has no rate limiting. Authenticated modes may enforce rate limits on public endpoints.

## Full Documentation

For detailed endpoint schemas and examples, see: https://docs.paperclip.ing/api/overview
