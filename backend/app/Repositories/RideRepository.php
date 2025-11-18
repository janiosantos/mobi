<?php

namespace App\Repositories;

use App\Models\Ride;
use App\Repositories\Contracts\RideRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class RideRepository extends BaseRepository implements RideRepositoryInterface
{
    public function __construct(Ride $model)
    {
        parent::__construct($model);
    }

    public function findByRideNumber(string $rideNumber): ?Ride
    {
        return $this->model->where('ride_number', $rideNumber)->first();
    }

    public function getActiveRidesForPassenger(int $passengerId): Collection
    {
        return $this->model->forPassenger($passengerId)
            ->active()
            ->with(['driver', 'vehicle', 'category'])
            ->get();
    }

    public function getActiveRidesForDriver(int $driverId): Collection
    {
        return $this->model->forDriver($driverId)
            ->active()
            ->with(['passenger', 'vehicle', 'category'])
            ->get();
    }

    public function getRidesForPassenger(int $passengerId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->model->forPassenger($passengerId)
            ->with(['driver', 'vehicle', 'category', 'payment', 'ratings'])
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
    }

    public function getRidesForDriver(int $driverId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->model->forDriver($driverId)
            ->with(['passenger', 'vehicle', 'category', 'payment', 'ratings'])
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
    }

    public function getAvailableRides(float $latitude, float $longitude, int $categoryId, float $radius = 5): Collection
    {
        return $this->model->where('status', 'searching')
            ->where('vehicle_category_id', $categoryId)
            ->whereNull('driver_id')
            ->get()
            ->filter(function ($ride) use ($latitude, $longitude, $radius) {
                $distance = $this->calculateDistance(
                    $latitude,
                    $longitude,
                    $ride->pickup_latitude,
                    $ride->pickup_longitude
                );
                return $distance <= $radius;
            });
    }

    public function getTodayRides(): Collection
    {
        return $this->model->today()->get();
    }

    public function getCompletedRidesToday(): Collection
    {
        return $this->model->today()->completed()->get();
    }

    public function updateStatus(int $rideId, string $status): bool
    {
        $timestampField = match ($status) {
            'accepted' => 'accepted_at',
            'driver_arrived' => 'driver_arrived_at',
            'in_progress' => 'started_at',
            'completed' => 'completed_at',
            default => null,
        };

        $data = ['status' => $status];

        if ($timestampField) {
            $data[$timestampField] = now();
        }

        return $this->update($rideId, $data);
    }

    public function assignDriver(int $rideId, int $driverId, int $vehicleId): bool
    {
        return $this->update($rideId, [
            'driver_id' => $driverId,
            'vehicle_id' => $vehicleId,
            'status' => 'accepted',
            'accepted_at' => now(),
        ]);
    }

    /**
     * Calculate distance between two points using Haversine formula
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
