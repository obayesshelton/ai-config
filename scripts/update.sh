#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# update.sh — Pull latest shared config and re-link
# Run from project root: .ai-shared/scripts/update.sh
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_DIR"

echo "🔄 Updating shared AI config..."

# Pull latest submodule
cd .ai-shared
git pull origin main
cd "$PROJECT_DIR"

# Re-run setup to catch any new files
.ai-shared/scripts/setup.sh

# Stage the submodule update
git add .ai-shared

echo ""
echo "✅ Updated. Review changes with: git diff --cached"
echo "   Then commit: git commit -m 'chore: update shared AI config'"
