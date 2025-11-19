<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class Ride extends Model
{
    use HasFactory, SoftDeletes, LogsActivity;

    protected $fillable = [
        'ride_number',
        'passenger_id',
        'driver_id',
        'vehicle_id',
        'vehicle_category_id',
        'pickup_latitude',
        'pickup_longitude',
        'pickup_address',
        'pickup_city',
        'pickup_state',
        'pickup_country',
        'pickup_postal_code',
        'pickup_notes',
        'dropoff_latitude',
        'dropoff_longitude',
        'dropoff_address',
        'dropoff_city',
        'dropoff_state',
        'dropoff_country',
        'dropoff_postal_code',
        'dropoff_notes',
        'has_stops',
        'stops_count',
        'estimated_distance',
        'estimated_duration',
        'actual_distance',
        'actual_duration',
        'route_polyline',
        'estimated_price',
        'final_price',
        'base_fare',
        'distance_fare',
        'time_fare',
        'surge_multiplier',
        'discount_amount',
        'coupon_id',
        'platform_fee',
        'driver_earnings',
        'status',
        'requested_at',
        'accepted_at',
        'driver_arrived_at',
        'started_at',
        'completed_at',
        'cancelled_at',
        'cancelled_by',
        'cancellation_reason',
        'cancellation_fee',
        'payment_status',
        'payment_method',
        'payment_id',
        'passenger_notes',
        'waiting_time',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'pickup_latitude' => 'decimal:7',
            'pickup_longitude' => 'decimal:7',
            'dropoff_latitude' => 'decimal:7',
            'dropoff_longitude' => 'decimal:7',
            'has_stops' => 'boolean',
            'stops_count' => 'integer',
            'estimated_distance' => 'decimal:2',
            'actual_distance' => 'decimal:2',
            'estimated_price' => 'decimal:2',
            'final_price' => 'decimal:2',
            'base_fare' => 'decimal:2',
            'distance_fare' => 'decimal:2',
            'time_fare' => 'decimal:2',
            'surge_multiplier' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'platform_fee' => 'decimal:2',
            'driver_earnings' => 'decimal:2',
            'cancellation_fee' => 'decimal:2',
            'requested_at' => 'datetime',
            'accepted_at' => 'datetime',
            'driver_arrived_at' => 'datetime',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
            'cancelled_at' => 'datetime',
            'metadata' => 'array',
        ];
    }

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly(['status', 'driver_id', 'payment_status'])
            ->logOnlyDirty()
            ->dontSubmitEmptyLogs();
    }

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    public function passenger()
    {
        return $this->belongsTo(User::class, 'passenger_id');
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class);
    }

    public function category()
    {
        return $this->belongsTo(VehicleCategory::class, 'vehicle_category_id');
    }

    public function payment()
    {
        return $this->belongsTo(Payment::class);
    }

    public function coupon()
    {
        return $this->belongsTo(Coupon::class);
    }

    public function locations()
    {
        return $this->hasMany(RideLocation::class);
    }

    public function messages()
    {
        return $this->hasMany(Message::class);
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }

    public function passengerRating()
    {
        return $this->hasOne(Rating::class)->where('rater_type', 'passenger');
    }

    public function driverRating()
    {
        return $this->hasOne(Rating::class)->where('rater_type', 'driver');
    }

    public function stops()
    {
        return $this->hasMany(RideStop::class)->orderBy('stop_number');
    }

    /*
    |--------------------------------------------------------------------------
    | Accessors & Methods
    |--------------------------------------------------------------------------
    */

    public function isActive(): bool
    {
        return in_array($this->status, ['requested', 'searching', 'accepted', 'driver_arrived', 'in_progress']);
    }

    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    public function isCancelled(): bool
    {
        return in_array($this->status, ['cancelled_by_passenger', 'cancelled_by_driver', 'cancelled_by_system']);
    }

    public function canBeCancelled(): bool
    {
        return in_array($this->status, ['requested', 'searching', 'accepted', 'driver_arrived']);
    }

    public function canBeStarted(): bool
    {
        return $this->status === 'driver_arrived';
    }

    public function canBeCompleted(): bool
    {
        return $this->status === 'in_progress';
    }

    public function getPickupLocation(): array
    {
        return [
            'latitude' => (float) $this->pickup_latitude,
            'longitude' => (float) $this->pickup_longitude,
            'address' => $this->pickup_address,
        ];
    }

    public function getDropoffLocation(): array
    {
        return [
            'latitude' => (float) $this->dropoff_latitude,
            'longitude' => (float) $this->dropoff_longitude,
            'address' => $this->dropoff_address,
        ];
    }

    public function getDurationInMinutes(): ?int
    {
        if (!$this->started_at || !$this->completed_at) {
            return null;
        }

        return $this->started_at->diffInMinutes($this->completed_at);
    }

    /*
    |--------------------------------------------------------------------------
    | Scopes
    |--------------------------------------------------------------------------
    */

    public function scopeActive($query)
    {
        return $query->whereIn('status', ['requested', 'searching', 'accepted', 'driver_arrived', 'in_progress']);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeCancelled($query)
    {
        return $query->whereIn('status', ['cancelled_by_passenger', 'cancelled_by_driver', 'cancelled_by_system']);
    }

    public function scopeForPassenger($query, $passengerId)
    {
        return $query->where('passenger_id', $passengerId);
    }

    public function scopeForDriver($query, $driverId)
    {
        return $query->where('driver_id', $driverId);
    }

    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    public function scopeThisMonth($query)
    {
        return $query->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year);
    }
}
