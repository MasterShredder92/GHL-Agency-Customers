<!--
FILE:       MEMORY.md
WHAT:       Append-only session log plus permanent "who Zach is" identity context for all agents
READ WHEN:  Every session start (per CLAUDE.md); when needing Zach's work style or prior session outcomes
SKIP WHEN:  Task is purely structural/code with no need for operator identity or history
ROUTES TO:  CONTEXT.md — current stage continuing from prior sessions | AGENTS.md — rules established across sessions | clients/adkins/client.md — client details referenced in sessions
HARD RULES: Append-only (newest session on top, never edit past entries); "Who Zach Is" section is permanent and must not be removed
-->

# Who Zach Is

**Zach Adkins** runs ZiroWork, a done-for-you customer-acquisition service for service-based businesses. The service sits in front of a client's booking/billing (Square, Stripe, etc.); never replaces it. GHL is the engine; Claude Code is the control layer (MCP + API, not dashboard).

**Work style:** Decides and commits. Wants behavior over self-reports, answer-first, map-first, correction over agreement, one question at a time.

---

# Session Log (Newest on Top)

## [2026-06-28] Raven rebuild + repo cleaned to agent-ready

- **New canon = `clients/adkins/raven-scripts/_enrollment-agent/`** (90-day Quo pull + 50-agent rewrite). Old `zirowork-agents` runtime archived → `_archive/zirowork-legacy/`.
- **Decisions locked:** reply SELECTION from pre-approved hard phrases (LLM only classifies intent — no free generation); GHL is sole system of record (**no Supabase**); channel = GHL LC Phone/Conversations API.
- **Repo cleaned (health 2.4→8.7):** CLAUDE.md = router/map; 31 docs got routing headers; playbook split into 7 core + `client-ops/` + `_campaigns-deferred/`; legacy + zombie dupes (HARNESS.md, PROGRESS.md) archived; stale `adkins-music-lessons` paths fixed; burned PIT redacted; pricing standardized $200/$180/$160.
- **New build canon:** `_enrollment-agent/` ARCHITECTURE-AND-PLAN.md, GHL-INTEGRATION.md, HARNESS-HOOKS-LOOPS.md. Cleanup log: `.agent/repo-clean/progress.md`.
- **CONTEXT.md rewritten** as the single now+next source.
- **Next:** BUILD Phase 0 — compile canon → `data/*.json`; port FLOW.md → `state-machine.json`; author `pricing.json` (see ARCHITECTURE-AND-PLAN.md §13).

## [2026-06-25] Restructured CLAUDE.md → MEMORY/AGENTS/CONTEXT router

## [2026-06-26] GHL 422 fixed + MCP dynamic-token + multi-location runbook

- **Fixed website signup 422:** `customFields` sent as object → converted to GHL v2 array `[{id,field_value}]` in `api/ghl-contact.ts` (regex-filters non-ID keys); dropped 3 SMS-consent slugs (consent lives in Supabase only). Commit `c4a2927`.
- **Value-mapping follow-up:** form sent lowercase ids/keys that don't match SINGLE_OPTIONS picklists; now sends labels (`instrument`→"Piano", `preferred_location`→`LOCATIONS[key].name`).
- **MCP token was dead (401):** swapped to live `GHL_ADKINS_API_KEY`, then refactored `.mcp.json` to `headersHelper` (`scripts/ghl-mcp-headers.js`) that reads the token live from `.env` — single source, secret out of `.mcp.json`. Verified end-to-end (test contact created, all 8 fields resolved via MCP).
- **Surfaced the multi-location traps:** two different locationIds (GHL sub-account ID `TCahcPK9X1pptNjBJxP3` vs Supabase UUID in `locations.ts`); each GHL sub-account has its own field IDs; GHL field dataType is immutable. Wrote `adkins-music-website/GHL_LOCATION_ONBOARDING.md` (field spec + steps + AVOID/CHECK). Fixed stale token in website `.env.local`.
- **Next:** Onboard Bellevue/Elkhorn/Gretna per the runbook — need their GHL sub-account IDs (not in repo); do the per-location `GHL_FIELD_IDS`/`GHL_LOCATION_IDS` refactor before location #2.


## [2026-06-26] GHL v2 API complete — BUILD vs OPERATE architecture mastered

- **Fixed v1→v2 migration:** Removed `/v1/` segments, added Version: 2021-07-28 header, placed locationId in body
- **Fixed setup script:** ES modules, .env loading, v2 payload formats (dataType, name, etc.)
- **Key insight:** GHL v2 is BUILD (UI) + OPERATE (API) split. Pipelines/workflows/funnels/forms are **UI-only** (no create endpoint). API can only move data through existing structures. The 401 on [PIPELINE] POST was not a scope issue — it was attempting a non-existent endpoint.
- **What's done:** Custom fields (10) ✓, tags (6) ✓, website `/api/ghl-contact.ts` updated to v2 ✓
- **What's next:** Form → GHL sync test; pipeline creation is manual UI work (create once, then script references stage IDs)
- Committed: pipeline step refactored to GET-only + user guidance (don't build via API)


## [2026-06-25] Router restructure complete: MEMORY/AGENTS/CONTEXT pattern locked

- Restructured CLAUDE.md as thin router (3-line pattern → MEMORY/AGENTS/CONTEXT)
- Created MEMORY.md (session log + "who Zach is"), AGENTS.md (hard rules R01–R15), CONTEXT.md (renamed PROGRESS.md)
- Created scripts/update-state.sh (save-and-update helper: appends session stub to MEMORY.md)
- Fixed scripts/verify.sh (clients/ check conditional; exits 0 both ways: fresh clone ✓ and local ✓)
- Removed secrets from clients/adkins/credentials.md (now env var names only; values in .env, gitignored)
- Updated feature_list.json (added router_restructure section R01–R07, all done)
- **Committed to main** (efa5601)
- **Next:** F01 — A2P 10DLC approval (blocks all SMS flows; SMS-independent work only until approved)


- Folded HARNESS.md rules into AGENTS.md
- Renamed PROGRESS.md → CONTEXT.md
- Created MEMORY.md (this file) with session log
- Fixed scripts/verify.sh: clients/ check now conditional (skips if absent, for fresh clone)
- Created scripts/update-state.sh (helper for save-and-update)
- Updated feature_list.json with restructure as done items
- **Verified:** verify.sh exits 0 both ways (clients/ present and absent)
- **Next:** F01 — A2P 10DLC approval (blocks all SMS flows)

## [2026-06-24] Harness lockdown: verify.sh gate + state + scope + rules + pre-commit hook

- Created scripts/verify.sh (verification gate; exits 0 ✓ on clean repo)
- Created PROGRESS.md + DECISIONS.md (cross-session state)
- Created feature_list.json (scope primitive)
- Created HARNESS.md (rule canon R01–R15)
- Wired .githooks/pre-commit (gate runs before commit; rejects fake-PIT at exit 1 ✓)
- Created scripts/init.sh (environment standup)
- Audit checklist green
- **Pushed to GitHub main**
- **Next:** Restructure CLAUDE.md as router; fold HARNESS into AGENTS.md; rename PROGRESS → CONTEXT
