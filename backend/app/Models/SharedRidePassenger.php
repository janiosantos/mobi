<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SharedRidePassenger extends Model
{
    use HasFactory;

    protected $fillable = [
        'shared_ride_id',
        'passenger_id',
        'pickup_latitude',
        'pickup_longitude',
        'pickup_address',
        'dropoff_latitude',
        'dropoff_longitude',
        'dropoff_address',
        'status',
        'price',
    ];

    protected $casts = [
        'pickup_latitude' => 'float',
        'pickup_longitude' => 'float',
        'dropoff_latitude' => 'float',
        'dropoff_longitude' => 'float',
        'price' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = ['passenger_name', 'passenger_photo_url', 'joined_at'];

    /**
     * Get the shared ride.
     */
    public function sharedRide()
    {
        return $this->belongsTo(SharedRide::class);
    }

    /**
     * Get the passenger user.
     */
    public function passenger()
    {
        return $this->belongsTo(User::class, 'passenger_id');
    }

    /**
     * Get passenger name attribute.
     */
    public function getPassengerNameAttribute()
    {
        return $this->passenger ? $this->passenger->name : 'Unknown';
    }

    /**
     * Get passenger photo URL attribute.
     */
    public function getPassengerPhotoUrlAttribute()
    {
        return $this->passenger ? $this->passenger->photo_url : null;
    }

    /**
     * Get joined at attribute (alias for created_at).
     */
    public function getJoinedAtAttribute()
    {
        return $this->created_at;
    }

    /**
     * Scope to filter by status.
     */
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope to filter confirmed passengers.
     */
    public function scopeConfirmed($query)
    {
        return $query->where('status', 'confirmed');
    }

    /**
     * Mark passenger as picked up.
     */
    public function markAsPickedUp()
    {
        $this->update(['status' => 'picked_up']);
    }

    /**
     * Mark passenger as dropped off.
     */
    public function markAsDroppedOff()
    {
        $this->update(['status' => 'dropped_off']);
    }

    /**
     * Cancel passenger's participation.
     */
    public function cancel()
    {
        $this->update(['status' => 'cancelled']);
        $this->sharedRide->updatePassengerCount();
    }
}
