<!--
FILE:       CONTEXT.md
WHAT:       Current active stage, status, and next steps (rewritten each session to reflect truth). The single source for "where are we / what's next."
READ WHEN:  Every session start; before resuming work or deciding what to do next.
SKIP WHEN:  Pure domain-doc reading or rule auditing with no session state needed.
ROUTES TO:  clients/adkins/raven-scripts/_enrollment-agent/REAL-FLOW.md (the grounded flow) · clients/adkins/raven-scripts/_enrollment-agent/TEST-LOG.md (findings) · clients/adkins/raven-scripts/_enrollment-agent/ARCHITECTURE-AND-PLAN.md (§13 phases) · AGENTS.md (rules)
HARD RULES: Rewrite each session (not append); one active stage; next step must be command-checkable (R06). This file is the canonical now+next — keep it true.
-->

# Active Stage & Next Step

**Active Stage:** **Raven runtime BUILT (P0 + P1 deterministic core) and rebuilt from the REAL threads. In dry-run scenario testing. NEXT = P2 Square booking + adult-voice fix.**

The agent now runs end-to-end on the developer's machine (dry-run, nothing sent). Two real leads (Paul, Andrew) go opener→…→BOOKED clean. Booking + LLM + live GHL are still stubbed seams.

> ⚠️ **The agent lives in `clients/adkins/raven-scripts/_enrollment-agent/` which is GITIGNORED (clients/ holds real customer PII from `_quo-pull`). So the agent code is NOT in git — it is local-only. A backup/versioning plan is needed (own repo for the engine sans PII, or a backup).**

---

## Status (true as of this session)
- ✅ **P0 data plane:** `data/{state-machine,pricing,runtime}.json` build + validate against schemas. `pricing.json` LOCKED = $200 single / $180 military-or-2–3 / $160 4+ / $400 2x / $50 promo / $320 referral.
- ✅ **P1 reply loop (deterministic core):** ingest→identify→context→classify→route→select→**validate**→send→update, as pure TS (`src/`), Node runs `.ts` directly (no build). Seams stubbed: classifier = keyword stub (LLM later), store = in-memory (GHL adapter later), sender = dry-run, **booker** seam added (Square later).
- ✅ **Rebuilt from REAL data:** mined all 50 `_quo-pull/threads/*.txt` (32 signed) → **REAL-FLOW.md** (skeleton + side-quests + steer-back). `state-machine.json` is now a **steering** FSM (each state has an `objective`; side-quests answer + return to flow). `runtime.json` = **44 verbatim real templates**. Synthetic `variants-corpus.md` quarantined → `_deprecated-synthetic/`.
- ✅ **Model aligned to the real GHL form:** First/Last = **student**; **Preferred Time** = availability window (e.g. "Saturday 10am-3p"), not a day; Military? / Has-Instrument? / Student-Age / Skill-Level fields wired.
- ✅ **Self-defending:** `npm run check` = data validate + content audit (slots/banned/price/drift) + 20 unit tests + **4 golden-conversation evals** (`evals/cases.json`). Wired into `scripts/verify.sh` → `.githooks/pre-commit` → a regression **refuses the commit**. Runtime pre-send validator blocks bad sends always.
- ✅ **Testing loop:** `src/chat.ts` dry-run harness (Zach plays customer); every finding logged in **TEST-LOG.md** (15 corrections, each traced + tested).

---

## What's Next (in order)
1. **Adult-voice fix** (open finding): adult self-learners (Student Age ≥ ~16) are addressed in 3rd person ("get him set up", "lessons for Andrew"). Drive 2nd-person ("you/your") off Student Age / who_for. Add an eval case.
2. **P2 — Close & book (Square):** teacher match (TEACHER-PROFILES + Square `searchAvailability`) → idempotent `bookings.create` behind the existing `book` seam; confirm only after a real booking; fail → HUMAN_REVIEW. Fills the booking-gated slots (offer real times, teacher).
3. **LLM classifier:** replace the keyword stub behind `Classifier` (Claude structured output, history-aware, multi-intent) — keep STOP fast-path. Carry the evals over to guard it.
4. **Live GHL adapter + webhook:** `Store`/`Sender` against the real API (needs `GHL_RAVEN_TOKEN` + custom-field IDs). Then P3 outbound opener + drip loop.

---

## Open blockers / notes
- Agent code is **gitignored (local-only)** — see warning above; decide a backup plan.
- WIP=1 (feature_list.json). Secrets ONLY in `.env`. `clients/` stays gitignored.
- **Gate:** `cd clients/adkins/raven-scripts/_enrollment-agent && npm run check` must exit 0; repo gate `bash scripts/verify.sh` runs it too (pre-commit).
- `clients/adkins/src/lib/ghl.ts` `createGHLContact` still a reference helper, not wired (P3 form intake).
