# ZiroWork — Control Layer for GHL Agency

**ZiroWork is a done-for-you customer-acquisition service for service-based businesses.** We sit on top of clients' existing tools (Square, Stripe, etc.) and automate lead response, follow-up, and retention via GoHighLevel (GHL).

**Claude Code is the control layer.** We operate ZiroWork via the GHL MCP + API, not via GHL's dashboard.

---

## Quick Navigation

**Start Here:**
- **[docs/north-star.md](./docs/north-star.md)** — What ZiroWork is, the frame, the two honest limits
- **[docs/ghl-config.md](./docs/ghl-config.md)** — GHL setup, MCP endpoint, agency account details, current scopes

**Operating:**
- **[docs/capabilities.md](./docs/capabilities.md)** — The 15 core capabilities (native vs. build)
- **[clients/_index.md](./clients/_index.md)** — Client roster; each client has a sealed folder

**Automation & Scale:**
- **[scripts/](./scripts/)** — Repeatable jobs (onboard new client, deploy snapshot, cross-client reporting)
- **[snapshots/](./snapshots/)** — What each snapshot contains, how to build/deploy

---

## Key Facts

- **GHL Agency = ZiroWork.** One account for all clients.
- **MCP is how we operate.** Live, conversational tasks (find leads, send SMS, create workflows) use MCP in chat.
- **Scripts are for repeatable, bulk, or multi-client jobs.** Committed to repo, not one-off chat actions.
- **Secrets live ONLY in `.env` (gitignored).** Never in repo files.
- **Each client is sealed.** Claude reads only the relevant client folder before operating.

---

## Setup

1. Copy `.env.example` → `.env`
2. Populate `.env` with your agency & client credentials
3. Read [docs/north-star.md](./docs/north-star.md)
4. Pick a client from [clients/_index.md](./clients/_index.md)
5. Use GHL MCP or scripts to operate

---

## Hard Rules

- `.env` and `.env*` are gitignored. Secrets stay local only.
- Env var NAMES can appear in `credentials.md` files; VALUES never.
- One-off chat tasks → MCP. Repeatable tasks → scripts.
- Always confirm before bulk writes across multiple clients.
