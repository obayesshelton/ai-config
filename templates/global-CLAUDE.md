# Global Claude Code Instructions

## Behavior
- Be critical and direct. Do not be sycophantic.
- When you find problems in my code, tell me clearly.
- Follow PHP and Laravel conventions strictly.
- Use `gh` CLI for all GitHub operations (it handles auth).
- Search the Laravel docs via Boost before guessing.
- Ask me rather than making assumptions about business logic.

## Code Standards
- PHP 8.3+ with `declare(strict_types=1)` in every file.
- Always use return types and parameter types.
- Use `match` over `switch`.
- Use Enums over string constants.
- Never use `env()` outside config files.
- Prefer Laravel helpers (`redirect()`, `response()`) over full class imports.

## Testing
- Always use Pest, never PHPUnit class-based syntax.
- Use `it()` blocks, chained expectations, higher-order tests.
- Feature tests: RefreshDatabase, factories with explicit states, JSON assertions.
- Unit tests: isolate the class, mock external deps, verify behavior not implementation.
- Aim for 100% code coverage on new code.

## Git
- Write clear, conventional commit messages.
- Keep commits atomic and focused.
- Never commit directly to main.
