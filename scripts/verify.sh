#!/bin/bash

# Verification gate for ZiroWork repo.
# ONE command. Non-zero exit on any failure. Binding (run via pre-commit hook).
# Exit 0 = repo is correct. Exit non-zero = repo has a problem.

set -e

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_ROOT"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

fail_count=0

# Helper: print status
pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; fail_count=$((fail_count + 1)); }

echo "=== ZiroWork Verification Gate ==="
echo

# ============================================================================
# 1. SECRET SCAN (priority #1)
# ============================================================================
echo "Checking for secrets..."

# Check for GHL PIT pattern (pit-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
if git ls-files | xargs grep -l 'pit-[a-f0-9]\{8\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{12\}' 2>/dev/null || false; then
  fail "GHL PIT found in tracked files"
else
  pass "No GHL PITs in tracked files"
fi

# Check for bearer token pattern (Bearer [long-string])
if git ls-files | xargs grep -l 'Bearer [A-Za-z0-9_-]\{50,\}' 2>/dev/null || false; then
  fail "Bearer token found in tracked files"
else
  pass "No bearer tokens in tracked files"
fi

# Check for Square access token pattern (EAA[A-Z...])
if git ls-files | xargs grep -l 'EAA[A-Za-z0-9_-]\{50,\}' 2>/dev/null || false; then
  fail "Square access token found in tracked files"
else
  pass "No Square tokens in tracked files"
fi

# Check .env* is gitignored (but .env.example is OK — it's the template)
if git ls-files | grep -E '^\.env' | grep -v '\.env\.example' || false; then
  fail ".env files are tracked in git (should be gitignored)"
else
  pass ".env files not tracked (gitignored correctly)"
fi

# Check .gitignore contains .env* patterns
if ! grep -q '\.env' .gitignore; then
  fail ".gitignore does not block .env files"
else
  pass ".gitignore blocks .env files"
fi

echo

# ============================================================================
# 2. NO HARDCODED LOCATION IDs IN SCRIPTS
# ============================================================================
echo "Checking for hardcoded Location IDs in scripts..."

# Location ID patterns (L followed by 12 uppercase alphanumeric, or yh... for agency)
if grep -r 'L[A-Z0-9]\{12\}\|yh[A-Za-z0-9]\{32\}' scripts/ --include="*.sh" --include="*.js" --include="*.py" 2>/dev/null || false; then
  fail "Hardcoded Location IDs found in scripts/ (use env vars instead)"
else
  pass "No hardcoded Location IDs in scripts/"
fi

echo

# ============================================================================
# 3. PER-CLIENT SHAPE CHECK (conditional: skip if clients/ is gitignored/absent)
# ============================================================================
echo "Checking per-client folder structure..."

if [ ! -d "clients" ]; then
  # On a fresh clone, clients/ is gitignored and absent. This is OK.
  pass "clients/ absent (fresh clone; gitignored — OK)"
else
  # clients/ exists locally; validate per-client shape
  if [ ! -d "clients/adkins" ]; then
    fail "clients/adkins/ missing"
  else
    pass "clients/adkins/ exists"

    # Check required files
    if [ ! -f "clients/adkins/client.md" ]; then
      fail "  → clients/adkins/client.md missing"
    else
      pass "  → client.md present"
    fi

    if [ ! -f "clients/adkins/credentials.md" ]; then
      fail "  → clients/adkins/credentials.md missing"
    else
      pass "  → credentials.md present"

      # Verify credentials.md doesn't contain actual secret values (not placeholders with $)
      if grep -E 'pit-[a-f0-9]{8,}|EAA[a-zA-Z0-9]{50,}' "clients/adkins/credentials.md" || false; then
        fail "  → credentials.md contains actual secret values (should only have env var names)"
      else
        pass "  → credentials.md has names only (no values)"
      fi
    fi

    if [ ! -f "clients/adkins/notes.md" ]; then
      fail "  → clients/adkins/notes.md missing"
    else
      pass "  → notes.md present"
    fi
  fi
fi

echo

# ============================================================================
# 4. ROUTER LINT
# ============================================================================
echo "Checking router (CLAUDE.md)..."

if [ ! -f "CLAUDE.md" ]; then
  fail "CLAUDE.md missing"
else
  pass "CLAUDE.md exists"

  # Check line count (should be ≤ ~100 lines)
  line_count=$(wc -l < CLAUDE.md)
  if [ "$line_count" -gt 120 ]; then
    fail "  → CLAUDE.md is $line_count lines (max ~100, keep it thin)"
  else
    pass "  → CLAUDE.md is $line_count lines (within limit)"
  fi

  # Check for domain logic (keywords: music school, Adkins, client name, business logic)
  if grep -i 'music school\|adkins' CLAUDE.md || false; then
    fail "  → CLAUDE.md contains domain logic (should be generic router only)"
  else
    pass "  → CLAUDE.md is domain-free"
  fi

  # Check router references MEMORY.md, AGENTS.md, CONTEXT.md
  if grep -q 'MEMORY.md' CLAUDE.md && grep -q 'AGENTS.md' CLAUDE.md && grep -q 'CONTEXT.md' CLAUDE.md; then
    pass "  → CLAUDE.md references MEMORY/AGENTS/CONTEXT (router pattern OK)"
  else
    fail "  → CLAUDE.md missing reference to MEMORY.md, AGENTS.md, or CONTEXT.md"
  fi
fi

echo

# ============================================================================
# 5. REQUIRED STRUCTURAL ARTIFACTS
# ============================================================================
echo "Checking harness artifacts..."

if [ ! -f "MEMORY.md" ]; then
  fail "MEMORY.md missing (required)"
else
  pass "MEMORY.md exists"
fi

if [ ! -f "AGENTS.md" ]; then
  fail "AGENTS.md missing (required)"
else
  pass "AGENTS.md exists"
fi

if [ ! -f "CONTEXT.md" ]; then
  fail "CONTEXT.md missing (required)"
else
  pass "CONTEXT.md exists"
fi

if [ ! -f "DECISIONS.md" ]; then
  fail "DECISIONS.md missing (required)"
else
  pass "DECISIONS.md exists"
fi

if [ ! -f "feature_list.json" ]; then
  fail "feature_list.json missing (required)"
else
  pass "feature_list.json exists"
fi

echo

# ============================================================================
# 6. HOOKS WIRED
# ============================================================================
echo "Checking hook wiring..."

if [ -d ".githooks" ] || [ -d ".husky" ]; then
  pass "Hook directory exists"
else
  echo "⚠ Hook directory missing (will be set up in hook-wire step)"
fi

echo

# ============================================================================
# 7. DOC GRAPH & HYGIENE (links, orphans, headers, one-now, WIP)
# ============================================================================
echo "Checking doc graph (links / orphans / headers / one-now / WIP)..."

if node scripts/check-docs.mjs; then
  pass "Doc graph clean"
else
  fail "Doc graph has problems (see above)"
fi

echo

# ============================================================================
# 8. SHELL LINT (shellcheck — skipped if not installed)
# ============================================================================
echo "Linting shell scripts..."

if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck -S error scripts/*.sh .githooks/* 2>/dev/null; then
    pass "shellcheck: no error-level findings"
  else
    fail "shellcheck found error-level problems (see above)"
  fi
else
  echo -e "${RED}⚠ SHELL SCRIPTS UNCHECKED${NC} — shellcheck not installed; scripts/*.sh + hooks were NOT linted (run: scoop install shellcheck)"
fi

echo

# ============================================================================
# 9. SCRIPT SYNTAX (node --check on every tracked .mjs/.js)
# ============================================================================
echo "Checking JS/MJS syntax..."

syntax_bad=0
while IFS= read -r jsf; do
  [ -z "$jsf" ] && continue
  if ! node --check "$jsf" 2>/dev/null; then
    fail "  → syntax error in $jsf"
    syntax_bad=1
  fi
done < <(git ls-files '*.mjs' '*.js')
if [ "$syntax_bad" -eq 0 ]; then
  pass "All tracked .mjs/.js parse"
fi

echo

# ============================================================================
# 10. RAVEN ENROLLMENT AGENT GATE (clients/ is gitignored — run if present)
# ============================================================================
echo "Checking Raven enrollment agent (if present)..."

RAVEN_DIR="clients/adkins/raven-scripts/_enrollment-agent"
if [ ! -d "$RAVEN_DIR" ]; then
  pass "Raven agent absent (gitignored/fresh clone — OK)"
elif ! command -v node >/dev/null 2>&1; then
  echo -e "${RED}⚠ Raven agent UNCHECKED${NC} — node not found"
else
  if ( cd "$RAVEN_DIR" && node data/validate.mjs >/dev/null 2>&1 && node --test src/raven.test.ts >/dev/null 2>&1 && node evals/run.ts >/dev/null 2>&1 ); then
    pass "Raven agent: data validates + tests + evals pass"
  else
    fail "Raven agent: gate FAILED — run: (cd $RAVEN_DIR && npm run check)"
  fi
fi

echo

# ============================================================================
# SUMMARY
# ============================================================================
echo "=== Summary ==="
if [ $fail_count -eq 0 ]; then
  echo -e "${GREEN}All checks passed (exit 0)${NC}"
  exit 0
else
  echo -e "${RED}$fail_count check(s) failed (exit 1)${NC}"
  exit 1
fi
