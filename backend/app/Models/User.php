<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasFactory, Notifiable, HasApiTokens, SoftDeletes, HasRoles, LogsActivity;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'user_type',
        'profile_photo',
        'cpf',
        'birth_date',
        'gender',
        'wallet_balance',
        'average_rating',
        'total_ratings',
        'is_active',
        'is_banned',
        'banned_at',
        'ban_reason',
        'fcm_token',
        'device_type',
        'app_version',
        'last_active_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'birth_date' => 'date',
            'wallet_balance' => 'decimal:2',
            'average_rating' => 'decimal:2',
            'is_active' => 'boolean',
            'is_banned' => 'boolean',
            'banned_at' => 'datetime',
            'last_active_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Activity log options
     */
    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly(['name', 'email', 'user_type', 'is_active', 'is_banned'])
            ->logOnlyDirty()
            ->dontSubmitEmptyLogs();
    }

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    /**
     * Driver profile relationship (one-to-one)
     */
    public function driverProfile()
    {
        return $this->hasOne(DriverProfile::class, 'user_id');
    }

    /**
     * Rides as passenger (one-to-many)
     */
    public function ridesAsPassenger()
    {
        return $this->hasMany(Ride::class, 'passenger_id');
    }

    /**
     * Rides as driver (one-to-many)
     */
    public function ridesAsDriver()
    {
        return $this->hasMany(Ride::class, 'driver_id');
    }

    /**
     * Payment methods (one-to-many)
     */
    public function paymentMethods()
    {
        return $this->hasMany(PaymentMethod::class);
    }

    /**
     * Payments (one-to-many)
     */
    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Ratings given by this user (one-to-many)
     */
    public function ratingsGiven()
    {
        return $this->hasMany(Rating::class, 'rater_id');
    }

    /**
     * Ratings received by this user (one-to-many)
     */
    public function ratingsReceived()
    {
        return $this->hasMany(Rating::class, 'rated_id');
    }

    /**
     * Messages sent (one-to-many)
     */
    public function messagesSent()
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    /**
     * Messages received (one-to-many)
     */
    public function messagesReceived()
    {
        return $this->hasMany(Message::class, 'recipient_id');
    }

    /**
     * Earnings (for drivers)
     */
    public function earnings()
    {
        return $this->hasMany(Earning::class, 'driver_id');
    }

    /**
     * Withdrawals (for drivers)
     */
    public function withdrawals()
    {
        return $this->hasMany(Withdrawal::class, 'driver_id');
    }

    /**
     * Coupon usage
     */
    public function couponUsage()
    {
        return $this->hasMany(CouponUsage::class);
    }

    /*
    |--------------------------------------------------------------------------
    | Accessors & Mutators
    |--------------------------------------------------------------------------
    */

    /**
     * Get user's full address if exists
     */
    public function getFullNameAttribute(): string
    {
        return $this->name;
    }

    /**
     * Check if user is a driver
     */
    public function isDriver(): bool
    {
        return $this->user_type === 'driver';
    }

    /**
     * Check if user is a passenger
     */
    public function isPassenger(): bool
    {
        return $this->user_type === 'passenger';
    }

    /**
     * Check if user is an admin
     */
    public function isAdmin(): bool
    {
        return $this->user_type === 'admin';
    }

    /**
     * Check if driver is approved
     */
    public function isApprovedDriver(): bool
    {
        return $this->isDriver()
            && $this->driverProfile
            && $this->driverProfile->status === 'approved';
    }

    /**
     * Check if driver is online
     */
    public function isOnline(): bool
    {
        return $this->isDriver()
            && $this->driverProfile
            && $this->driverProfile->is_online;
    }

    /**
     * Get user's active ride
     */
    public function getActiveRideAttribute()
    {
        if ($this->isPassenger()) {
            return $this->ridesAsPassenger()
                ->whereIn('status', ['requested', 'searching', 'accepted', 'driver_arrived', 'in_progress'])
                ->latest()
                ->first();
        }

        if ($this->isDriver()) {
            return $this->ridesAsDriver()
                ->whereIn('status', ['accepted', 'driver_arrived', 'in_progress'])
                ->latest()
                ->first();
        }

        return null;
    }

    /**
     * Get default payment method
     */
    public function defaultPaymentMethod()
    {
        return $this->paymentMethods()->where('is_default', true)->first();
    }

    /*
    |--------------------------------------------------------------------------
    | Scopes
    |--------------------------------------------------------------------------
    */

    /**
     * Scope drivers only
     */
    public function scopeDrivers($query)
    {
        return $query->where('user_type', 'driver');
    }

    /**
     * Scope passengers only
     */
    public function scopePassengers($query)
    {
        return $query->where('user_type', 'passenger');
    }

    /**
     * Scope active users
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)->where('is_banned', false);
    }

    /**
     * Scope verified users
     */
    public function scopeVerified($query)
    {
        return $query->whereNotNull('email_verified_at');
    }
}
