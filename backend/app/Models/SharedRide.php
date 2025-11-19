<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SharedRide extends Model
{
    use HasFactory;

    protected $fillable = [
        'driver_id',
        'vehicle_id',
        'pickup_latitude',
        'pickup_longitude',
        'pickup_address',
        'dropoff_latitude',
        'dropoff_longitude',
        'dropoff_address',
        'departure_time',
        'max_passengers',
        'current_passengers',
        'price_per_seat',
        'status',
    ];

    protected $casts = [
        'pickup_latitude' => 'float',
        'pickup_longitude' => 'float',
        'dropoff_latitude' => 'float',
        'dropoff_longitude' => 'float',
        'departure_time' => 'datetime',
        'price_per_seat' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = ['has_available_seats', 'is_full'];

    /**
     * Get the driver of this shared ride.
     */
    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    /**
     * Get the vehicle used for this shared ride.
     */
    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class);
    }

    /**
     * Get the passengers in this shared ride.
     */
    public function passengers()
    {
        return $this->hasMany(SharedRidePassenger::class);
    }

    /**
     * Get active passengers only.
     */
    public function activePassengers()
    {
        return $this->passengers()->whereIn('status', ['confirmed', 'picked_up']);
    }

    /**
     * Check if there are available seats.
     */
    public function getHasAvailableSeatsAttribute()
    {
        return $this->current_passengers < $this->max_passengers;
    }

    /**
     * Check if the ride is full.
     */
    public function getIsFullAttribute()
    {
        return $this->current_passengers >= $this->max_passengers;
    }

    /**
     * Scope to filter scheduled rides.
     */
    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled');
    }

    /**
     * Scope to filter rides with available seats.
     */
    public function scopeWithAvailableSeats($query)
    {
        return $query->whereColumn('current_passengers', '<', 'max_passengers');
    }

    /**
     * Scope to search rides by location and time.
     */
    public function scopeSearchByRoute($query, $pickupLat, $pickupLng, $dropoffLat, $dropoffLng, $maxDistance = 5)
    {
        // Using Haversine formula to calculate distance
        $earthRadius = 6371; // km

        return $query->selectRaw("
            *,
            (
                $earthRadius * acos(
                    cos(radians(?)) * cos(radians(pickup_latitude)) *
                    cos(radians(pickup_longitude) - radians(?)) +
                    sin(radians(?)) * sin(radians(pickup_latitude))
                )
            ) as pickup_distance,
            (
                $earthRadius * acos(
                    cos(radians(?)) * cos(radians(dropoff_latitude)) *
                    cos(radians(dropoff_longitude) - radians(?)) +
                    sin(radians(?)) * sin(radians(dropoff_latitude))
                )
            ) as dropoff_distance
        ", [
            $pickupLat, $pickupLng, $pickupLat,
            $dropoffLat, $dropoffLng, $dropoffLat
        ])
        ->havingRaw('pickup_distance < ?', [$maxDistance])
        ->havingRaw('dropoff_distance < ?', [$maxDistance])
        ->orderBy('pickup_distance');
    }

    /**
     * Update passenger count.
     */
    public function updatePassengerCount()
    {
        $this->current_passengers = $this->activePassengers()->count();
        $this->save();
    }
}
