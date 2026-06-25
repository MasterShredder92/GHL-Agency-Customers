# ZiroWork — Control Layer for GHL Agency

**Read [MEMORY.md](./MEMORY.md) first** — who Zach is and what happened last session.  
**Read [AGENTS.md](./AGENTS.md) before doing anything else** — all hard rules.  
**Read [CONTEXT.md](./CONTEXT.md)** — the active stage and where to go next.

---

## Repo Structure

```
docs/                          # Domain docs (what ZiroWork is, GHL setup, capabilities)
├── north-star.md              # What ZiroWork is, frame, two honest limits
├── ghl-config.md              # GHL setup, MCP endpoint, agency account, scopes
└── capabilities.md            # 15 core capabilities (native vs. build)

clients/                        # Client folders (sealed; one per customer)
├── _index.md                  # Client roster
└── <client-slug>/             # Each client: client.md, credentials.md, notes.md

scripts/                        # Repeatable jobs
├── verify.sh                  # Verification gate (exits 0/1)
├── init.sh                    # One-shot environment / record setup
└── update-state.sh            # Append session entry to MEMORY.md

snapshots/                      # Deployment snapshots (what each contains, how to build/deploy)

CLAUDE.md                       # This file (router; ≤100 lines, no domain)
MEMORY.md                       # Session log + "who Zach is" (append-only)
AGENTS.md                       # Hard rules canon (R01–R15)
CONTEXT.md                      # Current stage + next step + last checkpoint
DECISIONS.md                    # Why each structural choice was made (append-only)
feature_list.json              # Scope: priority, dependsOn, state, verify per item
.env.example                   # Template (names only, no secrets)
.env                           # Secrets (gitignored, local only)
```

---

## One Sentence Each

- **GHL Agency = ZiroWork.** One account for all clients.
- **Secrets ONLY in `.env` (gitignored).** Never in repo files.
- **Repo is source of truth.** If it's not in the repo, it doesn't exist.
- **MCP for live tasks. Scripts for repeatable, bulk, or multi-client jobs.**
- **Each client is sealed.** Claude reads only the relevant folder before operating.
