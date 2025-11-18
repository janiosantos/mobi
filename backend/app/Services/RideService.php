<?php

namespace App\Services;

use App\Models\Ride;
use App\Models\User;
use App\Models\VehicleCategory;
use App\DTOs\RideDTO;
use App\Repositories\Contracts\RideRepositoryInterface;
use App\Events\RideRequested;
use App\Events\RideAccepted;
use App\Events\RideStarted;
use App\Events\RideCompleted;
use App\Events\RideCancelled;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class RideService
{
    public function __construct(
        protected RideRepositoryInterface $rideRepository,
        protected GoogleMapsService $googleMaps,
        protected PricingService $pricing,
        protected DriverMatchingService $driverMatching,
    ) {}

    /**
     * Estimate ride price and duration
     */
    public function estimateRide(RideDTO $data): array
    {
        // Get route info from Google Maps
        $directions = $this->googleMaps->getDirections(
            $data->pickupLatitude,
            $data->pickupLongitude,
            $data->dropoffLatitude,
            $data->dropoffLongitude
        );

        if (!$directions) {
            throw new \Exception('Unable to calculate route. Please check the addresses.');
        }

        $category = VehicleCategory::findOrFail($data->vehicleCategoryId);

        // Calculate pricing
        $estimate = $this->pricing->calculateEstimate(
            $category,
            $directions['distance']['value'],
            $directions['duration']['value'],
            $data->pickupLatitude,
            $data->pickupLongitude,
            $data->couponId
        );

        return [
            'category' => [
                'id' => $category->id,
                'name' => $category->name,
                'icon' => $category->icon,
            ],
            'route' => [
                'distance' => $directions['distance'],
                'duration' => $directions['duration'],
                'polyline' => $directions['polyline'],
            ],
            'pricing' => $estimate,
        ];
    }

    /**
     * Create a new ride request
     */
    public function createRide(User $passenger, RideDTO $data): Ride
    {
        return DB::transaction(function () use ($passenger, $data) {
            // Get route and pricing
            $estimate = $this->estimateRide($data);

            // Create ride
            $ride = $this->rideRepository->create([
                'ride_number' => $this->generateRideNumber(),
                'passenger_id' => $passenger->id,
                'vehicle_category_id' => $data->vehicleCategoryId,
                'pickup_latitude' => $data->pickupLatitude,
                'pickup_longitude' => $data->pickupLongitude,
                'pickup_address' => $data->pickupAddress,
                'pickup_city' => $data->pickupCity,
                'pickup_state' => $data->pickupState,
                'pickup_postal_code' => $data->pickupPostalCode,
                'dropoff_latitude' => $data->dropoffLatitude,
                'dropoff_longitude' => $data->dropoffLongitude,
                'dropoff_address' => $data->dropoffAddress,
                'dropoff_city' => $data->dropoffCity,
                'dropoff_state' => $data->dropoffState,
                'dropoff_postal_code' => $data->dropoffPostalCode,
                'estimated_distance' => $estimate['pricing']['distance_km'],
                'estimated_duration' => $estimate['pricing']['duration_minutes'],
                'route_polyline' => $estimate['route']['polyline'],
                'estimated_price' => $estimate['pricing']['total'],
                'base_fare' => $estimate['pricing']['base_fare'],
                'distance_fare' => $estimate['pricing']['distance_fare'],
                'time_fare' => $estimate['pricing']['time_fare'],
                'surge_multiplier' => $estimate['pricing']['surge_multiplier'],
                'discount_amount' => $estimate['pricing']['discount'],
                'coupon_id' => $data->couponId,
                'platform_fee' => $estimate['pricing']['platform_fee'],
                'driver_earnings' => $estimate['pricing']['driver_earnings'],
                'status' => 'searching',
                'payment_method' => $data->paymentMethod,
                'passenger_notes' => $data->passengerNotes,
                'requested_at' => now(),
            ]);

            // Dispatch event to notify nearby drivers
            event(new RideRequested($ride));

            Log::info('Ride created', ['ride_id' => $ride->id, 'ride_number' => $ride->ride_number]);

            return $ride;
        });
    }

    /**
     * Driver accepts a ride
     */
    public function acceptRide(Ride $ride, User $driver): Ride
    {
        if ($ride->driver_id) {
            throw new \Exception('This ride has already been accepted by another driver.');
        }

        if (!$driver->driverProfile->canAcceptRides()) {
            throw new \Exception('Driver is not able to accept rides at this moment.');
        }

        $vehicle = $driver->driverProfile->primaryVehicle();

        if (!$vehicle) {
            throw new \Exception('Driver does not have an active vehicle.');
        }

        return DB::transaction(function () use ($ride, $driver, $vehicle) {
            // Assign driver to ride
            $this->rideRepository->assignDriver($ride->id, $driver->id, $vehicle->id);

            // Mark driver as unavailable
            $driver->driverProfile->update(['is_available' => false]);

            // Reload ride
            $ride = $ride->fresh();

            // Dispatch event
            event(new RideAccepted($ride));

            Log::info('Ride accepted', [
                'ride_id' => $ride->id,
                'driver_id' => $driver->id,
            ]);

            return $ride;
        });
    }

    /**
     * Driver arrives at pickup location
     */
    public function arriveAtPickup(Ride $ride): Ride
    {
        if ($ride->status !== 'accepted') {
            throw new \Exception('Invalid ride status for arrival.');
        }

        $this->rideRepository->updateStatus($ride->id, 'driver_arrived');

        return $ride->fresh();
    }

    /**
     * Start the ride
     */
    public function startRide(Ride $ride): Ride
    {
        if ($ride->status !== 'driver_arrived') {
            throw new \Exception('Ride cannot be started. Driver must arrive first.');
        }

        return DB::transaction(function () use ($ride) {
            $this->rideRepository->updateStatus($ride->id, 'in_progress');

            $ride = $ride->fresh();

            event(new RideStarted($ride));

            Log::info('Ride started', ['ride_id' => $ride->id]);

            return $ride;
        });
    }

    /**
     * Complete the ride
     */
    public function completeRide(Ride $ride, float $actualDistanceKm, int $actualDurationMinutes): Ride
    {
        if ($ride->status !== 'in_progress') {
            throw new \Exception('Ride is not in progress.');
        }

        return DB::transaction(function () use ($ride, $actualDistanceKm, $actualDurationMinutes) {
            // Calculate final price based on actual distance/time
            $category = $ride->category;
            $actualDistanceMeters = $actualDistanceKm * 1000;
            $actualDurationSeconds = $actualDurationMinutes * 60;

            $finalPricing = $this->pricing->calculateEstimate(
                $category,
                $actualDistanceMeters,
                $actualDurationSeconds,
                $ride->pickup_latitude,
                $ride->pickup_longitude,
                $ride->coupon_id
            );

            // Update ride
            $ride->update([
                'status' => 'completed',
                'completed_at' => now(),
                'actual_distance' => $actualDistanceKm,
                'actual_duration' => $actualDurationMinutes,
                'final_price' => $finalPricing['total'],
                'platform_fee' => $finalPricing['platform_fee'],
                'driver_earnings' => $finalPricing['driver_earnings'],
            ]);

            // Mark driver as available again
            $ride->driver->driverProfile->update(['is_available' => true]);

            // Update driver stats
            $this->updateDriverStats($ride->driver->driverProfile);

            event(new RideCompleted($ride));

            Log::info('Ride completed', ['ride_id' => $ride->id]);

            return $ride->fresh();
        });
    }

    /**
     * Cancel a ride
     */
    public function cancelRide(Ride $ride, User $user, string $reason): Ride
    {
        if (!$ride->canBeCancelled()) {
            throw new \Exception('This ride cannot be cancelled.');
        }

        return DB::transaction(function () use ($ride, $user, $reason) {
            $cancelledBy = $user->id === $ride->passenger_id ? 'passenger' : 'driver';
            $status = $cancelledBy === 'passenger' ? 'cancelled_by_passenger' : 'cancelled_by_driver';

            // Calculate cancellation fee if applicable
            $cancellationFee = 0;
            if ($ride->status === 'accepted' || $ride->status === 'driver_arrived') {
                $cancellationFee = config('mobi.ride.cancel_penalty');
            }

            $ride->update([
                'status' => $status,
                'cancelled_at' => now(),
                'cancelled_by' => $cancelledBy,
                'cancellation_reason' => $reason,
                'cancellation_fee' => $cancellationFee,
            ]);

            // If driver was assigned, make them available again
            if ($ride->driver_id) {
                $ride->driver->driverProfile->update(['is_available' => true]);
            }

            event(new RideCancelled($ride));

            Log::info('Ride cancelled', [
                'ride_id' => $ride->id,
                'cancelled_by' => $cancelledBy,
            ]);

            return $ride->fresh();
        });
    }

    /**
     * Generate unique ride number
     */
    protected function generateRideNumber(): string
    {
        do {
            $number = 'RIDE-' . strtoupper(Str::random(8));
        } while (Ride::where('ride_number', $number)->exists());

        return $number;
    }

    /**
     * Update driver statistics
     */
    protected function updateDriverStats($driverProfile): void
    {
        $driverProfile->increment('total_rides');
        $driverProfile->increment('total_rides_completed');

        // Recalculate rates
        $totalRides = $driverProfile->total_rides;
        $completed = $driverProfile->total_rides_completed;
        $cancelled = $driverProfile->total_rides_cancelled;

        if ($totalRides > 0) {
            $driverProfile->update([
                'cancellation_rate' => ($cancelled / $totalRides) * 100,
            ]);
        }
    }
}
