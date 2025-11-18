<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Message;

class MessagePolicy
{
    /**
     * Determine if the user can view the message.
     */
    public function view(User $user, Message $message): bool
    {
        // User can view if they are sender or receiver
        return $message->sender_id === $user->id || $message->receiver_id === $user->id;
    }

    /**
     * Determine if the user can send a message in this ride.
     */
    public function send(User $user, \App\Models\Ride $ride): bool
    {
        // User must be passenger or driver of the ride
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return false;
        }

        // Ride must be active (accepted, driver_arrived, or in_progress)
        return in_array($ride->status, ['accepted', 'driver_arrived', 'in_progress']);
    }

    /**
     * Determine if the user can delete the message.
     */
    public function delete(User $user, Message $message): bool
    {
        // Only sender can delete their message (within 5 minutes)
        if ($message->sender_id !== $user->id) {
            return false;
        }

        // Message must be less than 5 minutes old
        return $message->created_at->diffInMinutes(now()) < 5;
    }
}
