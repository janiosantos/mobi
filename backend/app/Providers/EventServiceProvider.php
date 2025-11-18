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
            \App\Listeners\UpdateRideStatus::class,
            \App\Listeners\LogRideActivity::class,
        ],
        \App\Events\RideStarted::class => [
            \App\Listeners\NotifyPassengerRideStarted::class,
            \App\Listeners\StartRideTracking::class,
            \App\Listeners\LogRideActivity::class,
        ],
        \App\Events\RideCompleted::class => [
            \App\Listeners\ProcessPayment::class,
            \App\Listeners\CalculateDriverEarnings::class,
            \App\Listeners\NotifyRideCompleted::class,
            \App\Listeners\RequestRating::class,
            \App\Listeners\LogRideActivity::class,
        ],
        \App\Events\RideCancelled::class => [
            \App\Listeners\HandleCancellationPenalty::class,
            \App\Listeners\NotifyRideCancellation::class,
            \App\Listeners\ReleaseDriver::class,
            \App\Listeners\LogRideActivity::class,
        ],

        // Driver Events
        \App\Events\DriverWentOnline::class => [
            \App\Listeners\UpdateDriverAvailability::class,
            \App\Listeners\LogDriverActivity::class,
        ],
        \App\Events\DriverWentOffline::class => [
            \App\Listeners\UpdateDriverAvailability::class,
            \App\Listeners\LogDriverActivity::class,
        ],
        \App\Events\DriverLocationUpdated::class => [
            \App\Listeners\BroadcastDriverLocation::class,
            \App\Listeners\UpdateRideLocation::class,
        ],
        \App\Events\DriverApproved::class => [
            \App\Listeners\NotifyDriverApproval::class,
            \App\Listeners\SendWelcomeEmail::class,
        ],
        \App\Events\DriverRejected::class => [
            \App\Listeners\NotifyDriverRejection::class,
        ],
        \App\Events\DocumentUploaded::class => [
            \App\Listeners\ProcessDocumentVerification::class,
        ],

        // Payment Events
        \App\Events\PaymentProcessed::class => [
            \App\Listeners\SendPaymentReceipt::class,
            \App\Listeners\UpdateRidePaymentStatus::class,
        ],
        \App\Events\PaymentFailed::class => [
            \App\Listeners\NotifyPaymentFailure::class,
            \App\Listeners\RetryPayment::class,
        ],

        // Rating Events
        \App\Events\RatingSubmitted::class => [
            \App\Listeners\UpdateUserRating::class,
            \App\Listeners\CheckRatingThreshold::class,
        ],

        // Chat Events
        \App\Events\MessageSent::class => [
            \App\Listeners\BroadcastMessage::class,
            \App\Listeners\SendMessageNotification::class,
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
