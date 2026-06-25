#!/bin/bash
# Extract GHL credentials from .env.local and output as JSON for Claude Code

ENV_FILE="$(dirname "$0")/../.env.local"

if [ ! -f "$ENV_FILE" ]; then
  echo '{}' >&2
  exit 1
fi

# Extract GHL_API_KEY and GHL_AGENCY_ID from .env.local
GHL_API_KEY=$(grep '^GHL_API_KEY=' "$ENV_FILE" | cut -d'=' -f2-)
GHL_AGENCY_ID=$(grep '^GHL_AGENCY_ID=' "$ENV_FILE" | cut -d'=' -f2-)

# Output as JSON
cat <<EOF
{
  "GHL_API_KEY": "$GHL_API_KEY",
  "GHL_AGENCY_ID": "$GHL_AGENCY_ID"
}
EOF
