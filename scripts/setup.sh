#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# setup.sh — Wire shared AI config into project
# Run from project root: .ai-shared/scripts/setup.sh
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$(cd "$SHARED_DIR/.." && pwd)"

echo "🔧 Setting up AI shared config..."
echo "   Shared config: $SHARED_DIR"
echo "   Project root:  $PROJECT_DIR"

cd "$PROJECT_DIR"

# ─────────────────────────────────────────────
# 1. Create .claude/ directory with symlinks
# ─────────────────────────────────────────────
echo ""
echo "📁 Setting up .claude/ ..."

mkdir -p .claude

# Symlink agents (shared)
if [ -d .claude/agents ] && [ ! -L .claude/agents ]; then
    echo "   ⚠️  .claude/agents/ exists and is not a symlink. Backing up to .claude/agents.bak"
    mv .claude/agents .claude/agents.bak
fi
ln -sfn ../.ai-shared/claude/agents .claude/agents
echo "   ✓ .claude/agents → .ai-shared/claude/agents"

# Symlink commands (shared)
if [ -d .claude/commands ] && [ ! -L .claude/commands ]; then
    mv .claude/commands .claude/commands.bak
fi
ln -sfn ../.ai-shared/claude/commands .claude/commands
echo "   ✓ .claude/commands → .ai-shared/claude/commands"

# Copy hooks.json (not symlink — projects may need to extend it)
if [ ! -f .claude/hooks.json ]; then
    cp .ai-shared/claude/hooks.json .claude/hooks.json
    echo "   ✓ .claude/hooks.json copied (editable per-project)"
else
    echo "   ⏭ .claude/hooks.json already exists, skipping"
fi

# Create settings.json with sensible defaults if it doesn't exist
if [ ! -f .claude/settings.json ]; then
    cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(php artisan *)",
      "Bash(./vendor/bin/pest *)",
      "Bash(./vendor/bin/phpstan *)",
      "Bash(./vendor/bin/pint *)",
      "Bash(composer *)",
      "Bash(npm *)",
      "Bash(gh *)",
      "Bash(git *)"
    ]
  }
}
EOF
    echo "   ✓ .claude/settings.json created with Laravel defaults"
else
    echo "   ⏭ .claude/settings.json already exists, skipping"
fi

# ─────────────────────────────────────────────
# 2. Create .github/workflows/ with symlinks
# ─────────────────────────────────────────────
echo ""
echo "📁 Setting up .github/workflows/ ..."

mkdir -p .github/workflows

for workflow in .ai-shared/github/workflows/*.yml; do
    filename=$(basename "$workflow")
    if [ ! -f ".github/workflows/$filename" ]; then
        ln -sfn "../../.ai-shared/github/workflows/$filename" ".github/workflows/$filename"
        echo "   ✓ .github/workflows/$filename → .ai-shared/github/workflows/$filename"
    else
        echo "   ⏭ .github/workflows/$filename already exists, skipping"
    fi
done

# ─────────────────────────────────────────────
# 3. Create .ai/guidelines/ with symlinks
# ─────────────────────────────────────────────
echo ""
echo "📁 Setting up .ai/guidelines/ ..."

mkdir -p .ai/guidelines

for guideline in .ai-shared/guidelines/*.md; do
    filename=$(basename "$guideline")
    ln -sfn "../../.ai-shared/guidelines/$filename" ".ai/guidelines/$filename"
    echo "   ✓ .ai/guidelines/$filename → .ai-shared/guidelines/$filename"
done

# ─────────────────────────────────────────────
# 4. Merge project-specific overrides (.ai-local/)
# ─────────────────────────────────────────────
if [ -d .ai-local ]; then
    echo ""
    echo "📁 Merging project-specific overrides from .ai-local/ ..."

    # Link local agents alongside shared ones
    if [ -d .ai-local/agents ]; then
        for agent in .ai-local/agents/*.md; do
            [ -f "$agent" ] || continue
            filename=$(basename "$agent")
            ln -sfn "../../.ai-local/agents/$filename" ".claude/agents/$filename" 2>/dev/null || \
                echo "   ⚠️  Cannot symlink local agent $filename into shared agents dir (it's a symlink itself)"
            echo "   ✓ Local agent: $filename"
        done
    fi

    # Link local guidelines alongside shared ones
    if [ -d .ai-local/guidelines ]; then
        for guideline in .ai-local/guidelines/*.md; do
            [ -f "$guideline" ] || continue
            filename=$(basename "$guideline")
            ln -sfn "../../.ai-local/guidelines/$filename" ".ai/guidelines/$filename"
            echo "   ✓ Local guideline: $filename"
        done
    fi
fi

# ─────────────────────────────────────────────
# 5. Update .gitignore
# ─────────────────────────────────────────────
echo ""
echo "📝 Checking .gitignore ..."

GITIGNORE_ENTRIES=(
    "# AI local overrides (project-specific, not shared)"
    ".ai-local/"
    ""
    "# Boost MCP config (generated per-machine)"
    ".mcp.json"
)

for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if [ -z "$entry" ]; then
        continue
    fi
    if ! grep -qF "$entry" .gitignore 2>/dev/null; then
        echo "$entry" >> .gitignore
        echo "   ✓ Added to .gitignore: $entry"
    fi
done

# ─────────────────────────────────────────────
# 6. Check for AGENTS.md
# ─────────────────────────────────────────────
echo ""
if [ ! -f AGENTS.md ]; then
    echo "⚠️  No AGENTS.md found. Copy the template and fill in your project details:"
    echo "   cp .ai-shared/templates/AGENTS.md.example AGENTS.md"
else
    echo "✓ AGENTS.md exists"
fi

# ─────────────────────────────────────────────
# 7. Check for Boost
# ─────────────────────────────────────────────
if [ -f artisan ]; then
    if ! grep -q "laravel/boost" composer.json 2>/dev/null; then
        echo ""
        echo "💡 Laravel Boost not installed. Run:"
        echo "   composer require laravel/boost --dev"
        echo "   php artisan boost:install"
    fi
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit AGENTS.md with your project details"
echo "  2. Run: composer require laravel/boost --dev && php artisan boost:install"
echo "  3. Start Claude Code: claude"
