<?php

declare(strict_types=1);

namespace App\Providers;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\ServiceProvider;

/**
 * Strict defaults for AI-assisted Laravel development.
 *
 * These settings force both you and AI agents to write explicit, correct code.
 * See: Nuno Maduro's "Agentic Precision" talk (Laracon India 2026)
 *
 * Copy the boot() contents into your AppServiceProvider.
 */
class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        // ──────────────────────────────────────────────
        // Strict mode: fail loudly in development
        // ──────────────────────────────────────────────
        // This enables ALL three protections below at once,
        // but only in non-production environments:
        Model::shouldBeStrict(! app()->isProduction());

        // ──────────────────────────────────────────────
        // Always-on protections (even in production)
        // ──────────────────────────────────────────────

        // Throw if accessing an attribute that doesn't exist on the model.
        // Catches typos and assumptions AI agents make about your schema.
        Model::preventAccessingMissingAttributes();

        // Throw if a relationship is lazy-loaded.
        // Forces explicit eager loading, preventing N+1 queries.
        // AI agents often forget ->with(), this catches it immediately.
        Model::preventLazyLoading();

        // Throw if mass-assigning an attribute not in $fillable.
        // Prevents AI from accidentally exposing fields to mass assignment.
        Model::preventSilentlyDiscardingAttributes();

        // ──────────────────────────────────────────────
        // Immutable dates (optional but recommended)
        // ──────────────────────────────────────────────
        // Date objects returned by Eloquent are immutable (CarbonImmutable).
        // Prevents subtle mutation bugs in date calculations.
        // Uncomment if you want this:
        // \Illuminate\Support\Facades\Date::use(\Carbon\CarbonImmutable::class);
    }
}
