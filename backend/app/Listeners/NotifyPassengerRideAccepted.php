<?php

namespace App\Listeners;

use App\Events\RideAccepted;
use Illuminate\Support\Facades\Log;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class NotifyPassengerRideAccepted implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Handle the event.
     */
    public function handle(RideAccepted $event): void
    {
        $ride = $event->ride;
        $passenger = $ride->passenger;
        $driver = $ride->driver;

        Log::info('Notifying passenger about ride acceptance', [
            'ride_id' => $ride->id,
            'passenger_id' => $passenger->id,
            'driver_id' => $driver->id,
        ]);

        // TODO: Send push notification to passenger
        // This would include driver info: name, photo, rating, vehicle info

        // TODO: Send SMS/Email notification as backup

        Log::info('Notification sent to passenger', [
            'ride_id' => $ride->id,
            'passenger_id' => $passenger->id,
        ]);
    }
}
