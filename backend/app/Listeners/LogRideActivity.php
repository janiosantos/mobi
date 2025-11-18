<?php

namespace App\Listeners;

use App\Events\RideRequested;
use App\Events\RideAccepted;
use App\Events\RideStarted;
use App\Events\RideCompleted;
use App\Events\RideCancelled;
use Illuminate\Support\Facades\Log;

class LogRideActivity
{
    /**
     * Register the listeners for the subscriber.
     */
    public function subscribe($events): array
    {
        return [
            RideRequested::class => 'handleRideRequested',
            RideAccepted::class => 'handleRideAccepted',
            RideStarted::class => 'handleRideStarted',
            RideCompleted::class => 'handleRideCompleted',
            RideCancelled::class => 'handleRideCancelled',
        ];
    }

    /**
     * Handle RideRequested event.
     */
    public function handleRideRequested(RideRequested $event): void
    {
        activity()
            ->performedOn($event->ride)
            ->causedBy($event->ride->passenger)
            ->withProperties([
                'ride_number' => $event->ride->ride_number,
                'pickup_address' => $event->ride->pickup_address,
                'dropoff_address' => $event->ride->dropoff_address,
                'estimated_price' => $event->ride->estimated_price,
            ])
            ->log('Ride requested');

        Log::info('Ride requested', [
            'ride_id' => $event->ride->id,
            'passenger_id' => $event->ride->passenger_id,
        ]);
    }

    /**
     * Handle RideAccepted event.
     */
    public function handleRideAccepted(RideAccepted $event): void
    {
        activity()
            ->performedOn($event->ride)
            ->causedBy($event->ride->driver)
            ->withProperties([
                'ride_number' => $event->ride->ride_number,
                'driver_name' => $event->ride->driver->name,
                'vehicle' => $event->ride->vehicle->make . ' ' . $event->ride->vehicle->model,
            ])
            ->log('Ride accepted by driver');

        Log::info('Ride accepted', [
            'ride_id' => $event->ride->id,
            'driver_id' => $event->ride->driver_id,
        ]);
    }

    /**
     * Handle RideStarted event.
     */
    public function handleRideStarted(RideStarted $event): void
    {
        activity()
            ->performedOn($event->ride)
            ->causedBy($event->ride->driver)
            ->withProperties([
                'ride_number' => $event->ride->ride_number,
                'started_at' => $event->ride->started_at,
            ])
            ->log('Ride started');

        Log::info('Ride started', [
            'ride_id' => $event->ride->id,
        ]);
    }

    /**
     * Handle RideCompleted event.
     */
    public function handleRideCompleted(RideCompleted $event): void
    {
        activity()
            ->performedOn($event->ride)
            ->causedBy($event->ride->driver)
            ->withProperties([
                'ride_number' => $event->ride->ride_number,
                'final_price' => $event->ride->final_price,
                'duration' => $event->ride->actual_duration_seconds,
                'distance' => $event->ride->actual_distance_meters,
            ])
            ->log('Ride completed');

        Log::info('Ride completed', [
            'ride_id' => $event->ride->id,
            'final_price' => $event->ride->final_price,
        ]);
    }

    /**
     * Handle RideCancelled event.
     */
    public function handleRideCancelled(RideCancelled $event): void
    {
        $causer = $event->ride->cancelled_by === 'passenger'
            ? $event->ride->passenger
            : $event->ride->driver;

        activity()
            ->performedOn($event->ride)
            ->causedBy($causer)
            ->withProperties([
                'ride_number' => $event->ride->ride_number,
                'cancelled_by' => $event->ride->cancelled_by,
                'reason' => $event->ride->cancellation_reason,
            ])
            ->log('Ride cancelled');

        Log::info('Ride cancelled', [
            'ride_id' => $event->ride->id,
            'cancelled_by' => $event->ride->cancelled_by,
        ]);
    }
}
