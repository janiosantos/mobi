<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class DriverProfile extends Model
{
    use HasFactory, SoftDeletes, LogsActivity;

    protected $fillable = [
        'user_id',
        'license_number',
        'license_category',
        'license_expiry_date',
        'license_photo',
        'status',
        'rejection_reason',
        'approved_at',
        'approved_by',
        'is_online',
        'is_available',
        'current_latitude',
        'current_longitude',
        'heading',
        'speed',
        'last_location_update',
        'went_online_at',
        'went_offline_at',
        'average_rating',
        'total_ratings',
        'total_rides',
        'total_rides_completed',
        'total_rides_cancelled',
        'acceptance_rate',
        'cancellation_rate',
        'total_earnings',
        'available_balance',
        'bank_name',
        'bank_account_type',
        'bank_agency',
        'bank_account',
        'pix_key',
        'pix_key_type',
    ];

    protected function casts(): array
    {
        return [
            'license_expiry_date' => 'date',
            'approved_at' => 'datetime',
            'is_online' => 'boolean',
            'is_available' => 'boolean',
            'current_latitude' => 'decimal:7',
            'current_longitude' => 'decimal:7',
            'heading' => 'decimal:2',
            'speed' => 'decimal:2',
            'last_location_update' => 'datetime',
            'went_online_at' => 'datetime',
            'went_offline_at' => 'datetime',
            'average_rating' => 'decimal:2',
            'acceptance_rate' => 'decimal:2',
            'cancellation_rate' => 'decimal:2',
            'total_earnings' => 'decimal:2',
            'available_balance' => 'decimal:2',
        ];
    }

    /**
     * Activity log options
     */
    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly(['status', 'is_online', 'is_available', 'current_latitude', 'current_longitude'])
            ->logOnlyDirty()
            ->dontSubmitEmptyLogs();
    }

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    /**
     * User relationship (one-to-one inverse)
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Approver (admin who approved)
     */
    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    /**
     * Documents
     */
    public function documents()
    {
        return $this->hasMany(DriverDocument::class);
    }

    /**
     * Vehicles
     */
    public function vehicles()
    {
        return $this->hasMany(Vehicle::class);
    }

    /**
     * Primary vehicle
     */
    public function primaryVehicle()
    {
        return $this->hasOne(Vehicle::class)->where('is_primary', true);
    }

    /**
     * Rides
     */
    public function rides()
    {
        return $this->hasMany(Ride::class, 'driver_id', 'user_id');
    }

    /**
     * Earnings
     */
    public function earnings()
    {
        return $this->hasMany(Earning::class, 'driver_id', 'user_id');
    }

    /**
     * Withdrawals
     */
    public function withdrawals()
    {
        return $this->hasMany(Withdrawal::class, 'driver_id', 'user_id');
    }

    /*
    |--------------------------------------------------------------------------
    | Accessors & Helpers
    |--------------------------------------------------------------------------
    */

    /**
     * Check if driver is approved
     */
    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    /**
     * Check if driver is pending
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if driver is rejected
     */
    public function isRejected(): bool
    {
        return $this->status === 'rejected';
    }

    /**
     * Check if driver can accept rides
     */
    public function canAcceptRides(): bool
    {
        return $this->isApproved()
            && $this->is_online
            && $this->is_available;
    }

    /**
     * Get current location as array
     */
    public function getCurrentLocation(): ?array
    {
        if (!$this->current_latitude || !$this->current_longitude) {
            return null;
        }

        return [
            'latitude' => (float) $this->current_latitude,
            'longitude' => (float) $this->current_longitude,
            'heading' => (float) $this->heading,
            'speed' => (float) $this->speed,
            'updated_at' => $this->last_location_update,
        ];
    }

    /**
     * Calculate distance from a point (in km)
     */
    public function distanceFrom(float $latitude, float $longitude): float
    {
        if (!$this->current_latitude || !$this->current_longitude) {
            return PHP_FLOAT_MAX;
        }

        $earthRadius = 6371; // km

        $latFrom = deg2rad($this->current_latitude);
        $lonFrom = deg2rad($this->current_longitude);
        $latTo = deg2rad($latitude);
        $lonTo = deg2rad($longitude);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }

    /*
    |--------------------------------------------------------------------------
    | Scopes
    |--------------------------------------------------------------------------
    */

    /**
     * Approved drivers
     */
    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    /**
     * Online drivers
     */
    public function scopeOnline($query)
    {
        return $query->where('is_online', true);
    }

    /**
     * Available drivers
     */
    public function scopeAvailable($query)
    {
        return $query->where('is_online', true)
            ->where('is_available', true)
            ->where('status', 'approved');
    }

    /**
     * Drivers near a location
     */
    public function scopeNearby($query, float $latitude, float $longitude, float $radiusKm = 5)
    {
        // Using Haversine formula for distance calculation in SQL
        $query->selectRaw("
            *, (
                6371 * acos(
                    cos(radians(?)) *
                    cos(radians(current_latitude)) *
                    cos(radians(current_longitude) - radians(?)) +
                    sin(radians(?)) *
                    sin(radians(current_latitude))
                )
            ) AS distance
        ", [$latitude, $longitude, $latitude])
        ->having('distance', '<=', $radiusKm)
        ->orderBy('distance');

        return $query;
    }
}
