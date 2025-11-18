<?php

namespace App\Jobs;

use App\Models\Ride;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class CleanupExpiredRidesJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     */
    public $tries = 1;

    /**
     * The number of seconds the job can run before timing out.
     */
    public $timeout = 300;

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            // Cancel rides that have been searching for more than 10 minutes
            $expiredSearchingRides = Ride::where('status', 'searching')
                ->where('created_at', '<', now()->subMinutes(10))
                ->get();

            foreach ($expiredSearchingRides as $ride) {
                $ride->update([
                    'status' => 'no_driver_found',
                    'cancelled_at' => now(),
                    'cancelled_by' => 'system',
                    'cancellation_reason' => 'No driver found within the timeout period',
                ]);

                Log::info('Expired ride cancelled', ['ride_id' => $ride->id]);
            }

            // Cancel rides where driver accepted but didn't arrive for 30 minutes
            $expiredAcceptedRides = Ride::where('status', 'accepted')
                ->where('accepted_at', '<', now()->subMinutes(30))
                ->get();

            foreach ($expiredAcceptedRides as $ride) {
                $ride->update([
                    'status' => 'cancelled_by_system',
                    'cancelled_at' => now(),
                    'cancelled_by' => 'system',
                    'cancellation_reason' => 'Driver did not arrive within 30 minutes',
                ]);

                // Make driver available again
                if ($ride->driver_id) {
                    $ride->driver->driverProfile->update(['is_available' => true]);
                }

                Log::info('Expired accepted ride cancelled', ['ride_id' => $ride->id]);
            }

            Log::info('Cleanup expired rides job completed', [
                'searching_cancelled' => $expiredSearchingRides->count(),
                'accepted_cancelled' => $expiredAcceptedRides->count(),
            ]);
        } catch (\Exception $e) {
            Log::error('Error cleaning up expired rides', [
                'error' => $e->getMessage(),
            ]);
        }
    }
}
