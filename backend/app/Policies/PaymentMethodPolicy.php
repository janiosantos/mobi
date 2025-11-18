<?php

namespace App\Policies;

use App\Models\User;
use App\Models\PaymentMethod;

class PaymentMethodPolicy
{
    /**
     * Determine if the user can view the payment method.
     */
    public function view(User $user, PaymentMethod $paymentMethod): bool
    {
        // Owner can view their payment method
        if ($paymentMethod->user_id === $user->id) {
            return true;
        }

        // Admins can view any payment method
        return $user->hasRole('admin');
    }

    /**
     * Determine if the user can create payment methods.
     */
    public function create(User $user): bool
    {
        // Users can have max 5 payment methods
        return $user->paymentMethods()->count() < 5;
    }

    /**
     * Determine if the user can update the payment method.
     */
    public function update(User $user, PaymentMethod $paymentMethod): bool
    {
        // Owner can update their payment method
        return $paymentMethod->user_id === $user->id;
    }

    /**
     * Determine if the user can delete the payment method.
     */
    public function delete(User $user, PaymentMethod $paymentMethod): bool
    {
        // Owner can delete their payment method
        if ($paymentMethod->user_id === $user->id) {
            // Must have at least one payment method
            if ($user->paymentMethods()->count() <= 1) {
                return false;
            }
            return true;
        }

        return false;
    }

    /**
     * Determine if the user can set the payment method as default.
     */
    public function setDefault(User $user, PaymentMethod $paymentMethod): bool
    {
        // Owner can set their payment method as default
        return $paymentMethod->user_id === $user->id;
    }
}
