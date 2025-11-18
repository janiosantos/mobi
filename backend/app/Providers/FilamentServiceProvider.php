<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Filament\Support\Facades\FilamentAsset;
use Filament\Support\Assets\Css;
use Filament\Support\Assets\Js;

class FilamentServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        // Register custom Filament assets if needed
        // FilamentAsset::register([
        //     Css::make('custom-stylesheet', __DIR__ . '/../../resources/css/custom.css'),
        //     Js::make('custom-script', __DIR__ . '/../../resources/js/custom.js'),
        // ]);
    }
}
