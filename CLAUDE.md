<!--
FILE:       CLAUDE.md
WHAT:       Entry-point ROUTER. Always loaded. Points to where everything lives; holds no client/business detail.
READ WHEN:  Always — first file every session.
SKIP WHEN:  Never.
ROUTES TO:  MEMORY.md → AGENTS.md → CONTEXT.md (in that order), then the map below.
HARD RULES: Stay a generic router. No client/business domain content. Name the active client + concrete paths in CONTEXT.md, not here.
-->

# ZiroWork — Control Layer for GHL Agency

**Session start order (always):**
1. [MEMORY.md](./MEMORY.md) — who Zach is + what happened last session
2. [AGENTS.md](./AGENTS.md) — hard rules (R01–R15); not suggestions
3. [CONTEXT.md](./CONTEXT.md) — **active client, current stage, and exact next step + paths**

> The router is generic. **CONTEXT.md tells you which client is active right now and the concrete files to open.** Start there for "what do I do next."

---

## Five facts (the whole frame)
- **GHL is the system of record.** One agency account, all clients. No external DB.
- **Secrets ONLY in `.env`** (gitignored). Never in tracked files.
- **Repo is source of truth.** If it's not here, it doesn't exist.
- **Each client folder is sealed.** Read only the active client before operating.
- **Every doc has a header** (`WHAT / READ WHEN / SKIP WHEN / ROUTES TO / HARD RULES`). Read the header first; skip the file if it doesn't match your task.

---

## Repo map

```
CLAUDE.md           ← this router (generic; no client domain)
AGENTS.md           ← hard rules canon R01–R15 (read always)
CONTEXT.md          ← active client + current stage + next step (rewritten each session)
MEMORY.md           ← session log + who Zach is (append-only)
DECISIONS.md        ← why each structural choice was made (append-only)
feature_list.json   ← scope: priority, dependsOn, state, verify
docs/               ← domain knowledge (load only when the task needs it)
  north-star.md       what ZiroWork is
  ghl-config.md       GHL agency/API/MCP/Location IDs
  capabilities.md     GHL capabilities (native vs build)
scripts/            ← verify.sh (gate), init.sh, update-state.sh, setup/onboarding
clients/<slug>/     ← sealed per client (gitignored)
  client.md           canonical IDs + profile
  credentials.md      env var NAMES only
  notes.md / TODO.md  history + working order
  raven-scripts/      ← the client's enrollment agent (see "If working on the agent" below)
_archive/           ← deprecated (old runtime, superseded docs). Do NOT read or import.
```

---

## If working on… → go here

| Task | Read |
|---|---|
| Hard rules / what's allowed | [AGENTS.md](./AGENTS.md) |
| Current task / next step / active client | [CONTEXT.md](./CONTEXT.md) + `clients/<slug>/TODO.md` |
| Why a choice was made | [DECISIONS.md](./DECISIONS.md) |
| What ZiroWork is | [docs/north-star.md](./docs/north-star.md) |
| GHL API / MCP / Location IDs | [docs/ghl-config.md](./docs/ghl-config.md) |
| A client's profile / canonical IDs | `clients/<slug>/client.md` |
| **Enrollment agent — build it** | `clients/<slug>/raven-scripts/_enrollment-agent/ARCHITECTURE-AND-PLAN.md` |
| **Agent — doctrine / templates / FAQ** | `clients/<slug>/raven-scripts/_enrollment-agent/ENROLLMENT-AGENT.md` |
| **Agent — GHL wiring (inbound/outbound/A2P)** | `clients/<slug>/raven-scripts/_enrollment-agent/GHL-INTEGRATION.md` |
| **Agent — harness / hooks / loops** | `clients/<slug>/raven-scripts/_enrollment-agent/HARNESS-HOOKS-LOOPS.md` |
| Agent — routed reply examples | `…/_enrollment-agent/conversation-library.md` + `few-shot-bank.md` |
| Agent — runtime routing table | `…/_enrollment-agent/runtime.json` |
| Agent — state machine / flow | `clients/<slug>/raven-scripts/FLOW.md` |
| Teacher matching | `clients/<slug>/raven-scripts/TEACHER-PROFILES.md` (jump by ID) |
| Booking / availability | `clients/<slug>/raven-scripts/SQUARE.md` |
| Client-ops policy (payment/cancel/etc.) | `clients/<slug>/raven-scripts/_quo-pull/POLICY-STAGING.md` |

---

## Canon vs archive (read before trusting an old file)
- **The enrollment-agent canon = `clients/<slug>/raven-scripts/_enrollment-agent/`** (the active client's, named in CONTEXT.md). Source of truth for the agent.
- **`_archive/` = dead.** Old runtime + superseded docs. Never import, run, or cite it.
- **Agent design (locked):** an LLM *classifies* intent; the *reply* is selected from pre-approved phrases/variants — not free generation. See `…/_enrollment-agent/HARNESS-HOOKS-LOOPS.md`.
