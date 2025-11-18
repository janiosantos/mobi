<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\URL;
use Illuminate\Database\Eloquent\Model;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Force HTTPS in production
        if ($this->app->environment('production')) {
            URL::forceScheme('https');
        }
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Prevent lazy loading in development
        Model::preventLazyLoading(!app()->isProduction());

        // Prevent silently discarding attributes
        Model::preventSilentlyDiscardingAttributes(!app()->isProduction());

        // Prevent accessing missing attributes
        Model::preventAccessingMissingAttributes(!app()->isProduction());
    }
}
