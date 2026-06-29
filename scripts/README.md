<!--
FILE:       scripts/README.md
WHAT:       Index of every script in scripts/ — what each does and when to run it
READ WHEN:  Before running or editing anything in scripts/; when you need the gate, init, or a helper and don't know which file
SKIP WHEN:  Pure doc/markdown work with no script involved
ROUTES TO:  CLAUDE.md — repo router | AGENTS.md — R01 secrets-in-.env rule these scripts honor | feature_list.json — scope items some scripts implement
HARD RULES: Secrets ONLY from .env (never hardcoded); the gate (verify.sh) is non-bypassable via the pre-commit hook; STUB scripts are not yet implemented — do not assume they work
-->

# Scripts

What each script does and when to run it. The gate is the one you run by hand; most others are helpers Claude Code or the hooks invoke.

## Gate & validation
| Script | What | When to run |
|---|---|---|
| `verify.sh` | The verification gate. Runs every check (secrets, IDs, router lint, doc graph, syntax); exit 0 = repo correct. | Before every commit. The `.githooks/pre-commit` hook runs it automatically — your commit is refused on non-zero exit. |
| `check-docs.mjs` | Doc reference-graph + hygiene validator (LINKS / ORPHANS / HEADERS / ONE-NOW / WIP). Called **by** `verify.sh`. | Not run by hand; edit it to add/adjust a doc check. |

## Environment & auth
| Script | What | When to run |
|---|---|---|
| `init.sh` | One-shot standup: `.env` from `.env.example`, deps, GHL MCP reachable, PIT valid. | Once on a fresh clone, before any feature work. |
| `ghl-mcp-headers.js` | Prints the GHL MCP auth header, reading the live token from `.env` (single source). Wired as `headersHelper` in `.mcp.json`. | Never by hand — Claude Code runs it on each MCP connection. |
| `extract-env-vars.sh` | Reads GHL credentials from `.env.local` and emits JSON for Claude Code. | When bootstrapping local credentials. |

## State & setup
| Script | What | When to run |
|---|---|---|
| `update-state.sh` | Appends a timestamped session-entry stub to `MEMORY.md` (save-and-update). | At session end, before committing. |
| `setup-crm-foundation.mjs` | Provisions the Adkins GHL foundation (custom fields, tags) via the v2 API. Pipelines/workflows stay UI-only. | One-time, per sub-account foundation build. |

## Client ops (stubs — implement when needed)
| Script | What | When to run |
|---|---|---|
| `onboard-subaccount.sh` | **STUB.** Scaffold a new client folder + GHL sub-account. | Implement when onboarding client #2 (F07). |
| `deploy-snapshot.sh` | **STUB.** Push a standard GHL snapshot to a client sub-account. | Implement when scaling a proven setup. |
| `bulk-report.sh` | Cross-client reporting. Becomes a capped daily loop once ≥2 clients exist. | Manually for now; loop after L01. |
