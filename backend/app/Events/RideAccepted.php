<?php

namespace App\Events;

use App\Models\Ride;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RideAccepted implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Ride $ride
    ) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('ride.' . $this->ride->id),
            new PrivateChannel('user.' . $this->ride->passenger_id),
        ];
    }

    public function broadcastAs(): string
    {
        return 'ride.accepted';
    }

    public function broadcastWith(): array
    {
        return [
            'ride_id' => $this->ride->id,
            'ride_number' => $this->ride->ride_number,
            'driver' => [
                'id' => $this->ride->driver_id,
                'name' => $this->ride->driver->name,
                'photo_url' => $this->ride->driver->profile_photo_url,
                'rating' => $this->ride->driver->average_rating,
            ],
            'vehicle' => [
                'make' => $this->ride->vehicle->make,
                'model' => $this->ride->vehicle->model,
                'color' => $this->ride->vehicle->color,
                'license_plate' => $this->ride->vehicle->license_plate,
            ],
        ];
    }
}
