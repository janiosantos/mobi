<?php

namespace App\Events;

use App\Models\Ride;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RideCancelled implements ShouldBroadcast
{
    use Dispatchable, SerializesModels;

    public function __construct(public Ride $ride) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('ride.' . $this->ride->id),
        ];
    }

    public function broadcastAs(): string
    {
        return 'ride.cancelled';
    }

    public function broadcastWith(): array
    {
        return [
            'ride_id' => $this->ride->id,
            'cancelled_by' => $this->ride->cancelled_by,
            'cancellation_reason' => $this->ride->cancellation_reason,
            'cancelled_at' => $this->ride->cancelled_at?->toISOString(),
        ];
    }
}
