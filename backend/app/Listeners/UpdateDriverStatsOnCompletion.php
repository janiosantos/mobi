<?php

namespace App\Listeners;

use App\Events\RideCompleted;
use Illuminate\Support\Facades\Log;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class UpdateDriverStatsOnCompletion implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Handle the event.
     */
    public function handle(RideCompleted $event): void
    {
        $ride = $event->ride;

        if (!$ride->driver_id) {
            return;
        }

        $driverProfile = $ride->driver->driverProfile;

        Log::info('Updating driver statistics after ride completion', [
            'driver_id' => $driverProfile->id,
            'ride_id' => $ride->id,
        ]);

        // Increment completed rides
        $driverProfile->increment('total_rides');
        $driverProfile->increment('completed_rides');

        // Recalculate acceptance rate
        $totalRides = $driverProfile->total_rides;
        $completedRides = $driverProfile->completed_rides;
        $cancelledRides = $driverProfile->cancelled_rides;

        if ($totalRides > 0) {
            $acceptanceRate = ($completedRides / $totalRides) * 100;
            $cancellationRate = ($cancelledRides / $totalRides) * 100;

            $driverProfile->update([
                'acceptance_rate' => $acceptanceRate,
                'cancellation_rate' => $cancellationRate,
            ]);
        }

        Log::info('Driver statistics updated', [
            'driver_id' => $driverProfile->id,
            'total_rides' => $driverProfile->total_rides,
            'completed_rides' => $driverProfile->completed_rides,
            'acceptance_rate' => $driverProfile->acceptance_rate,
        ]);
    }
}
