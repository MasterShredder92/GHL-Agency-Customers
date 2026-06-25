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

### Router Restructure (Phase C — this session)
- [x] CLAUDE.md rewritten as thin router (≤100 lines, no domain, points to MEMORY/AGENTS/CONTEXT)
- [x] MEMORY.md created (session log, "who Zach is")
- [x] PROGRESS.md renamed → CONTEXT.md (current truth)
- [x] AGENTS.md created (folded HARNESS.md rules; hard rules canon)
- [x] scripts/update-state.sh created (helper: append session stub to MEMORY.md)
- [x] scripts/verify.sh fixed (clients/ check conditional; skips if absent for fresh clone)
- [x] feature_list.json updated (restructure as done items)
- [x] Verified: verify.sh exits 0 both ways (clients/ present and absent)

---

## What's Next (In Order)

### IMMEDIATE (Feature Work)
1. **F01 — A2P 10DLC Approval** (BLOCKER — gates all SMS flows)
   - Apply for 10DLC number (manual GHL process)
   - Until approved: SMS-independent work only (lead capture, email, etc.)
   - dependsOn: none
   - verify: `curl -s https://rest-api.twilio.com/...` (check 10DLC status, pending/approved)

### THEN (Adkins Zero-Limit Core)
2. **F02 — Lead Capture via GHL Web Form** (SMS-independent)
3. **F03 — Instant AI SMS Response** (blocked by F01)
4. **F04 — Follow-Up Sequences** (blocked by F01)
5. **F05 — Pipeline Management** (SMS-independent)
6. **F06 — Reporting & Analytics** (SMS-independent)

### LATER (Cross-Client Loops)
7. **F07 — Second Client Onboard** (after Adkins MVP ships)
8. **L01 — Bulk Reporting Loop** (after ≥2 clients live)

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
