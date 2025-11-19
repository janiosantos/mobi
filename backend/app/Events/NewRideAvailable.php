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

class NewRideAvailable implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Ride $ride;
    public array $driverIds;

    /**
     * Create a new event instance.
     */
    public function __construct(Ride $ride, array $driverIds)
    {
        $this->ride = $ride;
        $this->driverIds = $driverIds;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        $channels = [];

        foreach ($this->driverIds as $driverId) {
            $channels[] = new PrivateChannel('user.' . $driverId);
        }

        return $channels;
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'ride.new.available';
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
                'pickup_latitude' => $this->ride->pickup_latitude,
                'pickup_longitude' => $this->ride->pickup_longitude,
                'pickup_address' => $this->ride->pickup_address,
                'dropoff_latitude' => $this->ride->dropoff_latitude,
                'dropoff_longitude' => $this->ride->dropoff_longitude,
                'dropoff_address' => $this->ride->dropoff_address,
                'estimated_distance_meters' => $this->ride->estimated_distance_meters,
                'estimated_duration_seconds' => $this->ride->estimated_duration_seconds,
                'estimated_price' => $this->ride->estimated_price,
                'vehicle_category_id' => $this->ride->vehicle_category_id,
                'passenger' => [
                    'id' => $this->ride->passenger->id,
                    'name' => $this->ride->passenger->name,
                    'rating' => $this->ride->passenger->rating,
                    'profile_photo_url' => $this->ride->passenger->profile_photo_url,
                ],
            ],
        ];
    }
}
