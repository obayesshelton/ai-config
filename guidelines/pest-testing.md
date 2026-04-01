# Pest Testing Conventions

## General Rules

- Use `it()` blocks exclusively. Never use `test()` or PHPUnit class-based syntax.
- Use `describe()` to group related tests.
- Use `beforeEach()` for shared setup. Do not repeat setup across tests.
- Use chained expectations: `expect($x)->toBe(1)->and($y)->toBeNull()`
- Use higher-order tests when they improve readability.
- Every test should test ONE behavior. If you write "and" in the test name, split it.

## Feature Tests (API / HTTP)

```php
use App\Models\User;
use App\Models\Contact;

describe('ContactController', function () {
    beforeEach(function () {
        $this->user = User::factory()->create();
    });

    describe('store', function () {
        it('creates a contact with valid data', function () {
            $data = Contact::factory()->make()->toArray();

            actingAs($this->user)
                ->postJson(route('contacts.store'), $data)
                ->assertCreated()
                ->assertJsonStructure(['data' => ['id', 'name', 'email']]);

            expect(Contact::count())->toBe(1);
        });

        it('rejects unauthenticated requests', function () {
            postJson(route('contacts.store'), [])
                ->assertUnauthorized();
        });

        it('validates required fields', function () {
            actingAs($this->user)
                ->postJson(route('contacts.store'), [])
                ->assertUnprocessable()
                ->assertJsonValidationErrors(['name', 'email']);
        });

        it('rejects duplicate emails', function () {
            $existing = Contact::factory()->create(['email' => 'taken@example.com']);

            actingAs($this->user)
                ->postJson(route('contacts.store'), [
                    'name' => 'New Contact',
                    'email' => 'taken@example.com',
                ])
                ->assertUnprocessable()
                ->assertJsonValidationErrors(['email']);
        });
    });
});
```

## What Every Feature Test Should Cover

For each endpoint, write tests for:
1. **Happy path** — valid input, authorized user, expected outcome
2. **Authentication** — unauthenticated returns 401
3. **Authorization** — wrong role/permission returns 403
4. **Validation** — each required field, each validation rule
5. **Edge cases** — empty collections, null relationships, boundary values
6. **Side effects** — jobs dispatched, events fired, notifications sent

Use fakes for side effects:
```php
it('sends a welcome email', function () {
    Notification::fake();

    actingAs($this->user)
        ->postJson(route('contacts.store'), $data);

    Notification::assertSentTo($contact, WelcomeNotification::class);
});
```

## Unit Tests

```php
describe('PriceCalculator', function () {
    it('calculates subtotal', function () {
        $calculator = new PriceCalculator(items: [
            new LineItem(price: 1000, quantity: 2),
            new LineItem(price: 500, quantity: 1),
        ]);

        expect($calculator->subtotal())->toBe(2500);
    });

    it('applies percentage discount', function () {
        $calculator = new PriceCalculator(items: [
            new LineItem(price: 1000, quantity: 1),
        ]);

        expect($calculator->withDiscount(percent: 10)->total())->toBe(900);
    });

    it('returns zero for empty items', function () {
        $calculator = new PriceCalculator(items: []);

        expect($calculator->total())->toBe(0);
    });
});
```

## Dataset Tests

Use datasets for testing multiple inputs:

```php
it('rejects invalid email formats', function (string $email) {
    actingAs($this->user)
        ->postJson(route('contacts.store'), [
            'name' => 'Test',
            'email' => $email,
        ])
        ->assertUnprocessable();
})->with([
    'missing @' => ['not-an-email'],
    'missing domain' => ['user@'],
    'spaces' => ['user @example.com'],
]);
```

## Coverage

- Run tests with coverage: `php artisan test --coverage`
- Enforce minimum: `php artisan test --coverage --min=100`
- Use `covers()` to scope coverage to specific classes:

```php
covers(CreateContact::class);

it('creates a contact', function () { ... });
```

## Things NOT To Do

- Do not test framework code (don't test that Laravel validates "required")
- Do not test implementation details (don't assert a specific SQL query ran)
- Do not write tests that pass regardless of behavior (e.g., asserting `true === true`)
- Do not use `$this->withoutExceptionHandling()` unless debugging a specific test
