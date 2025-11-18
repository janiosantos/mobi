<?php

namespace App\Events;

use App\Models\Ride;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RideRequested implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Ride $ride
    ) {}

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new Channel('available-rides'),
            new PrivateChannel('ride.' . $this->ride->id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'ride.requested';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'ride_id' => $this->ride->id,
            'ride_number' => $this->ride->ride_number,
            'passenger_id' => $this->ride->passenger_id,
            'vehicle_category_id' => $this->ride->vehicle_category_id,
            'pickup' => [
                'latitude' => $this->ride->pickup_latitude,
                'longitude' => $this->ride->pickup_longitude,
                'address' => $this->ride->pickup_address,
            ],
            'dropoff' => [
                'latitude' => $this->ride->dropoff_latitude,
                'longitude' => $this->ride->dropoff_longitude,
                'address' => $this->ride->dropoff_address,
            ],
            'estimated_price' => $this->ride->estimated_price,
        ];
    }
}
