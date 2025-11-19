<?php

namespace App\Events;

use App\Models\Ride;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class DriverLocationUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Ride $ride;
    public float $latitude;
    public float $longitude;

    /**
     * Create a new event instance.
     */
    public function __construct(Ride $ride, float $latitude, float $longitude)
    {
        $this->ride = $ride;
        $this->latitude = $latitude;
        $this->longitude = $longitude;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('ride.' . $this->ride->id),
            new PrivateChannel('user.' . $this->ride->passenger_id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'driver.location.updated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'ride_id' => $this->ride->id,
            'driver_id' => $this->ride->driver_id,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'timestamp' => now()->toIso8601String(),
        ];
    }
}
