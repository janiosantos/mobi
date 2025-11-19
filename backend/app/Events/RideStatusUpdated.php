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

class RideStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Ride $ride;

    /**
     * Create a new event instance.
     */
    public function __construct(Ride $ride)
    {
        $this->ride = $ride;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('ride.' . $this->ride->id),
            new PrivateChannel('user.' . $this->ride->passenger_id),
            $this->ride->driver_id
                ? new PrivateChannel('user.' . $this->ride->driver_id)
                : null,
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'ride.status.updated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'ride' => [
                'id' => $this->ride->id,
                'ride_number' => $this->ride->ride_number,
                'status' => $this->ride->status,
                'passenger_id' => $this->ride->passenger_id,
                'driver_id' => $this->ride->driver_id,
                'pickup_latitude' => $this->ride->pickup_latitude,
                'pickup_longitude' => $this->ride->pickup_longitude,
                'pickup_address' => $this->ride->pickup_address,
                'dropoff_latitude' => $this->ride->dropoff_latitude,
                'dropoff_longitude' => $this->ride->dropoff_longitude,
                'dropoff_address' => $this->ride->dropoff_address,
                'estimated_price' => $this->ride->estimated_price,
                'final_price' => $this->ride->final_price,
                'driver' => $this->ride->driver ? [
                    'id' => $this->ride->driver->id,
                    'name' => $this->ride->driver->name,
                    'rating' => $this->ride->driver->rating,
                    'profile_photo_url' => $this->ride->driver->profile_photo_url,
                ] : null,
                'vehicle' => $this->ride->vehicle ? [
                    'id' => $this->ride->vehicle->id,
                    'brand' => $this->ride->vehicle->brand,
                    'model' => $this->ride->vehicle->model,
                    'color' => $this->ride->vehicle->color,
                    'plate' => $this->ride->vehicle->plate,
                ] : null,
            ],
        ];
    }
}
