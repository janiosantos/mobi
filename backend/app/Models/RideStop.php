<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RideStop extends Model
{
    use HasFactory;

    protected $fillable = [
        'ride_id',
        'stop_number',
        'address',
        'latitude',
        'longitude',
        'wait_time_minutes',
        'arrived_at',
        'departed_at',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'wait_time_minutes' => 'integer',
        'arrived_at' => 'datetime',
        'departed_at' => 'datetime',
    ];

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    /**
     * Ride relationship
     */
    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    /*
    |--------------------------------------------------------------------------
    | Accessors & Mutators
    |--------------------------------------------------------------------------
    */

    /**
     * Check if driver has arrived at this stop
     */
    public function hasArrived(): bool
    {
        return !is_null($this->arrived_at);
    }

    /**
     * Check if driver has departed from this stop
     */
    public function hasDeparted(): bool
    {
        return !is_null($this->departed_at);
    }

    /**
     * Check if stop is completed (arrived and departed)
     */
    public function isCompleted(): bool
    {
        return $this->hasArrived() && $this->hasDeparted();
    }

    /**
     * Check if currently at this stop (arrived but not departed)
     */
    public function isCurrentStop(): bool
    {
        return $this->hasArrived() && !$this->hasDeparted();
    }

    /**
     * Get wait time remaining in minutes
     */
    public function getWaitTimeRemainingAttribute(): ?int
    {
        if (!$this->hasArrived() || $this->hasDeparted()) {
            return null;
        }

        $elapsedMinutes = now()->diffInMinutes($this->arrived_at);
        $remaining = $this->wait_time_minutes - $elapsedMinutes;

        return max(0, $remaining);
    }

    /*
    |--------------------------------------------------------------------------
    | Scopes
    |--------------------------------------------------------------------------
    */

    /**
     * Scope stops for a specific ride
     */
    public function scopeForRide($query, int $rideId)
    {
        return $query->where('ride_id', $rideId)->orderBy('stop_number');
    }

    /**
     * Scope completed stops
     */
    public function scopeCompleted($query)
    {
        return $query->whereNotNull('arrived_at')
            ->whereNotNull('departed_at');
    }

    /**
     * Scope pending stops
     */
    public function scopePending($query)
    {
        return $query->whereNull('arrived_at');
    }
}
