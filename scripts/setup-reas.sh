#!/bin/bash
set -e

# Configuration
PAPERCLIP_URL="http://localhost:3100"
COMPANY_ID="48f61379-2369-4c6c-adcf-8396f3201c0d"
API_KEY="paperclip_7ab54b7e_5072_48c4_9629_46ab9a8a909f"
PROMPTS_DIR="/paperclip/agents"

# Helper for API calls
api_call() {
  local method=$1
  local path=$2
  local body=$3
  curl -s -X "$method" "$PAPERCLIP_URL$path" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$body"
}

get_agent_id() {
  local name=$1
  api_call "GET" "/api/companies/$COMPANY_ID/agents" "" | jq -r ".[] | select(.name == \"$name\") | .id" | head -n 1
}

echo "--- Registering Backlog Crawler Agent ---"
CRAWLER_ID=$(get_agent_id "Backlog Crawler")
if [ -z "$CRAWLER_ID" ] || [ "$CRAWLER_ID" == "null" ]; then
  CRAWLER_AGENT=$(api_call "POST" "/api/companies/$COMPANY_ID/agents" '{
    "name": "Backlog Crawler",
    "role": "researcher",
    "title": "Property Sourcing Specialist",
    "adapterType": "openclaw_gateway",
    "adapterConfig": {
      "instructionsFilePath": "'$PROMPTS_DIR'/backlog_crawler_instructions.md"
    },
    "runtimeConfig": {
      "heartbeat": { "enabled": true, "intervalSec": 3600 }
    }
  }')
  CRAWLER_ID=$(echo "$CRAWLER_AGENT" | jq -r '.id')
fi
echo "Crawler Agent ID: $CRAWLER_ID"

echo "--- Registering Investment Analyst Agent ---"
ANALYST_ID=$(get_agent_id "Investment Analyst")
if [ -z "$ANALYST_ID" ] || [ "$ANALYST_ID" == "null" ]; then
  ANALYST_AGENT=$(api_call "POST" "/api/companies/$COMPANY_ID/agents" '{
    "name": "Investment Analyst",
    "role": "researcher",
    "title": "Real Estate Finance Expert",
    "adapterType": "openclaw_gateway",
    "adapterConfig": {
      "instructionsFilePath": "'$PROMPTS_DIR'/investment_analyst_instructions.md"
    },
    "runtimeConfig": {
      "heartbeat": { "enabled": true, "intervalSec": 3600 }
    }
  }')
  ANALYST_ID=$(echo "$ANALYST_AGENT" | jq -r '.id')
fi
echo "Analyst Agent ID: $ANALYST_ID"

if [ "$CRAWLER_ID" == "null" ] || [ "$ANALYST_ID" == "null" ]; then
  echo "Error: Failed to resolve Agent IDs."
  exit 1
fi

echo "--- Creating/Updating Crawler Routine (2 AM) ---"
# Check if routine exists
CRAWLER_ROUTINE_ID=$(api_call "GET" "/api/companies/$COMPANY_ID/routines" "" | jq -r '.[] | select(.title == "Daily Property Fetch") | .id' | head -n 1)

if [ -z "$CRAWLER_ROUTINE_ID" ] || [ "$CRAWLER_ROUTINE_ID" == "null" ]; then
  CRAWLER_ROUTINE=$(api_call "POST" "/api/companies/$COMPANY_ID/routines" '{
    "title": "Daily Property Fetch",
    "description": "Scrape new condo listings matching base criteria",
    "assigneeAgentId": "'$CRAWLER_ID'",
    "status": "active"
  }')
  CRAWLER_ROUTINE_ID=$(echo "$CRAWLER_ROUTINE" | jq -r '.id')
fi

api_call "POST" "/api/routines/$CRAWLER_ROUTINE_ID/triggers" '{
  "kind": "schedule",
  "label": "Daily 2AM",
  "enabled": true,
  "cronExpression": "0 2 * * *",
  "timezone": "America/Chicago"
}'

echo "--- Creating/Updating Analyst Routine (3 AM) ---"
ANALYST_ROUTINE_ID=$(api_call "GET" "/api/companies/$COMPANY_ID/routines" "" | jq -r '.[] | select(.title == "Daily Investment Analysis") | .id' | head -n 1)

if [ -z "$ANALYST_ROUTINE_ID" ] || [ "$ANALYST_ROUTINE_ID" == "null" ]; then
  ANALYST_ROUTINE=$(api_call "POST" "/api/companies/$COMPANY_ID/routines" '{
    "title": "Daily Investment Analysis",
    "description": "Analyze backlog properties for cashflow and location rules",
    "assigneeAgentId": "'$ANALYST_ID'",
    "status": "active"
  }')
  ANALYST_ROUTINE_ID=$(echo "$ANALYST_ROUTINE" | jq -r '.id')
fi

api_call "POST" "/api/routines/$ANALYST_ROUTINE_ID/triggers" '{
  "kind": "schedule",
  "label": "Daily 3AM",
  "enabled": true,
  "cronExpression": "0 3 * * *",
  "timezone": "America/Chicago"
}'

echo "--- Setup Complete ---"
