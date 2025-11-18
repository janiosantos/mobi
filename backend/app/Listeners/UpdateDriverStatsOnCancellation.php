<?php

namespace App\Listeners;

use App\Events\RideCancelled;
use Illuminate\Support\Facades\Log;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class UpdateDriverStatsOnCancellation implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Handle the event.
     */
    public function handle(RideCancelled $event): void
    {
        $ride = $event->ride;

        // Only update stats if driver cancelled
        if ($ride->cancelled_by !== 'driver' || !$ride->driver_id) {
            return;
        }

        $driverProfile = $ride->driver->driverProfile;

        Log::info('Updating driver statistics after cancellation', [
            'driver_id' => $driverProfile->id,
            'ride_id' => $ride->id,
        ]);

        // Increment total rides and cancelled rides
        $driverProfile->increment('total_rides');
        $driverProfile->increment('cancelled_rides');

        // Recalculate cancellation rate
        $totalRides = $driverProfile->total_rides;
        $cancelledRides = $driverProfile->cancelled_rides;

        if ($totalRides > 0) {
            $cancellationRate = ($cancelledRides / $totalRides) * 100;

            $driverProfile->update([
                'cancellation_rate' => $cancellationRate,
            ]);
        }

        Log::info('Driver statistics updated after cancellation', [
            'driver_id' => $driverProfile->id,
            'cancelled_rides' => $driverProfile->cancelled_rides,
            'cancellation_rate' => $driverProfile->cancellation_rate,
        ]);
    }
}
