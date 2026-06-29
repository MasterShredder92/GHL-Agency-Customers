<!--
FILE:       CONTEXT.md
WHAT:       Current active stage, status, and next steps (rewritten each session to reflect truth). The single source for "where are we / what's next."
READ WHEN:  Every session start; before resuming work or deciding what to do next.
SKIP WHEN:  Pure domain-doc reading or rule auditing with no session state needed.
ROUTES TO:  clients/adkins/raven-scripts/_enrollment-agent/ARCHITECTURE-AND-PLAN.md — the build roadmap (§13) | DECISIONS.md — the cleanup record (D16) | AGENTS.md — rules | feature_list.json — scope/WIP
HARD RULES: Rewrite each session (not append); one active stage; next step must be command-checkable (R06). This file is the canonical now+next — keep it true.
-->

# Active Stage & Next Step

**Active Stage:** **Raven enrollment agent — repo cleaned & routed (agent-ready). NEXT = BUILD Phase 0.**

The repo audit + cleanup is complete. The conversation canon is done. The runtime does not exist yet — that's the build.

---

## Status (true as of this session)
- ✅ **Decisions locked:** reply *selection* from hard phrases (LLM only classifies, no free generation) · **GHL** is the only system of record (no Supabase) · channel = GHL LC Phone/Conversations API · legacy `zirowork-agents` runtime archived.
- ✅ **Canon = `clients/adkins/raven-scripts/_enrollment-agent/`** (90-day Quo + 50-agent rewrite): ENROLLMENT-AGENT.md (doctrine), conversation-library.md (22 routed scenarios), few-shot-bank.md, runtime.json (intent→template), LOCATION-DIFFERENCES.md, variants-corpus.md (offline only). Build specs: **ARCHITECTURE-AND-PLAN.md**, **GHL-INTEGRATION.md**, **HARNESS-HOOKS-LOOPS.md**.
- ✅ **Repo cleaned:** CLAUDE.md is a router/map; 31 docs got routing headers; playbook split into 7 core + `client-ops/` + `_campaigns-deferred/`; legacy → `_archive/`; stale paths fixed; PIT redacted; pricing standardized ($200/$180/$160). Full record: DECISIONS.md D16 (health 2.4 → 8.7).
- ✅ **A2P 10DLC: APPROVED** (2026-06-26) — SMS unblocked.
- ✅ **Stack (D14/D15):** Twenty CRM cut; all 4 locations = ONE GHL sub-account (`TCahcPK9X1pptNjBJxP3`) + `preferred_location` field; native-workflow routing.
- ✅ **Omaha form → GHL contact sync** live end-to-end (v2 API, 8 custom fields, 422 fixed).
- ℹ️ GHL pipeline is **UI-only to create** (v2 API can't); make once in the Adkins dashboard, then reference stage IDs.

---

## What's Next (in order)

### 1. BUILD the Raven runtime — Phase 0 → 4  (see ARCHITECTURE-AND-PLAN.md §13)
- **P0 Foundation:** compile the markdown canon → `data/*.json` (runtime.json already is; port FLOW.md → `state-machine.json`; author `pricing.json` from SQUARE.md). *Done = `data/` builds + validates.*
- **P1 Reply loop (GHL):** webhook → identify → context → classify(LLM) → route → **select hard-phrase reply** → validate → send → update GHL state. *Done = a real inbound text gets a correct, guardrail-passing, context-aware reply; eval-gated.*
- **P2 Close + book:** teacher match (TEACHER-PROFILES + Square `searchAvailability`) → idempotent `bookings.create`; confirm only after a real booking; failure → HUMAN_REVIEW.
- **P3 Outbound + drip loop:** form-intake hook fires opener; cron drip D2/D4/D7 → COLD, cancel-on-reply.
- **P4 Harden:** observability, eval set, idempotency/retry, opt-out/quiet-hours.

### 2. Wire form → GHL (unblocks P3 opener)
- `clients/adkins/src/lib/ghl.ts` `createGHLContact` is a reference helper, **not wired**. Wire it into the website form intake (need `SignupLanding.tsx` path) OR move to the website repo. Drop the `if (preferredLoc === 'omaha')` per-sub-account branching — every submit posts to the single sub-account with `preferred_location` set (D15).

### 3. (Optional) Create the GHL pipeline in the Adkins UI
"Trial to Enrollment" stages (New Lead → Contacted → Trial Booked → Trial Completed → Enrolled); capture stage IDs for opportunity advancement.

---

## Open blockers
- **`SignupLanding.tsx` path** (website repo, separate location) — needed to wire `ghl.ts`. Non-blocking on submit (fire-and-forget), blocks the live opener.

---

## Operational notes
- WIP=1 (feature_list.json). Secrets ONLY in `.env`. `clients/` stays gitignored.
- Cleanup log: DECISIONS.md D16. Build detail: `_enrollment-agent/ARCHITECTURE-AND-PLAN.md`.
- Gate: `scripts/verify.sh` exists and is wired via `.githooks/pre-commit`; run `bash scripts/verify.sh` (must exit 0) before commits.
