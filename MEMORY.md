# Who Zach Is

**Zach Adkins** runs ZiroWork, a done-for-you customer-acquisition service for service-based businesses. The service sits in front of a client's booking/billing (Square, Stripe, etc.); never replaces it. GHL is the engine; Claude Code is the control layer (MCP + API, not dashboard).

**Work style:** Decides and commits. Wants behavior over self-reports, answer-first, map-first, correction over agreement, one question at a time.

---

# Session Log (Newest on Top)

## [2026-06-25] Restructured CLAUDE.md → MEMORY/AGENTS/CONTEXT router

## [2026-06-26] Fixed GHL API v1→v2 migration (endpoint 404 root cause)

- Identified and fixed 404 error: scripts were using `/v1/` endpoint path on v2 host (incompatible)
- Root cause: v1 reached end-of-support 2025-12-31; v2 has no `/v1/` namespace
- Fixed setup-crm-foundation.mjs: changed BASE_URL to v2 host (services.leadconnectorhq.com), added Version: 2021-07-28 header
- Verified location ID is correct (TCahcPK9X1pptNjBJxP3 — Adkins sub-account)
- Updated CONTEXT.md with v2 test plan; verified repo with gate (exits 0 ✓)
- Committed fix to main (f7a3c7f)
- **Next:** Test setup script with rotated API key; verify custom fields/tags/pipeline created in GHL


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
