Run the @test-writer agent. Write Pest tests for $ARGUMENTS.

If no arguments given, write tests for all files changed since the last commit that don't yet have corresponding test files.

After writing tests:
1. Run them: `php artisan test --filter=<new test files>`
2. Fix any failures
3. Check coverage: `php artisan test --coverage`
4. Report coverage percentage
