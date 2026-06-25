#!/bin/bash

# Onboard a new client sub-account in GHL
# Usage: ./onboard-subaccount.sh <client-slug> <business-name>
# Example: ./onboard-subaccount.sh acme "ACME Corp"

set -e

CLIENT_SLUG=$1
BUSINESS_NAME=$2

if [ -z "$CLIENT_SLUG" ] || [ -z "$BUSINESS_NAME" ]; then
    echo "Usage: ./onboard-subaccount.sh <client-slug> <business-name>"
    echo "Example: ./onboard-subaccount.sh acme 'ACME Corp'"
    exit 1
fi

echo "Onboarding new client: $BUSINESS_NAME ($CLIENT_SLUG)"

# TODO: Implement the following steps:

# 1. CREATE GHL SUB-ACCOUNT
#    - Call GHL API: POST /v1/sub-accounts/create
#    - Pass: business name, address, phone
#    - Receive: Location ID, API key
#    - Store in .env as GHL_${CLIENT_UPPER}_API_KEY and GHL_${CLIENT_UPPER}_LOCATION_ID

# 2. CONFIGURE GHL SUB-ACCOUNT
#    - Set: Default timezone, currency, language
#    - Set: Twilio/LC Phone integration (if applicable)
#    - Create: Default tags for lead stages (Prospect, Qualified, Booked, Customer, Cold)

# 3. CREATE CLIENT FOLDER
#    - mkdir -p clients/${CLIENT_SLUG}/
#    - Create: client.md (business details + Location IDs)
#    - Create: credentials.md (env var names)
#    - Create: notes.md (running log, start with "Onboarded [date]")

# 4. UPDATE .env
#    - Add env vars for this client (GHL_${CLIENT_UPPER}_API_KEY, etc.)
#    - Instructions: "Fill in values from step 1 above"

# 5. DEPLOY SNAPSHOT
#    - Call scripts/deploy-snapshot.sh ${CLIENT_SLUG}
#    - This copies standard workflows, custom fields, forms to the new sub-account

# 6. VERIFY
#    - Test GHL API call with new Location ID
#    - Confirm sub-account is live
#    - Print summary of Location ID + env vars to use

# 7. COMMIT & NOTIFY
#    - Add new clients/${CLIENT_SLUG}/ files
#    - Print: "Ready! Next steps: fill .env, then read clients/${CLIENT_SLUG}/client.md"

echo "✗ STUB: Implementation needed"
echo "TODO: Implement steps 1-7 above"
echo "Reference: GHL API docs at https://developers.gohighlevel.com/"
