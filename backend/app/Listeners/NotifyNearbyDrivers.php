<?php

namespace App\Listeners;

use App\Events\RideRequested;
use App\Models\DriverProfile;
use Illuminate\Support\Facades\Log;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class NotifyNearbyDrivers implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Handle the event.
     */
    public function handle(RideRequested $event): void
    {
        $ride = $event->ride;

        Log::info('Finding nearby drivers for ride', ['ride_id' => $ride->id]);

        // Find drivers within 5km radius
        $radius = config('mobi.driver.search_radius_km', 5);

        $nearbyDrivers = DriverProfile::where('status', 'approved')
            ->where('is_online', true)
            ->where('is_available', true)
            ->whereHas('vehicles', function ($query) use ($ride) {
                $query->where('vehicle_category_id', $ride->vehicle_category_id)
                    ->where('is_active', true);
            })
            ->get()
            ->filter(function ($driver) use ($ride, $radius) {
                if (!$driver->current_latitude || !$driver->current_longitude) {
                    return false;
                }

                $distance = $this->calculateDistance(
                    $driver->current_latitude,
                    $driver->current_longitude,
                    $ride->pickup_latitude,
                    $ride->pickup_longitude
                );

                return $distance <= $radius;
            });

        Log::info('Found nearby drivers', [
            'ride_id' => $ride->id,
            'count' => $nearbyDrivers->count(),
        ]);

        // Send push notification to each driver
        foreach ($nearbyDrivers as $driver) {
            // TODO: Send push notification via FCM
            // This would be handled by a job like SendPushNotification
            Log::info('Would send notification to driver', [
                'driver_id' => $driver->user_id,
                'ride_id' => $ride->id,
            ]);
        }
    }

    /**
     * Calculate distance between two coordinates using Haversine formula
     */
    protected function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371; // km

        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }
}
