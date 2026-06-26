# GHL Configuration & API Setup

---

## Agency Account Overview

| Field | Value |
|-------|-------|
| **Agency Name** | ZiroWork |
| **Agency Type** | Processor for multiple clients |
| **MCP Endpoint** | https://services.leadconnectorhq.com/mcp/ |
| **Auth Method** | Private Integration Token (PIT) per sub-account |
| **API Docs** | https://developers.gohighlevel.com/ |

---

## Current API Scopes (Adkins Sub-Account)

When calling GHL API, you have these permissions:

| Category | Permission | Scope |
|----------|-----------|-------|
| **Contacts** | View & Edit | contacts.readonly, contacts.write |
| **Calendar** | View & Edit | calendars.readonly, calendars.write, calendars/events.readonly, calendars/events.write |
| **Conversations** | View & Edit | conversations.readonly, conversations.write, conversations/message.readonly, conversations/message.write |
| **Opportunities** | View & Edit | opportunities.readonly, opportunities.write |
| **Workflows** | View only | workflows.readonly |
| **Tags** | View & Edit | locations/tags.readonly, locations/tags.write |
| **Custom Fields** | View & Edit | locations/customFields.readonly, locations/customFields.write |
| **Forms** | View & Edit | forms.readonly, forms.write |
| **Invoices** | View & Edit | invoices.readonly, invoices.write |
| **Payments** | View & Edit | payments/orders.readonly, payments/orders.write, payments/transactions.readonly |
| **Businesses** | View & Edit | businesses.readonly, businesses.write |
| **Objects** | View & Edit | objects/schema.readonly, objects/schema.write, objects/record.readonly, objects/record.write, associations.readonly, associations.write |

---

## GHL MCP Tools Available

**MCP is how Claude Code interfaces with GHL directly.** Use MCP for live, conversational tasks.

### Available Tools (Official GHL MCP)

From `https://services.leadconnectorhq.com/mcp/`:

- `find_many_contacts` — Search/list contacts
- `find_one_contact` — Get single contact details
- `create_one_contact` | `create_many_contacts` — Add contacts
- `update_one_contact` | `update_many_contacts` — Modify contacts
- `find_many_opportunities` — Search/list opportunities
- `find_one_opportunity` — Get opportunity details
- `update_one_opportunity` — Modify opportunity (move in pipeline)
- `create_workflow` variants — Build workflows
- `send_email` — Send email via GHL
- `http_request` — Execute any GHL REST API call

**Use these for:** Lead qualification, SMS sending (via workflow action), tag management, pipeline updates, reporting queries.

---

## Location IDs & Sub-Accounts

All clients operate as sub-accounts under the ZiroWork agency. Each has a Location ID for API calls.

| Client | Account | Location ID | Status |
|--------|---------|-------------|--------|
| **ZiroWork (Agency)** | Agency level | `Zwvc66b4SDwQ6MZ25wXY` | Production |
| **Adkins Music Lessons** | Sub-account | `TCahcPK9X1pptNjBJxP3` | Production (SMS A2P approved ✓) |

**Why this matters:** When using MCP, you often specify a Location ID. The agency handles cross-client operations; sub-accounts handle per-client workflows.

---

## SMS & Calling Integration

**Current:** A2P 10DLC registration in progress (gates all SMS).

**Provider:** LC Phone (native to GHL, phasing out Twilio).

**How it works:**
1. A2P 10DLC approved → SMS activation live in GHL
2. Workflows send SMS via LC Phone
3. Replies come back to GHL conversations
4. No external SMS provider needed (all native)

**Tracking Number:** Will be assigned once A2P approved (currently pending).

---

## Square Integration (Adkins)

**Purpose:** One-time appointment creation; recurring billing stays in Square.

| Field | Value |
|-------|-------|
| **API Type** | REST (v2026-05-20) |
| **Auth** | OAuth + Access Token |
| **Locations** | 4 (Omaha, Bellevue, Gretna, Elkhorn) |
| **Use Case** | Create appointments when lead qualifies + books |

**Key Constraint:** GHL can't auto-charge recurring via Square. Billing stays in Square forever — this is a feature, not a limitation.

---

## Secrets & Local Setup

**All secrets live in `.env` (gitignored).**

Your `.env` must include (see `.env.example` for full template):
- `GHL_API_KEY` — Agency-level API key
- `GHL_ADKINS_API_KEY` — Adkins sub-account API key
- `SQUARE_ACCESS_TOKEN` — Square API credentials
- All Square location IDs

**Never print secret values.** Reference env var names only in reports.

---

## Operating Patterns

### One-Off / Live Tasks (Use MCP in Chat)

```
"Find all Adkins leads from this week who haven't been contacted"
→ Use find_many_contacts via MCP
→ Filter by date + tag
→ Return results
```

### Repeatable / Bulk Tasks (Use Scripts in Repo)

```
"Create a new client sub-account and deploy the standard lead-capture workflow"
→ Use scripts/onboard-subaccount.*
→ Committed to repo, runs every time identically
→ Bulk writes state what will change first, ask for approval
```

---

## PIT Rotation & Security

- **PIT is a password.** Never paste in shared docs/chat/commits.
- **Start scopes at View.** Add Edit only when trusted.
- **Avoid destructive scopes** (user deletion) unless required.
- **Rotate PIT ~every 90 days.**

If you suspect a PIT is compromised, rotate it immediately (this invalidates all old tokens).

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| "Invalid credentials" | PIT expired or wrong sub-account | Verify Location ID matches intent; check PIT in `.env` |
| "Location not found" | Using wrong Location ID | Confirm you're targeting the right client |
| "Permission denied" | Scope not enabled | Request admin to add scope (e.g., workflows.write) |
| Workflow won't trigger | Missing contact field | Verify contact has all required custom fields before workflow runs |
