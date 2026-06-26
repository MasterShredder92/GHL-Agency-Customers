# Active Stage & Next Step

**Active Stage:** Harness complete, committed, hook-wired, gate green on a fresh clone. WIP=1.

**Last Checkpoint:** All structural rules in place. Repo is source of truth. Verification gate passes with clients/ present and absent. save-and-update routine wired.

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

### PHASE E: CRM Foundation for Adkins (In Progress)

**CURRENT (This Session):**
1. **CRM Foundation Setup** (SMS-independent, prerequisite for all Adkins features)
   - Status: WIP — scripts ready, API credentials pending verification
   - Location ID: `TCahcPK9X1pptNjBJxP3`
   - API Key: stored in `.env` + `.mcp.json` (NEVER in tracked files)
   - What to create:
     - Custom fields: instrument, student_age, skill_level, preferred_times, lead_source
     - Tags: trial-requested, trial-booked, trial-completed, enrolled, lost, nurture
     - Pipeline: "Trial to Enrollment" (stages: New Lead → Contacted → Trial Booked → Trial Completed → Enrolled)
   - Blocker: API returning 404; need to verify credentials are live/active in GHL
   - Next: restart Claude Code + retry API calls, OR confirm credentials validity

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

- **A2P 10DLC approval** (external; Twilio/GHL process; 3–5 business days typically)
  - All SMS features depend on this.
  - F01 is a gate; all SMS work deferred until approved.

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
