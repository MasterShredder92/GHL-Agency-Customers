# Decisions — Why Structural Choices Were Made

**Append-only log.** Every structural choice and its reason. Prevents relitigating settled calls.

---

## Session: Harness Lockdown (2026-06-25)

### D01: Verification Gate as the First Artifact

**Decision:** Build `scripts/verify.sh` before PROGRESS.md, DECISIONS.md, or feature_list.json.

**Why:** Verification is the highest-ROI subsystem (B10). A binding gate lets us validate each step as we build, not trust prose. Once the gate exists, every subsequent artifact can be validated on entry. Secrets leak is the highest-risk failure mode (recent incident: credentials in .env.local), so gate prioritizes:
1. SECRET SCAN (PITs, tokens, .env tracking)
2. Hardcoded IDs (no Location IDs in scripts; they come from client files or .env)
3. Per-client shape (sealed folders; structure is enforceable)
4. Router lint (CLAUDE.md ≤100 lines, domain-free)

**Impact:** Phase D proceeds with a non-bypassable correctness check after each step.

---

### D02: Router as Domain-Free Orientation Only

**Decision:** CLAUDE.md ≤~100 lines, points only, zero business/niche logic baked in.

**Why:** Domain coupling in the harness (B15, anti-pattern). CLAUDE.md is the entry point every session; if it restates domain, it duplicates docs/ + clients/ (B11). The moment a router restates, two sources of truth exist and drift. Router points → docs/ holds → domain stays one place. Keeps the hot artifact hot (B03).

**Impact:** CLAUDE.md will never be the source of "what is ZiroWork" or "how Adkins works." That lives in docs/north-star.md and clients/adkins-music-lessons/client.md. Router just points.

---

### D03: Client Folders Named by Full Business Name

**Decision:** `clients/adkins-music-lessons/` (not `clients/adkins/`).

**Why:** Clarity at scale. When you have 50 clients, abbreviated names collide or require mental mapping. Full names are unambiguous and grep-safe. Matches B15 (match structure to size) — even small repos benefit from the habits that scale.

**Impact:** Every new client gets `clients/<full-business-name>/`. Enforced in onboard-subaccount.sh TODOs.

---

### D04: Secrets Never in Any Tracked File

**Decision:** All secrets (GHL PITs, Square tokens, Twilio keys, webhook signatures) live ONLY in `.env` (gitignored). Env var NAMES appear in `clients/*/credentials.md`; VALUES never do.

**Why:** Bleed control. Secrets leaked into production once (Session 1: .env.local committed with live PITs, tokens, signatures). Verify.sh now refuses the pattern. .gitignore blocks .env*, and the gate scans for actual secret patterns (not just names). Belt-and-suspenders.

**Impact:** Every script reads from `.env`. Every CI/CD will inject secrets at runtime, not build time. Credentials.md is documentation of what goes into .env, not a copy of .env itself.

---

### D05: Scope as Data (feature_list.json), Not Prose

**Decision:** Coming in Step 3. Priority + dependsOn + state + verify per feature item, in JSON. Not a written plan.

**Why:** Prose plan = agent can ignore it. Data structure = gate enforces it. `dependsOn: ["A2P-approval"]` checked by the gate is a primitive the agent cannot bypass. Enforces WIP=1 (B09). Sequencing lives in code, not hopes.

**Impact:** Every feature carries a command-checkable `verify` that confirms "done." Next session reads feature_list.json, not prose.

---

### D06: No Loops Until Harness is Green

**Decision:** LOOPS.md will be created after all 7 harness steps pass and audit checklist is green.

**Why:** Looping on a red harness amplifies failure (B12). Cross-client automation (bulk-report, onboard-subaccount) must have: verification (gate), state (PROGRESS + DECISIONS), scope (feature_list), and rules (HARNESS). Without these, a loop that runs 100 times makes 100 mistakes.

**Impact:** No LOOPS.md file yet. scripts/bulk-report.sh remains a stub until harness audit passes. The build loop (agent, human commit) stays human-gated.

---

### D07: Hook Wiring Makes the Gate Binding

**Decision:** `.githooks/pre-commit` will run `verify.sh` before any commit is allowed. Failure = commit refused.

**Why:** A gate in a doc = a suggestion. A gate wired as a hook = a fact (B05, B07). Verification informs only if the human reads it; verification binds only if the hook enforces it. Documents inform, primitives enforce.

**Impact:** Once hooked, no one can commit a broken repo accidentally. The gate runs on every `git commit`.

---

### D08: Init as Its Own Phase

**Decision:** `scripts/init.sh` (Step 6) will stand up the record and environment.

**Why:** Initialization is often forgotten or ad-hoc (B16). A dedicated script ensures: .env is created from .env.example, dependencies are installed, GHL MCP endpoint is reachable, PIT is present and valid. New sessions run init.sh first, and the repo is a reliable surface from day one.

**Impact:** Onboarding a new human or agent = "run `scripts/init.sh`, then read PROGRESS.md."

---

### D09: Harness Before Any Feature Work

**Decision:** No feature_list items about lead capture, SMS, workflows, snapshots until the harness audit is green.

**Why:** A broken harness leaks bugs into the domain. Feature scope without state / verification / rules = chaos. Build the apparatus first; put work *through* the apparatus second.

**Impact:** This session stops after Step 7 (audit green). Feature work (building Adkins workflows, SMS setup, etc.) begins in the next session, against a locked harness.

---

## Session: Repo Rebuild (2026-06-24, previous)

### D10: Full Delete of Old Ideology

**Decision:** Delete all old files (AGENT.md, SCRIPTS.md, WORKFLOWS.md, CLIENTS.md, SESSION_HANDOFF.md, GHL_REFERENCE.md). No archive.

**Why:** Old repo was built on wrong framing (Adkins as product, not case study; SaaS assumptions; fake ROI numbers). Salvaging pieces = dragging wrong mental model into the new structure. Clean rebuild faster than surgical merge.

**Impact:** New repo starts from the two ideology docs (handoff + claude-instructions) only. Zero legacy confusion.

---

### D11: Location IDs as Non-Secrets (OK to Store in Files)

**Decision:** Location IDs (GHL: yhTX395nrDIWlmHv5bfP, Adkins Omaha: L80Q1SNMM4WQ0, etc.) can appear in clients/*/client.md and docs/ghl-config.md.

**Why:** Location IDs identify resources, not authenticate. They're in URLs, logs, API responses. Leaked Location ID ≠ compromised account (API key does). Verify.sh does not block Location ID patterns in docs/clients/.

**Impact:** Docs and client files are readable/shareable without redacting. Only .env is secret.

---

### D12: Adkins as First (and Only) Client Folder

**Decision:** Build clients/adkins-music-lessons/ fully (client.md, credentials.md, notes.md). Leave onboard-subaccount.sh and deploy-snapshot.sh as stubs with TODOs, not full implementations.

**Why:** Adkins is the test case. Seeing the pattern once (one full client folder) guides the next client (copy, adapt). Implementation of onboard/deploy can wait until a second client is ready; the TODOs in the stubs document what to do.

**Impact:** Next client goes faster (copy clients/adkins-music-lessons/ → clients/<new-name>/, adjust). Scripts are not yet needed.

---

### D13: Secrets Rotation Before Repo Lock

**Decision:** All credentials were rotated before locking the harness. New repo starts with clean .env.example (names only).

**Why:** Prior leak (Session 1: .env.local committed). Old secrets are compromised even after delete. New harness must start with fresh credentials.

**Impact:** Old PITs, tokens, webhook keys from Session 1 are invalid. New ones are in use only in the human's local .env (gitignored).

---
