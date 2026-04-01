# PHP & Laravel Coding Standards

## PHP Fundamentals

- `declare(strict_types=1);` in every PHP file.
- Use typed properties, return types, and parameter types everywhere.
- Use `readonly` properties where the value shouldn't change after construction.
- Use `match()` instead of `switch`.
- Use Enums in `app/Enums/` instead of string constants.
- Use named arguments when calling methods with 3+ parameters.
- Never suppress errors with `@`.

## Controllers

Every controller method follows this structure:
1. Authorize (via middleware, policy, or Gate)
2. Validate (via Form Request — never inline `$request->validate()`)
3. Execute (call an Action class or Eloquent directly)
4. Return response

Good:
```php
public function store(StoreContactRequest $request): RedirectResponse
{
    $contact = CreateContact::run($request->validated());

    return redirect()->route('contacts.show', $contact)
        ->with('success', 'Contact created.');
}
```

Bad:
```php
public function store(Request $request)
{
    $request->validate(['name' => 'required', 'email' => 'required|email']);
    $contact = new Contact;
    $contact->name = $request->name;
    $contact->email = $request->email;
    $contact->save();
    return redirect('/contacts/' . $contact->id);
}
```

## Eloquent Models

- Always define `$fillable` explicitly. Never use `$guarded = []`.
- Define `$casts` for dates, booleans, enums, and JSON columns.
- Relationships must have return types: `public function posts(): HasMany`
- Use query scopes for reusable query logic.
- Pivot tables should include `timestamps()`.
- Use `$with` sparingly — prefer explicit eager loading at the call site.

## Actions

Business logic lives in Action classes in `app/Actions/`:

```php
final class CreateContact
{
    public static function run(array $data): Contact
    {
        return Contact::create($data);
    }
}
```

Keep Actions focused on one operation. If it's getting complex, split into multiple Actions.

## Form Requests

All validation lives in Form Requests:

```php
final class StoreContactRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Contact::class);
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:contacts,email'],
        ];
    }
}
```

## Routes

- Use resource controllers: `Route::resource('contacts', ContactController::class)`
- Use route model binding: `Route::get('/contacts/{contact}', ...)`
- Name all routes explicitly if not using resource routes.
- Group routes by middleware.
- API routes return JSON via `JsonResource` classes.

## Error Handling

- Never catch exceptions just to re-throw or log — let Laravel's handler deal with it.
- Use abort helpers: `abort(404)`, `abort_if()`, `abort_unless()`
- Custom exceptions for domain-specific errors.

## Configuration

- Never use `env()` outside of `config/` files.
- Access config via `config('app.name')`.
- Use `.env` for environment-specific values only.

## Queues

- Anything that takes >500ms should be queued.
- Use `ShouldQueue` interface on jobs, notifications, listeners.
- Define `$tries`, `$backoff`, `$timeout` on every job.
- Use `$uniqueFor` to prevent duplicate jobs where appropriate.
