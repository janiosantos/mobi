<?php

namespace App\Repositories\Contracts;

use App\Models\Ride;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface RideRepositoryInterface extends BaseRepositoryInterface
{
    public function findByRideNumber(string $rideNumber): ?Ride;

    public function getActiveRidesForPassenger(int $passengerId): Collection;

    public function getActiveRidesForDriver(int $driverId): Collection;

    public function getRidesForPassenger(int $passengerId, int $perPage = 15): LengthAwarePaginator;

    public function getRidesForDriver(int $driverId, int $perPage = 15): LengthAwarePaginator;

    public function getAvailableRides(float $latitude, float $longitude, int $categoryId, float $radius = 5): Collection;

    public function getTodayRides(): Collection;

    public function getCompletedRidesToday(): Collection;

    public function updateStatus(int $rideId, string $status): bool;

    public function assignDriver(int $rideId, int $driverId, int $vehicleId): bool;
}
