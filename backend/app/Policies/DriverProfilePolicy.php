<?php

namespace App\Policies;

use App\Models\User;
use App\Models\DriverProfile;

class DriverProfilePolicy
{
    /**
     * Determine if the user can view the driver profile.
     */
    public function view(User $user, DriverProfile $driverProfile): bool
    {
        // Users can view their own driver profile
        if ($driverProfile->user_id === $user->id) {
            return true;
        }

        // Admins can view any driver profile
        if ($user->hasRole('admin')) {
            return true;
        }

        // Passengers can view approved driver profiles
        return $driverProfile->status === 'approved';
    }

    /**
     * Determine if the user can update the driver profile.
     */
    public function update(User $user, DriverProfile $driverProfile): bool
    {
        // Drivers can update their own profile
        if ($driverProfile->user_id === $user->id) {
            return true;
        }

        // Admins can update any profile
        return $user->hasRole('admin');
    }

    /**
     * Determine if the user can approve/reject the driver profile.
     */
    public function approve(User $user, DriverProfile $driverProfile): bool
    {
        // Only admins can approve/reject drivers
        return $user->hasRole('admin');
    }

    /**
     * Determine if the user can view sensitive information.
     */
    public function viewSensitive(User $user, DriverProfile $driverProfile): bool
    {
        // Only the driver themselves or admins can view sensitive info
        return $driverProfile->user_id === $user->id || $user->hasRole('admin');
    }

    /**
     * Determine if the user can update bank account information.
     */
    public function updateBankAccount(User $user, DriverProfile $driverProfile): bool
    {
        // Only the driver can update their bank account
        return $driverProfile->user_id === $user->id;
    }

    /**
     * Determine if the user can upload documents.
     */
    public function uploadDocuments(User $user, DriverProfile $driverProfile): bool
    {
        // Only the driver can upload their documents
        return $driverProfile->user_id === $user->id;
    }

    /**
     * Determine if the user can request withdrawals.
     */
    public function withdraw(User $user, DriverProfile $driverProfile): bool
    {
        // Only the driver can request withdrawals
        if ($driverProfile->user_id !== $user->id) {
            return false;
        }

        // Driver must be approved
        if ($driverProfile->status !== 'approved') {
            return false;
        }

        // Must have available balance
        return $driverProfile->available_balance > 0;
    }

    /**
     * Determine if the user can toggle online status.
     */
    public function toggleOnlineStatus(User $user, DriverProfile $driverProfile): bool
    {
        // Only the driver can change their online status
        if ($driverProfile->user_id !== $user->id) {
            return false;
        }

        // Driver must be approved to go online
        if ($driverProfile->status !== 'approved') {
            return false;
        }

        // Driver must have at least one active vehicle
        return $driverProfile->vehicles()->where('is_active', true)->exists();
    }
}
