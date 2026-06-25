# Hard Rules Canon (AGENTS.md)

**What correct looks like.** This is the rule set every agent (Claude Code, future agent, human reviewer) must follow. Domain-agnostic. Authority for all structural decisions.

Read this before doing anything. These rules are NOT suggestions.

---

## Core Rules (R01–R15)

### R01 — Repo Is Source of Truth
If it's not in the repo, it doesn't exist. Credentials live ONLY in `.env` (gitignored) + env var names in `credentials.md`. Client details ONLY in `clients/<slug>/`. State ONLY in MEMORY.md, CONTEXT.md, DECISIONS.md (not email, not Slack, not external).

### R02 — Exactly One Source of Truth Per Fact
Duplication → drift. GHL Location IDs: canonical in `clients/adkins-music-lessons/client.md`. Rules: live here (AGENTS.md). MCP details: canonical in `docs/ghl-config.md`. CLAUDE.md points; it does not restate.

### R03 — Router Stays Hot (≤100 Lines, No Domain)
CLAUDE.md auto-loads every session. Keep it thin. First three lines: "Read MEMORY.md first — Read AGENTS.md before doing anything — Read CONTEXT.md." Then a repo tree/map. Never restates domain. Domain lives in docs/ and clients/.

### R04 — Scope Is Data, Not Prose
`dependsOn: ["A2P-approval"]` in feature_list.json is a primitive; "wait for A2P approval" in a doc is a hope. State primitives enforce; documents inform only.

### R05 — Primitives Enforce; Documents Inform
Gate (verify.sh): checks secrets, hardcoded IDs, per-client shape. Primitive — cannot be bypassed. Hook (.githooks/pre-commit): runs gate before commit. Primitive. DECISIONS.md: explains why a choice was made. Document (informs only).

### R06 — Command-Checkable Definition of Done
No "looks done." Done = gate passes, a command succeeds, or a primitive enforces it. "Harness is locked" = verify.sh exits 0. "Client folder is correct" = verify.sh passes per-client shape check.

### R07 — Verification Is Highest-ROI Subsystem
Build it before polish. A broken gate catches more bugs than code review. Harness lockdown prioritizes verification (scripts/verify.sh is first). Every feature item carries a `verify` command (the gate will check it). Secret scan is priority #1 (we had a leak once; verify.sh is the circuit breaker).

### R08 — Cross-Session State: MEMORY + CONTEXT + DECISIONS
MEMORY.md: who Zach is + session log (append-only, newest on top). CONTEXT.md: current stage + next steps + last checkpoint (rewrite each session to reflect truth). DECISIONS.md: what was chosen and why (append-only, never deleted). Next session reads these first.

### R09 — One Unit of Work in Flight (WIP=1)
Enforced by feature_list.json. Starting 10 features and finishing none = chaos. Finishing one, then one more = progress. Only one item in `"state": "in_progress"` at a time.

### R10 — Initialization Is Its Own Phase
Before any feature work runs, the record and environment must be correct. scripts/init.sh stands up .env, deps, and GHL connectivity. Every new session calls `scripts/init.sh` before `scripts/verify.sh`.

### R11 — Secrets Never in Tracked Files
`.env` is gitignored. No PITs, tokens, webhook keys, or app secrets in any tracked file. `.env.example` has NAMES ONLY (e.g., `GHL_API_KEY=`). `clients/*/credentials.md` lists env var NAMES (e.g., `GHL_ADKINS_API_KEY`), never values. Verify.sh scans for secret patterns (pit-[...], EAA[...], etc.) and refuses commits if found. Hook (git pre-commit) runs verify.sh; failure blocks the commit.

### R12 — Cross-Client Loops Above Green Harness
A loop (bulk-report, onboard-subaccount) requires: harness green (verification, state, scope all present), ≥2 active clients (not hypothetical; real folders in clients/), loop spec with explicit stop condition + cost cap (LOOPS.md). Features F01–F06 are single-client (Adkins). Build, test, ship first. L01 (bulk-report) is deferred.

### R13 — Domain ≠ Harness
Business logic, niche rules, client-specific workflows: these are domain. Harness: environment, state, verification, control — domain-agnostic. AGENTS.md contains no mention of music schools, Adkins, GHL, or SMS workflows. Those are domain (docs/, clients/). AGENTS.md states rules like "secrets never in tracked files" — universal.

### R14 — Smallest Reversible Steps, Verify Each
Never bulk-rewrite 10 things, then run the gate. Change one thing, verify, move on. If a step breaks, the culprit is obvious. WIP=1 + smallest reversible steps = confidence.

### R15 — Match Structure to Size
A one-file spike doesn't need LOOPS.md. A 50-module system does. ZiroWork is currently small (1 client, 1 team). Structure matches: router + verify gate + state + single-client feature scope. LOOPS.md will be added when we have 2+ clients.

---

## Agent Responsibilities

### Zach's Role (Decide and Commit)
- Reads MEMORY.md, AGENTS.md, CONTEXT.md before asking Claude to do anything
- Decides what to work on (picks a feature from feature_list.json or gives a new direction)
- Confirms bulk/multi-client writes ("yes, send SMS to all these contacts")
- Reviews and commits work to GitHub (agent never commits; Zach only)

### Claude's Role (Architect and Execute)
- Reads MEMORY.md, AGENTS.md, CONTEXT.md first (context awareness)
- Applies Karpathy principles: think before coding, simplicity first, surgical changes, goal-driven execution
- Proposes work, not auto-commits
- Before commit: updates CONTEXT.md (stage/next) and calls scripts/update-state.sh (appends session stub to MEMORY.md)
- Verifies each step: run verify.sh after every change; must exit 0
- Flags when gate is red; does not commit if verify.sh fails

---

## Save-and-Update Routine (R08)

Before proposing any commit, Claude must:

1. Call `bash scripts/update-state.sh` (appends timestamped, empty session-entry stub to MEMORY.md)
2. Refresh CONTEXT.md's active-stage and next-step to reflect truth (what's done, what's next)
3. Commit message: concise, references the feature or rule (e.g., "chore: fix verify.sh clients/ check (R01)")

The repo must always be able to brief a fresh agent from CLAUDE.md alone. This routine ensures continuity.

---

## When Harness Fails

If verify.sh exits non-zero:

1. Read the failure message (specific check + why it failed)
2. Find the rule above (AGENTS.md R##)
3. Fix the repo to pass the check
4. Re-run verify.sh. Exit 0 = fixed.

---

## Gate Checks (Enforcer: scripts/verify.sh)

| Rule | Check | Failure |
|------|-------|---------|
| R11 (Secrets never tracked) | SECRET SCAN: PITs, tokens, .env in tracked files | repo has leaked credentials |
| R11 (Secrets never tracked) | .env is gitignored + not tracked | secret exposure risk |
| R04 (No hardcoded IDs in scripts) | Scan scripts/ for Location ID patterns | scripts can't loop over clients (ID is hardcoded) |
| R02 (One source of truth) | Per-client folder shape (client.md, credentials.md, notes.md) | client data is scattered or missing |
| R03 (Router is thin + domain-free) | CLAUDE.md ≤ 100 lines | router is bloated |
| R03 (Router is domain-free) | CLAUDE.md has no domain keywords | domain logic leaked into harness |
| R05 (Primitives exist) | Gate, MEMORY.md, AGENTS.md, CONTEXT.md, DECISIONS.md, feature_list.json present | harness is incomplete |

---

## Secrets: Never Tracked

Acceptable (gitignored):
- `.env` (local copy; names + values)
- `.env.local`
- `.env*.local`

Never tracked (will be caught by gate):
- PIT pattern: `pit-[a-f0-9]{8,}`
- Bearer token: `Bearer [A-Za-z0-9_-]{50,}`
- Square token: `EAA[A-Za-z0-9_-]{50,}`
- Any tracked `.env*` (except `.env.example`)

---

## Hard Stop Conditions (Gate Will Reject)

1. Secret pattern found in any tracked file → exit 1
2. Hardcoded Location ID in scripts/ → exit 1
3. Client folder missing required files (client.md, credentials.md, notes.md) → exit 1
4. CLAUDE.md > 120 lines → exit 1
5. CLAUDE.md contains domain keywords → exit 1
6. Required harness files missing (MEMORY.md, AGENTS.md, CONTEXT.md, DECISIONS.md, feature_list.json) → exit 1

---

## Last Updated

2026-06-25 (session: router restructure, Phase C)
