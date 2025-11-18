<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Ride;

class RidePolicy
{
    /**
     * Determine if the user can view the ride.
     */
    public function view(User $user, Ride $ride): bool
    {
        // User can view if they are passenger or driver of the ride
        return $ride->passenger_id === $user->id || $ride->driver_id === $user->id;
    }

    /**
     * Determine if the user can create rides.
     */
    public function create(User $user): bool
    {
        // Only passengers or users with passenger role can create rides
        return $user->isPassenger() || $user->hasRole('passenger');
    }

    /**
     * Determine if the user can cancel the ride.
     */
    public function cancel(User $user, Ride $ride): bool
    {
        // Passenger can cancel if they own the ride and it's cancellable
        if ($ride->passenger_id === $user->id && $ride->canBeCancelled()) {
            return true;
        }

        // Driver can cancel if they are assigned and it's cancellable
        if ($ride->driver_id === $user->id && $ride->canBeCancelled()) {
            return true;
        }

        return false;
    }

    /**
     * Determine if the user can rate the ride.
     */
    public function rate(User $user, Ride $ride): bool
    {
        // Only completed rides can be rated
        if ($ride->status !== 'completed') {
            return false;
        }

        // User must be passenger or driver of the ride
        return $ride->passenger_id === $user->id || $ride->driver_id === $user->id;
    }

    /**
     * Determine if the driver can accept the ride.
     */
    public function accept(User $user, Ride $ride): bool
    {
        // Must be a driver
        if (!$user->isDriver()) {
            return false;
        }

        // Ride must be in searching status
        if ($ride->status !== 'searching') {
            return false;
        }

        // Ride must not have a driver yet
        if ($ride->driver_id !== null) {
            return false;
        }

        // Driver must be approved and online
        return $user->isApprovedDriver() && $user->driverProfile?->is_online;
    }

    /**
     * Determine if the driver can start the ride.
     */
    public function start(User $user, Ride $ride): bool
    {
        // Must be the assigned driver
        if ($ride->driver_id !== $user->id) {
            return false;
        }

        // Ride must be in driver_arrived status
        return $ride->status === 'driver_arrived';
    }

    /**
     * Determine if the driver can complete the ride.
     */
    public function complete(User $user, Ride $ride): bool
    {
        // Must be the assigned driver
        if ($ride->driver_id !== $user->id) {
            return false;
        }

        // Ride must be in progress
        return $ride->status === 'in_progress';
    }

    /**
     * Determine if the user can update the ride.
     */
    public function update(User $user, Ride $ride): bool
    {
        // Only admins can update rides
        return $user->hasRole('admin');
    }

    /**
     * Determine if the user can delete the ride.
     */
    public function delete(User $user, Ride $ride): bool
    {
        // Only admins can delete rides
        return $user->hasRole('admin');
    }
}
