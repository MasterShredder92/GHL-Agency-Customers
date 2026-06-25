#!/bin/bash

# Initialization: Stand up the record and environment for ZiroWork repo.
# Run this FIRST in any new session, before any feature work.
# Sets up: .env from template, git hooks, checks MCP/PIT.

set -e

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=== ZiroWork Initialization ==="
echo

# ============================================================================
# 1. CHECK IF .env EXISTS; CREATE FROM TEMPLATE IF NOT
# ============================================================================
echo "Step 1: Environment file (.env)..."

if [ -f ".env" ]; then
  echo -e "${GREEN}✓${NC} .env exists"
else
  echo -e "${YELLOW}⚠${NC}  .env not found. Creating from .env.example..."
  cp .env.example .env
  echo -e "${GREEN}✓${NC} .env created"
  echo
  echo "⚠️  TODO: Populate .env with your actual secrets:"
  echo "   - GHL_API_KEY (agency)"
  echo "   - GHL_ADKINS_API_KEY (sub-account)"
  echo "   - SQUARE_ACCESS_TOKEN, SQUARE_APP_ID, SQUARE_APP_SECRET"
  echo "   - All SQUARE_LOCATION_* variables"
  echo "   Then re-run: bash scripts/init.sh"
  echo
fi

echo

# ============================================================================
# 2. LOAD .env AND VERIFY REQUIRED VARS
# ============================================================================
echo "Step 2: Verifying required environment variables..."

if [ ! -f ".env" ]; then
  echo -e "${RED}✗${NC} .env not found and could not be created"
  exit 1
fi

source .env

# Check for required vars (non-empty values)
required_vars=("GHL_API_KEY" "GHL_ADKINS_API_KEY" "SQUARE_ACCESS_TOKEN" "SQUARE_APP_ID")
missing_vars=()

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -gt 0 ]; then
  echo -e "${YELLOW}⚠${NC}  Missing or empty environment variables:"
  for var in "${missing_vars[@]}"; do
    echo "   - $var"
  done
  echo
  echo "Fill in .env and run again."
  exit 1
else
  echo -e "${GREEN}✓${NC} Required environment variables present"
fi

echo

# ============================================================================
# 3. INITIALIZE GIT & WIRE HOOKS
# ============================================================================
echo "Step 3: Git initialization and hook wiring..."

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${YELLOW}⚠${NC}  Not a git repo yet. Initializing..."
  git init
  echo -e "${GREEN}✓${NC} Git repo initialized"
fi

# Wire .githooks as the git hooks directory
git config core.hooksPath .githooks || {
  echo -e "${YELLOW}⚠${NC}  Could not set core.hooksPath. This may require manual setup."
  echo "   Run: git config core.hooksPath .githooks"
}

# Make pre-commit hook executable
chmod +x .githooks/pre-commit 2>/dev/null || true
echo -e "${GREEN}✓${NC} Git hooks wired (pre-commit will run on git commit)"

echo

# ============================================================================
# 4. VERIFY REPO STRUCTURE
# ============================================================================
echo "Step 4: Verifying repo structure..."

bash scripts/verify.sh

if [ $? -ne 0 ]; then
  echo -e "${RED}✗${NC} Verification gate failed. Fix the issues above."
  exit 1
fi

echo

# ============================================================================
# 5. CHECK GHL MCP ENDPOINT REACHABILITY (OPTIONAL)
# ============================================================================
echo "Step 5: Checking GHL MCP endpoint reachability..."

if command -v curl &> /dev/null; then
  if curl -s -o /dev/null -w "%{http_code}" "https://services.leadconnectorhq.com/mcp/" | grep -q "200\|401\|403"; then
    echo -e "${GREEN}✓${NC} GHL MCP endpoint is reachable"
  else
    echo -e "${YELLOW}⚠${NC}  GHL MCP endpoint unreachable (network issue? check URL in docs/ghl-config.md)"
  fi
else
  echo -e "${YELLOW}⚠${NC}  curl not found; skipping endpoint check"
fi

echo

# ============================================================================
# SUMMARY
# ============================================================================
echo "=== Initialization Complete ==="
echo -e "${GREEN}✓${NC} Repo is ready for feature work"
echo
echo "Next steps:"
echo "  1. Read PROGRESS.md (where we are)"
echo "  2. Check feature_list.json (what to work on)"
echo "  3. Start the next feature: bash scripts/verify.sh (to confirm gate is working)"
echo
