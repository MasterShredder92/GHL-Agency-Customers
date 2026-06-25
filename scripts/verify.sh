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
fail() { echo -e "${RED}✗${NC} $1"; ((fail_count++)); }

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
# 3. PER-CLIENT SHAPE CHECK
# ============================================================================
echo "Checking per-client folder structure..."

if [ ! -d "clients/adkins-music-lessons" ]; then
  fail "clients/adkins-music-lessons/ missing"
else
  pass "clients/adkins-music-lessons/ exists"

  # Check required files
  if [ ! -f "clients/adkins-music-lessons/client.md" ]; then
    fail "  → clients/adkins-music-lessons/client.md missing"
  else
    pass "  → client.md present"
  fi

  if [ ! -f "clients/adkins-music-lessons/credentials.md" ]; then
    fail "  → clients/adkins-music-lessons/credentials.md missing"
  else
    pass "  → credentials.md present"

    # Verify credentials.md doesn't contain actual secret values (not placeholders with $)
    if grep -E 'pit-[a-f0-9]{8,}|EAA[a-zA-Z0-9]{50,}' "clients/adkins-music-lessons/credentials.md" || false; then
      fail "  → credentials.md contains actual secret values (should only have env var names)"
    else
      pass "  → credentials.md has names only (no values)"
    fi
  fi

  if [ ! -f "clients/adkins-music-lessons/notes.md" ]; then
    fail "  → clients/adkins-music-lessons/notes.md missing"
  else
    pass "  → notes.md present"
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
fi

echo

# ============================================================================
# 5. REQUIRED STRUCTURAL ARTIFACTS
# ============================================================================
echo "Checking harness artifacts..."

if [ ! -f "HARNESS.md" ]; then
  echo "⚠ HARNESS.md missing (will be created in next step)"
else
  pass "HARNESS.md exists"
fi

if [ ! -f "PROGRESS.md" ]; then
  echo "⚠ PROGRESS.md missing (will be created in next step)"
else
  pass "PROGRESS.md exists"
fi

if [ ! -f "DECISIONS.md" ]; then
  echo "⚠ DECISIONS.md missing (will be created in next step)"
else
  pass "DECISIONS.md exists"
fi

if [ ! -f "feature_list.json" ]; then
  echo "⚠ feature_list.json missing (will be created in next step)"
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
