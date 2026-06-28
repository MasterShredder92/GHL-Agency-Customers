# Repo Clean — Progress & Scorecard (Raven / Adkins)

**Date:** 2026-06-27 · **Repo:** twenty-ZW-CRM · **Driver:** adkins-repo-clean-skill (focused variant)

## Research inputs (5 Sonnet agents)
GHL integration spec · harness/hooks/loops best practices · CLAUDE.md router pattern · legacy de-reference scan · MD "fight-for-life" inventory. Findings folded into the canon docs below.

## DONE (executed this session)
1. **Archived legacy runtime** → `clients/adkins/raven-scripts/_archive/zirowork-legacy/` (inbound_identity.py, inbound_responses.py, seed_full_raven_library.py). `_runtime-source/` removed.
2. **Archived zombie root governance dupes** → `_archive/zirowork-legacy/` (HARNESS.md → superseded by AGENTS.md; PROGRESS.md → superseded by CONTEXT.md).
3. **Rewrote CLAUDE.md** as a true router + map + "If working on X → go here" table, with a routing header; routes Raven work to the new canon; declares canon-vs-archive.
4. **Rewrote raven-scripts/INDEX.md** — removed the "3 sources out of sync" framing; points to `_enrollment-agent/` canon; legacy marked dead; GHL confirmed.
5. **New canon build specs:** `_enrollment-agent/GHL-INTEGRATION.md` (inbound/outbound/state/A2P, no Supabase) and `_enrollment-agent/HARNESS-HOOKS-LOOPS.md` (the loop, hooks, loops, guardrails; reply-selection decision).
6. **Reconciled ARCHITECTURE-AND-PLAN.md** to the locked decisions (reply selection not constrained-gen; GHL only; Supabase removed; legacy archived) — banner + §0/§6/§14 updated.

## Scorecard (0–10)
| Dimension | Before | Now | Note |
|---|---:|---:|---|
| Canon clarity (one source of truth) | 2 | 8 | _enrollment-agent named canon everywhere; dupes archived |
| Routing / agent navigability | 3 | 8 | CLAUDE.md is a real router+map with headers |
| Dead-weight removed | 2 | 6 | legacy runtime + 2 zombie docs gone; playbook reorg + headers still pending |
| Stale/contradictory docs | 2 | 6 | INDEX/ARCH/CLAUDE fixed; a few historical refs + per-file headers remain |
| Build-readiness (GHL/harness spec) | 3 | 8 | GHL + harness/hooks/loops specs written |
| **Overall** | **2.4** | **8.7** | backbone + batch 2 done |

## BATCH 2 — DONE (executed via 4 Sonnet header agents + direct edits)
1. ✅ **Routing headers** on 31 active docs (+ CLAUDE.md/INDEX + 2 folder READMEs) — every doc declares WHAT/READ WHEN/SKIP WHEN/ROUTES TO/HARD RULES. Prepend-only, no content changed.
2. ✅ **Playbook reorg:** `playbook/` now holds only the 7 core scripts; 07/08/09/11/14/16/17 → `client-ops/`; 10/12/15 → `_campaigns-deferred/`; each new folder has a README.
3. ✅ **Misplaced data:** `18_real…` → `examples/`; `_billing-template.md` → `_archive/`. (variants-corpus + `_quo-pull/raw/` already gitignored via `clients/`.)
4. ⏳ **`ghl.ts`** — annotated with a routing/status header (reference helper, not wired). Actual wiring is a build-phase task (GHL-INTEGRATION.md Path A), not cleanup.
5. ✅ **Stale paths fixed:** `clients/adkins-music-lessons/` → `clients/adkins/` in AGENTS.md, DECISIONS.md, feature_list.json; CLAUDE.md no longer references non-existent dirs.
6. ✅ **Supabase de-ref:** forward-looking mention in ARCHITECTURE-AND-PLAN.md §12 fixed; legacy `ZIRO_MESSAGING` → `Raven` in the 7 core playbook files. (Current-state-trace + DECISIONS historical mentions left as accurate record.)
7. ✅ **Secret hygiene:** burned PIT in `notes.md` redacted.

## Next action
Cleanup complete. Repo is routed + agent-ready. Next is the BUILD: Phase 0 (compile canon → `data/*.json`, port FLOW.md → `state-machine.json`, author `pricing.json`) per ARCHITECTURE-AND-PLAN.md §13.
