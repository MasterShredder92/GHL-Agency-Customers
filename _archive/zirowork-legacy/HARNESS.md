# HARNESS — Rule Canon for ZiroWork Repo

**What correct looks like.** The standard this repo is measured against. Domain-free. Points to REPO_BLUEPRINT.md for the generic procedure; this file is ZiroWork-specific rule enforcement.

**This file is NOT for feature work or domain logic.** Domain lives in `docs/` and `clients/`. This file holds structural rules only.

---

## Core Rules (R01–R15)

Read in one screen. Crosswalks to `REPO_BLUEPRINT.md` B-rules at the end.

### R01 — Repo Is Source of Truth

If it's not in the repo, it doesn't exist. No "we always do X" in Slack or memory — if X matters, it's a rule, primitive, or artifact in the repo.

**Applied here:**
- Credentials policy: ONLY in `.env` (gitignored) + env var names in `credentials.md`.
- Client details: ONLY in `clients/<slug>/`.
- State: ONLY in PROGRESS.md + DECISIONS.md (not email, not memory).

### R02 — Exactly One Source of Truth Per Fact

Duplication → drift. If a fact is stated in two places, one will become stale.

**Applied here:**
- GHL Location IDs: live in `clients/adkins-music-lessons/client.md` (canonical). CLAUDE.md points; it does not restate.
- Rules: live in this file (HARNESS.md). REPO_BLUEPRINT.md describes the procedure; it does not restate.
- MCP details: canonical source is `docs/ghl-config.md`. CLAUDE.md points outward.

**Enforcer:** Verify.sh lints for domain logic in CLAUDE.md (red if found).

### R03 — Router Stays Hot (≤100 Lines, No Domain)

The router (`CLAUDE.md`) auto-loads every session. Keep it thin. It maps and points. It never restates domain.

**Applied here:**
- CLAUDE.md ≤ 100 lines (currently 50).
- CLAUDE.md contains: orientation, current phase, pointers to docs/ and clients/.
- CLAUDE.md does NOT contain: business logic, credentials, Adkins-specific details, workflow definitions.
- If you're tempted to explain something in CLAUDE.md, write it in docs/ and point to it instead.

**Enforcer:** Verify.sh checks line count (>120 = fail) and scans for domain keywords (music, Adkins, etc.).

### R04 — Scope Is Data, Not Prose

Sequencing and WIP enforcement live in `feature_list.json`, not in documents.

**Applied here:**
- `dependsOn: ["A2P-approval"]` in feature_list.json is a primitive; "wait for A2P approval" in a doc is a hope.
- `verify` command per feature item is checked by the gate; "make sure it works" in prose is an opinion.
- WIP=1: only one item in flight. Enforced by the gate checking feature_list.json state.

**Enforcer:** Gate (verify.sh) will eventually refuse to mark a feature done if its dependsOn items are not done first.

### R05 — Primitives Enforce; Documents Inform

A document that says "do X" can be ignored. A primitive (gate, hook, script) that prevents "not X" cannot.

**Applied here:**
- Gate (verify.sh): checks secrets, hardcoded IDs, per-client shape. Primitive.
- Hook (.githooks/pre-commit): runs gate before commit. Primitive.
- DECISIONS.md: explains why a choice was made. Document (informs only).

**Implication:** If something must not be bypassed, make it a primitive, not a guideline.

### R06 — Every Task Carries a Command-Checkable Definition of Done

No "looks done." Done = gate passes, a command succeeds, or a primitive enforces it.

**Applied here:**
- "Harness is locked" = audit checklist is all green (command-checkable).
- "Client folder is correct" = verify.sh passes the per-client shape check.
- "No secrets leaked" = verify.sh passes the secret scan.

### R07 — Verification Is the Highest-ROI Subsystem

Build it before polish. A broken gate catches more bugs than code review.

**Applied here:**
- Harness lockdown prioritizes verification (H01_verify_gate is first).
- Every feature item carries a `verify` command (the gate will check it).
- Secret scan is priority #1 (we had a leak once; verify.sh is the circuit breaker).

### R08 — Cross-Session State: Progress + Decisions

PROGRESS.md: where we are now + next step + last checkpoint.  
DECISIONS.md: what was chosen and why (append-only).

**Applied here:**
- PROGRESS.md updated every session (current phase, what's done, what's next).
- DECISIONS.md never deleted; every structural choice recorded (D01–D13 so far).
- Next session reads these first, resuming from the checkpoint.

### R09 — One Unit of Work in Flight (WIP=1)

Enforced by the gate and feature_list.json. Starting 10 features and finishing none = chaos. Finishing one, then one more = progress.

**Applied here:**
- Harness lockdown: one step at a time (H01, then H02, then H03…). Verify after each.
- Feature work: one feature in `"state": "in_progress"` at a time.
- Multi-client operations (loops): deferred until harness is green + ≥2 clients.

### R10 — Initialization Is Its Own Phase

Before any feature work runs, the record and environment must be correct.

**Applied here:**
- scripts/init.sh (to be created in H06) stands up .env, deps, and GHL connectivity.
- Every new session calls `scripts/init.sh` before `scripts/verify.sh`.
- "Repo is broken" diagnoses are often init issues (missing .env, stale PIT, deps not installed).

### R11 — Secrets Never in Tracked Files

.env is gitignored. No PITs, tokens, webhook keys, or app secrets in any `.md` or `.sh` in the repo.

**Applied here:**
- .env.example has NAMES ONLY (e.g., `GHL_API_KEY=`).
- clients/*/credentials.md lists env var NAMES (e.g., `GHL_ADKINS_API_KEY`), never values.
- Verify.sh scans for secret patterns (pit-[...], EAA[...], etc.) and refuses commits if found.
- Hook (git pre-commit) runs verify.sh; failure blocks the commit.

**Failure mode:** GHL PIT leaks → entire agency compromised. No exceptions.

### R12 — Cross-Client Operations Are One Floor Above Single-Client Harness

A loop (bulk-report, onboard-subaccount) requires:
- Harness green (verification, state, scope all present).
- ≥2 active clients (not hypothetical; real client folders in clients/).
- Loop spec with explicit stop condition + cost cap (LOOPS.md).

**Applied here:**
- Feature F01–F06 are single-client (Adkins). Build, test, ship to Adkins first.
- L01 (bulk-report loop) is deferred until Adkins is live + second client exists.
- LOOPS.md will be created after harness audit passes + F07 (second client onboard) starts.

### R13 — Domain ≠ Harness

Business logic, niche rules, client-specific workflows: these are domain.  
Harness: environment, state, verification, control — domain-agnostic.

**Applied here:**
- HARNESS.md contains no mention of music schools, Adkins, GHL, or SMS workflows. Those are domain.
- HARNESS.md states rules like "secrets never in tracked files" and "one source of truth" — universal.
- Domain lives in docs/ (north-star.md, ghl-config.md, capabilities.md) and clients/ (client.md, credentials.md, notes.md).

**Enforcer:** Verify.sh checks CLAUDE.md for domain leakage (keywords: music, Adkins). Red = fix.

### R14 — Smallest Reversible Steps, Verify Each

Never bulk-rewrite 10 things, then run the gate. Change one thing, verify, move on. If a step breaks, the culprit is obvious.

**Applied here:**
- Harness lockdown: 7 steps, each with its own verify command. H01, verify. H02, verify. H03, verify. Never parallel.
- If H04 (HARNESS.md) fails verify, the problem is in H04, not in H01–H03 (which are already green).

### R15 — Match Structure to Size

A one-file spike doesn't need LOOPS.md. A 50-module system does. Scale the apparatus; never skip the record.

**Applied here:**
- ZiroWork is currently small (1 client, 1 team). Structure matches: router + verify gate + state + single-client feature scope.
- LOOPS.md will be added when we have 2+ clients and true cross-client ops.
- If ZiroWork grows to 500+ clients, we'll add per-module CONSTRAINTS.md and deeper doc tiering. Until then, current structure is correct.

---

## Enforced by the Gate

Verify.sh (scripts/verify.sh) runs these checks. All must pass (exit 0) for the repo to be correct:

| Rule | Check | Failure |
|------|-------|---------|
| R11 (Secrets never tracked) | SECRET SCAN: PITs, tokens, .env in tracked files | repo has leaked credentials |
| R11 (Secrets never tracked) | .env is gitignored + not tracked | secret exposure risk |
| R04 (No hardcoded IDs in scripts) | Scan scripts/ for Location ID patterns | scripts can't loop over clients (ID is hardcoded) |
| R02 (One source of truth) | Per-client folder shape (client.md, credentials.md, notes.md) | client data is scattered or missing |
| R03 (Router is thin + domain-free) | CLAUDE.md ≤ 100 lines | router is bloated |
| R03 (Router is domain-free) | CLAUDE.md has no domain keywords | domain logic leaked into harness |
| R05 (Primitives exist) | Gate, PROGRESS.md, DECISIONS.md, feature_list.json present | harness is incomplete |

---

## Crosswalk to REPO_BLUEPRINT.md

How this repo's rules map to the blueprint's B-rules and L-lectures.

| R | Concept | Blueprint | Lecture |
|---|---|---|---|
| R01 | Repo is source of truth | B01 | — |
| R02 | Exactly one source of truth | B11 | — |
| R03 | Router stays hot (≤100 lines, no domain) | B02, B03 | L03, L04 |
| R04 | Scope is data, not prose | B04 | L07, L08 |
| R05 | Primitives enforce; documents inform | B05 | L08, L09 |
| R06 | Command-checkable Definition of Done | B06 | — |
| R07 | Verification is highest-ROI subsystem | B10 | — |
| R08 | Cross-session state (PROGRESS + DECISIONS) | B08 | L05 |
| R09 | WIP=1 | B09 | — |
| R10 | Initialization is its own phase | B16 | L03, L06 |
| R11 | Secrets never in tracked files | R01 | (security specific) |
| R12 | Loops sit above green harness | B12 | LOOPS.md |
| R13 | Domain ≠ Harness | B15 (match size), anti-pattern | L01, L04 |
| R14 | Smallest reversible steps, verify each | B14 | — |
| R15 | Match structure to size | B15 | — |

---

## When Harness Fails

If verify.sh exits non-zero:

1. Read the failure message (specific check + why it failed).
2. Find the rule above (HARNESS.md R##).
3. Look up the enforcer (table above) to understand what the gate is checking.
4. Fix the repo to pass the check.
5. Re-run verify.sh. Exit 0 = fixed.

**Example:** "Hardcoded Location ID found in scripts/bulk-report.sh"
- Rule: R04 (No hardcoded IDs in scripts).
- Enforcer: Scan scripts/ for Location ID patterns.
- Fix: Replace `L80Q1SNMM4WQ0` in bulk-report.sh with `$SQUARE_LOCATION_OMAHA` or similar env var.
- Re-run: `bash scripts/verify.sh`. Should pass.

---

## This File Is Not Authority on Everything

HARNESS.md states the structural rules. For domain-specific decision criteria, operations details, or task definitions, read:

- **What ZiroWork is / why it works:** docs/north-star.md
- **GHL setup / MCP endpoint / Location IDs:** docs/ghl-config.md
- **The 15 capabilities / native vs. build:** docs/capabilities.md
- **Adkins business details / Square stack / Location IDs:** clients/adkins-music-lessons/client.md
- **Why each structural choice was made:** DECISIONS.md
- **Where we are / what's next:** PROGRESS.md
- **The procedure for structuring repos:** REPO_BLUEPRINT.md (generic; this repo specializes it)

---

## Last Updated

2026-06-25 (session: harness lockdown, Phase D Step 4)
