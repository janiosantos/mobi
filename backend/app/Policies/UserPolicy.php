<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    /**
     * Determine if the user can view the model.
     */
    public function view(User $currentUser, User $user): bool
    {
        // Users can view their own profile
        if ($currentUser->id === $user->id) {
            return true;
        }

        // Admins can view anyone
        if ($currentUser->hasRole('admin')) {
            return true;
        }

        // Drivers and passengers can view each other if they have shared a ride
        return $this->hasSharedRide($currentUser, $user);
    }

    /**
     * Determine if the user can update the model.
     */
    public function update(User $currentUser, User $user): bool
    {
        // Users can only update their own profile
        if ($currentUser->id === $user->id) {
            return true;
        }

        // Admins can update anyone
        return $currentUser->hasRole('admin');
    }

    /**
     * Determine if the user can delete the model.
     */
    public function delete(User $currentUser, User $user): bool
    {
        // Users can delete their own account
        if ($currentUser->id === $user->id) {
            return true;
        }

        // Admins can delete anyone
        return $currentUser->hasRole('admin');
    }

    /**
     * Determine if the user can ban another user.
     */
    public function ban(User $currentUser, User $user): bool
    {
        // Only admins can ban users
        if (!$currentUser->hasRole('admin')) {
            return false;
        }

        // Cannot ban yourself
        if ($currentUser->id === $user->id) {
            return false;
        }

        // Cannot ban other admins
        return !$user->hasRole('admin');
    }

    /**
     * Determine if the user can view sensitive information.
     */
    public function viewSensitive(User $currentUser, User $user): bool
    {
        // Only the user themselves or admins can view sensitive info
        return $currentUser->id === $user->id || $currentUser->hasRole('admin');
    }

    /**
     * Check if two users have shared a ride.
     */
    protected function hasSharedRide(User $user1, User $user2): bool
    {
        return \App\Models\Ride::where(function ($query) use ($user1, $user2) {
            $query->where('passenger_id', $user1->id)
                ->where('driver_id', $user2->id);
        })->orWhere(function ($query) use ($user1, $user2) {
            $query->where('passenger_id', $user2->id)
                ->where('driver_id', $user1->id);
        })->exists();
    }
}
