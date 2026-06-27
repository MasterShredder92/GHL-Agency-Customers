# Active Stage & Next Step

**Active Stage:** GHL API Integration (PHASE E) — **Omaha form → contact sync LIVE; replicate to 3 more locations next**.

**Status:** 
- ✅ Omaha form → GHL contact sync working end-to-end (422 fixed, all 8 custom fields populate, verified via MCP)
- ✅ 422 root cause fixed: `customFields` object → v2 array + dropped consent slugs (website commit `c4a2927`); value-mapping fix (labels not lowercase keys)
- ✅ MCP reads token live from `.env` via `headersHelper` (`scripts/ghl-mcp-headers.js`); no hardcoded secret in `.mcp.json`
- ✅ Multi-location runbook written: `adkins-music-website/GHL_LOCATION_ONBOARDING.md`
- ℹ️ Pipeline: **UI-only in GHL v2** (not API-creatable). Create in Adkins dashboard once, then reference existing stage IDs.

**Last Checkpoint:** Omaha sync verified live. **Now:** Onboard Bellevue/Elkhorn/Gretna per the runbook. BLOCKER: need their GHL **sub-account** IDs (repo only has Supabase UUIDs). Do the per-location `GHL_FIELD_IDS`/`GHL_LOCATION_IDS` refactor before location #2 — do NOT duplicate the Omaha block.

---

## What's Done ✅

### Repo Structure (Phase A — prior sessions)
- [x] Old content deleted (AGENT.md, SCRIPTS.md, WORKFLOWS.md, etc.)
- [x] New structure created (CLAUDE.md router, docs/, clients/, scripts/, snapshots/)
- [x] Adkins Music Lessons client folder (client.md, credentials.md, notes.md)
- [x] Secrets rotated; .env.local deleted
- [x] .env.example populated (names only, no values)

### Harness Lockdown (Phase B — prior session)
- [x] `scripts/verify.sh` — verification gate (exits 0, secret scan, per-client shape, router lint, artifact checklist)
- [x] PROGRESS.md + DECISIONS.md (cross-session state, append-only decision log)
- [x] feature_list.json (scope primitive: priority, dependsOn, state, verify per item)
- [x] HARNESS.md (rule canon R01–R15, enforcer mappings)
- [x] `.githooks/pre-commit` (hook-wiring; rejects secrets at exit 1)
- [x] `scripts/init.sh` (environment standup: .env, deps, GHL connectivity)
- [x] Audit checklist: all green

### Router Restructure (Phase C — this session) ✅ COMPLETE
- [x] CLAUDE.md rewritten as thin router (46 lines, no domain, 3-line pattern → MEMORY/AGENTS/CONTEXT)
- [x] MEMORY.md created (session log + "who Zach is"; append-only)
- [x] PROGRESS.md renamed → CONTEXT.md (current truth; rewrite each session)
- [x] AGENTS.md created (folded HARNESS.md rules R01–R15; hard rules canon)
- [x] scripts/update-state.sh created (helper: append timestamped session stub to MEMORY.md)
- [x] scripts/verify.sh fixed (clients/ check conditional; exits 0 fresh clone ✓ and local ✓)
- [x] clients/adkins/credentials.md cleaned (removed secrets; now env var names only)
- [x] feature_list.json updated (added router_restructure section R01–R07, all done)
- [x] **Committed to main** (efa5601: refactor: restructure CLAUDE.md → MEMORY/AGENTS/CONTEXT router pattern)
- [x] save-and-update routine: executed and recorded

---

## What's Next (In Order)

### PHASE E: GHL API Integration (Current)

**BLOCKERS & FIXES (This Session):**
1. **API Key Rotation** — COMPLETE (security incident)
   - Old PIT: burned (pasted in chat, rotated immediately)
   - New token: stored as `GHL_ADKINS_API_KEY` in `.env` (gitignored)

2. **Endpoint Format Bug** — ROOT CAUSE of 404 errors
   - ❌ Using: `/v1/contacts/` (v1 end-of-support Dec 31 2025)
   - ✅ Should use: `/contacts/` (v2 current)
   - ✅ locationId must be top-level in body (not just in customFields)
   - ✅ customFields format: array of `{key/id, field_value}` not plain object

**NEXT STEPS:**
1. ✅ API endpoint migration (v1→v2) complete
2. ✅ Both repos aligned on v2 format
3. ✅ Custom fields + tags created in GHL
4. **[OPTIONAL] Create pipeline in Adkins UI** (for later opportunity workflows; not required for lead capture)
   - Go to Adkins in GHL → **Opportunities → Pipelines → Create New Pipeline**
   - Add: "Trial to Enrollment" with stages: New Lead, Contacted, Trial Booked, Trial Completed, Enrolled
   - Re-run script to capture stage IDs
5. **Test form → GHL sync:** Submit Adkins form, verify contact appears in GHL with custom fields populated
6. **Build workflows** (once sync confirmed): F02 Lead Qualification, F03 SMS responses, etc.

### PHASE D: Feature Work — F01 (BLOCKER — gates all SMS)

**THEN (After CRM Foundation + F01 Approved):**
1. **F01 — A2P 10DLC Approval** (BLOCKER — gates all SMS flows)
   - Status: awaiting carrier approval (external; typically 3–5 business days)
   - Until approved: SMS-independent work only (lead capture, email, etc.)
   - dependsOn: CRM Foundation
   - Next: check `clients/adkins/notes.md` for approval status; SMS features unlock when approved

### THEN (After F01 Approved)

**Adkins Zero-Limit Core (SMS-dependent):**
2. **F02 — Lead Capture via GHL Web Form** (SMS-independent, start now)
3. **F03 — Instant AI SMS Response** (blocked by F01; starts after approval)
4. **F04 — Follow-Up Sequences** (blocked by F01; starts after approval)
5. **F05 — Pipeline Management** (SMS-independent, can start now)
6. **F06 — Reporting & Analytics** (SMS-independent, can start now)

### LATER (Cross-Client Loops)
7. **F07 — Second Client Onboard** (after Adkins MVP ships)
8. **L01 — Bulk Reporting Loop** (after ≥2 clients live; deferred per R12)

---

## Blockers

- **SignupLanding.tsx file path** (user has website repo in different location)
  - Need exact path to integrate ghl.ts contact creation
  - Blocks form → GHL sync (non-blocking on submit, fire-and-forget)

---

## Last Known Good State

- Repo structure: correct per REPO_BLUEPRINT.md Phase A
- Verification gate: present, functional, exits 0 (both clients/ present and absent)
- Secrets: rotated; no leaks in current repo
- Router (CLAUDE.md): 50 lines, domain-free, points to MEMORY/AGENTS/CONTEXT
- Client folder (Adkins): sealed, structure validated
- Harness: rule canon + state + scope + verification all in place
- Save-and-update routine: wired (update-state.sh + AGENTS.md rule)

---

## Operational Notes

- WIP=1: only one feature in `"state": "in_progress"` at a time
- After every step: run `bash scripts/verify.sh` (must exit 0)
- Before commit: run `scripts/update-state.sh` (appends session stub); then refresh CONTEXT.md's active-stage and next-step
- Secrets: ONLY in .env (gitignored). .env.example has names only.
- Clients stays gitignored. On clone: `verify.sh` skips per-client checks if clients/ absent.
