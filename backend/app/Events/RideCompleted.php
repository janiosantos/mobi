<?php

namespace App\Events;

use App\Models\Ride;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RideCompleted implements ShouldBroadcast
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
        return 'ride.completed';
    }

    public function broadcastWith(): array
    {
        return [
            'ride_id' => $this->ride->id,
            'completed_at' => $this->ride->completed_at?->toISOString(),
            'final_price' => number_format($this->ride->final_price ?? $this->ride->estimated_price, 2, '.', ''),
        ];
    }
}
