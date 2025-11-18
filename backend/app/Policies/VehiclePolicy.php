<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Vehicle;

class VehiclePolicy
{
    /**
     * Determine if the user can view the vehicle.
     */
    public function view(User $user, Vehicle $vehicle): bool
    {
        // Owner can view their vehicle
        if ($vehicle->driver_id === $user->driverProfile?->id) {
            return true;
        }

        // Admins can view any vehicle
        return $user->hasRole('admin');
    }

    /**
     * Determine if the user can create vehicles.
     */
    public function create(User $user): bool
    {
        // Must be a driver
        if (!$user->isDriver()) {
            return false;
        }

        // Must have a driver profile
        if (!$user->driverProfile) {
            return false;
        }

        // Driver can have max 3 vehicles
        return $user->driverProfile->vehicles()->count() < 3;
    }

    /**
     * Determine if the user can update the vehicle.
     */
    public function update(User $user, Vehicle $vehicle): bool
    {
        // Owner can update their vehicle
        if ($vehicle->driver_id === $user->driverProfile?->id) {
            return true;
        }

        // Admins can update any vehicle
        return $user->hasRole('admin');
    }

    /**
     * Determine if the user can delete the vehicle.
     */
    public function delete(User $user, Vehicle $vehicle): bool
    {
        // Owner can delete their vehicle
        if ($vehicle->driver_id === $user->driverProfile?->id) {
            // Cannot delete if it's the only vehicle
            if ($user->driverProfile->vehicles()->count() <= 1) {
                return false;
            }
            return true;
        }

        // Admins can delete any vehicle
        return $user->hasRole('admin');
    }

    /**
     * Determine if the user can activate the vehicle.
     */
    public function activate(User $user, Vehicle $vehicle): bool
    {
        // Only owner can activate their vehicle
        return $vehicle->driver_id === $user->driverProfile?->id;
    }
}
