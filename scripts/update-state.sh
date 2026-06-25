#!/bin/bash

# Update state: append a timestamped session-entry stub to MEMORY.md
# Call this before committing to record progress and enable cross-session continuity.

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MEMORY_FILE="$REPO_ROOT/MEMORY.md"

# Get today's date in YYYY-MM-DD format
DATE=$(date +%Y-%m-%d)

# Append a new session entry stub to the session log (after the header, at the top of "Session Log")
# Format:
# ## [YYYY-MM-DD] Brief title of what was done
#
# - Bullet point summary
# - **Next:** What's next

# Find the line number of "# Session Log" and insert after it
LINE_NUM=$(grep -n "^# Session Log" "$MEMORY_FILE" | cut -d: -f1)

if [ -z "$LINE_NUM" ]; then
  echo "ERROR: Could not find '# Session Log' in $MEMORY_FILE"
  exit 1
fi

# Calculate the insertion line (right after "# Session Log" and its header line)
INSERT_LINE=$((LINE_NUM + 2))

# Create a temp file with the new entry
TEMP_FILE=$(mktemp)
head -n "$INSERT_LINE" "$MEMORY_FILE" > "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "## [$DATE] [TO BE FILLED: brief title]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "- [TO BE FILLED: bullet point summary]" >> "$TEMP_FILE"
echo "- **Next:** [TO BE FILLED: what's next]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
tail -n +$((INSERT_LINE + 1)) "$MEMORY_FILE" >> "$TEMP_FILE"

# Replace the original file
mv "$TEMP_FILE" "$MEMORY_FILE"

echo "✓ Session stub appended to MEMORY.md ([$DATE])"
echo "  → Please refresh CONTEXT.md's active-stage and next-step before commit"
echo "  → Update the session entry title and bullets in MEMORY.md"
