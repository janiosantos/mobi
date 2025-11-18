<?php

namespace App\Services;

use App\Models\Ride;
use App\Models\DriverProfile;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;

class DriverMatchingService
{
    /**
     * Find available drivers near a location
     */
    public function findNearbyDrivers(
        float $latitude,
        float $longitude,
        int $categoryId,
        float $radiusKm = 5
    ): Collection {
        return DriverProfile::query()
            ->available()
            ->nearby($latitude, $longitude, $radiusKm)
            ->whereHas('vehicles', function ($query) use ($categoryId) {
                $query->where('vehicle_category_id', $categoryId)
                    ->where('is_active', true);
            })
            ->with(['user', 'primaryVehicle'])
            ->get()
            ->sortBy('distance'); // 'distance' is added by the nearby scope
    }

    /**
     * Find the best driver for a ride
     */
    public function findBestDriver(Ride $ride): ?DriverProfile
    {
        $drivers = $this->findNearbyDrivers(
            $ride->pickup_latitude,
            $ride->pickup_longitude,
            $ride->vehicle_category_id
        );

        if ($drivers->isEmpty()) {
            Log::info('No available drivers found', ['ride_id' => $ride->id]);
            return null;
        }

        // Score drivers based on multiple factors
        $scoredDrivers = $drivers->map(function ($driver) {
            $score = 0;

            // Distance score (closer is better) - 40%
            $maxDistance = config('mobi.ride.search_radius') / 1000; // km
            $distanceScore = (1 - ($driver->distance / $maxDistance)) * 40;
            $score += max(0, $distanceScore);

            // Rating score - 30%
            $ratingScore = ($driver->average_rating / 5) * 30;
            $score += $ratingScore;

            // Acceptance rate score - 20%
            $acceptanceScore = ($driver->acceptance_rate / 100) * 20;
            $score += $acceptanceScore;

            // Low cancellation rate score - 10%
            $cancellationScore = (1 - ($driver->cancellation_rate / 100)) * 10;
            $score += $cancellationScore;

            $driver->match_score = round($score, 2);

            return $driver;
        });

        // Return driver with highest score
        $bestDriver = $scoredDrivers->sortByDesc('match_score')->first();

        Log::info('Best driver found', [
            'ride_id' => $ride->id,
            'driver_id' => $bestDriver->user_id,
            'score' => $bestDriver->match_score,
            'distance' => $bestDriver->distance,
        ]);

        return $bestDriver;
    }

    /**
     * Notify drivers about a new ride
     */
    public function notifyDrivers(Ride $ride, Collection $drivers): void
    {
        foreach ($drivers as $driver) {
            // Send push notification to each driver
            // This would use FCM or similar service
            Log::info('Notifying driver about ride', [
                'ride_id' => $ride->id,
                'driver_id' => $driver->user_id,
            ]);

            // In production, you would:
            // event(new RideAvailableForDriver($ride, $driver));
        }
    }

    /**
     * Auto-assign ride to best driver (if enabled)
     */
    public function autoAssignRide(Ride $ride): bool
    {
        $bestDriver = $this->findBestDriver($ride);

        if (!$bestDriver) {
            return false;
        }

        // In production, you might want to notify the driver and wait for acceptance
        // instead of auto-assigning. This is just a helper method.

        Log::info('Auto-assigning ride', [
            'ride_id' => $ride->id,
            'driver_id' => $bestDriver->user_id,
        ]);

        return true;
    }

    /**
     * Calculate ETA for driver to reach pickup
     */
    public function calculateDriverETA(DriverProfile $driver, Ride $ride): ?int
    {
        // Use simple distance-based calculation (could use Google Maps API for accuracy)
        $distance = $driver->distanceFrom($ride->pickup_latitude, $ride->pickup_longitude);

        // Assume average city speed of 30 km/h
        $averageSpeed = 30; // km/h
        $hours = $distance / $averageSpeed;
        $minutes = $hours * 60;

        return (int) ceil($minutes);
    }
}
