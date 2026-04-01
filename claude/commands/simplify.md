Run the @laravel-simplifier agent on all files changed since the last commit.

Steps:
1. Identify changed files with `git diff --name-only HEAD`
2. Simplify each file following Taylor Otwell's Laravel philosophy
3. Run tests after each file to verify behavior is unchanged
4. Summarize what was simplified
