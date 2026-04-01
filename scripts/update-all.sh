#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# update-all.sh — Update shared config in all projects
# Usage: .ai-shared/scripts/update-all.sh ~/Code
# ─────────────────────────────────────────────

SEARCH_DIR="${1:-.}"

echo "🔍 Searching for projects with .ai-shared/ in: $SEARCH_DIR"
echo ""

FOUND=0
UPDATED=0
FAILED=0

for project in "$SEARCH_DIR"/*/; do
    if [ -d "$project/.ai-shared" ]; then
        FOUND=$((FOUND + 1))
        PROJECT_NAME=$(basename "$project")
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 $PROJECT_NAME"

        cd "$project"
        if .ai-shared/scripts/update.sh; then
            UPDATED=$((UPDATED + 1))

            # Auto-commit if there are changes
            if ! git diff --cached --quiet 2>/dev/null; then
                git commit -m "chore: update shared AI config" --no-verify
                echo "   📝 Committed update"
            else
                echo "   ⏭ Already up to date"
            fi
        else
            FAILED=$((FAILED + 1))
            echo "   ❌ Failed to update"
        fi
        echo ""
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Results: $FOUND found, $UPDATED updated, $FAILED failed"
