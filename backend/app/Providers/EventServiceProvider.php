<?php

namespace App\Providers;

use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event to listener mappings for the application.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],

        // Ride Events
        \App\Events\RideRequested::class => [
            \App\Listeners\NotifyNearbyDrivers::class,
            \App\Listeners\LogRideActivity::class,
        ],
        \App\Events\RideAccepted::class => [
            \App\Listeners\NotifyPassengerRideAccepted::class,
            \App\Listeners\LogRideActivity::class,
        ],
        \App\Events\RideStarted::class => [
            \App\Listeners\LogRideActivity::class,
        ],
        \App\Events\RideCompleted::class => [
            \App\Listeners\ProcessRidePayment::class,
            \App\Listeners\UpdateDriverStatsOnCompletion::class,
            \App\Listeners\LogRideActivity::class,
        ],
        \App\Events\RideCancelled::class => [
            \App\Listeners\UpdateDriverStatsOnCancellation::class,
            \App\Listeners\LogRideActivity::class,
        ],
    ];

    /**
     * Register any events for your application.
     */
    public function boot(): void
    {
        //
    }

    /**
     * Determine if events and listeners should be automatically discovered.
     */
    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}
