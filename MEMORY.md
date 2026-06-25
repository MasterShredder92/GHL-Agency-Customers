# Who Zach Is

**Zach Adkins** runs ZiroWork, a done-for-you customer-acquisition service for service-based businesses. The service sits in front of a client's booking/billing (Square, Stripe, etc.); never replaces it. GHL is the engine; Claude Code is the control layer (MCP + API, not dashboard).

**Work style:** Decides and commits. Wants behavior over self-reports, answer-first, map-first, correction over agreement, one question at a time.

---

# Session Log (Newest on Top)

## [2026-06-25] Restructured CLAUDE.md → MEMORY/AGENTS/CONTEXT router

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
