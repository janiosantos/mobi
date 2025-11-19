<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class SOSAlert extends Model
{
    use HasFactory;

    protected $table = 'sos_alerts';

    protected $fillable = [
        'user_id',
        'ride_id',
        'status',
        'latitude',
        'longitude',
        'accuracy',
        'note',
        'tracking_code',
        'activated_at',
        'deactivated_at',
        'resolution',
        'last_heartbeat_at',
    ];

    protected $casts = [
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
        'accuracy' => 'decimal:2',
        'activated_at' => 'datetime',
        'deactivated_at' => 'datetime',
        'last_heartbeat_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($sosAlert) {
            if (!$sosAlert->tracking_code) {
                $sosAlert->tracking_code = static::generateTrackingCode();
            }

            if (!$sosAlert->activated_at) {
                $sosAlert->activated_at = now();
            }
        });
    }

    /**
     * Generate unique tracking code
     */
    protected static function generateTrackingCode(): string
    {
        do {
            $code = 'SOS-' . strtoupper(Str::random(10));
        } while (static::where('tracking_code', $code)->exists());

        return $code;
    }

    /**
     * Get the user who triggered the SOS
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the associated ride
     */
    public function ride(): BelongsTo
    {
        return $this->belongsTo(Ride::class);
    }

    /**
     * Get location updates
     */
    public function locationUpdates(): HasMany
    {
        return $this->hasMany(SOSLocationUpdate::class);
    }

    /**
     * Get notifications sent
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(SOSNotification::class);
    }

    /**
     * Get monitoring alerts
     */
    public function monitoringAlerts(): HasMany
    {
        return $this->hasMany(SOSMonitoringAlert::class);
    }

    /**
     * Scope for active alerts
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Scope for resolved alerts
     */
    public function scopeResolved($query)
    {
        return $query->where('status', 'resolved');
    }

    /**
     * Scope for recent alerts
     */
    public function scopeRecent($query, $hours = 24)
    {
        return $query->where('activated_at', '>=', now()->subHours($hours));
    }

    /**
     * Check if SOS is active
     */
    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    /**
     * Check if SOS is resolved
     */
    public function isResolved(): bool
    {
        return $this->status === 'resolved';
    }

    /**
     * Deactivate the SOS alert
     */
    public function deactivate(string $resolution = null): void
    {
        $this->update([
            'status' => 'resolved',
            'deactivated_at' => now(),
            'resolution' => $resolution,
        ]);
    }

    /**
     * Update heartbeat timestamp
     */
    public function heartbeat(): void
    {
        $this->update([
            'last_heartbeat_at' => now(),
        ]);
    }

    /**
     * Add location update
     */
    public function addLocationUpdate(float $latitude, float $longitude, float $accuracy = null): SOSLocationUpdate
    {
        return $this->locationUpdates()->create([
            'latitude' => $latitude,
            'longitude' => $longitude,
            'accuracy' => $accuracy,
            'recorded_at' => now(),
        ]);
    }

    /**
     * Get tracking URL
     */
    public function getTrackingUrl(): string
    {
        return config('app.url') . '/track-sos/' . $this->tracking_code;
    }

    /**
     * Get latest location
     */
    public function getLatestLocation(): array
    {
        $latest = $this->locationUpdates()->latest('recorded_at')->first();

        if ($latest) {
            return [
                'latitude' => $latest->latitude,
                'longitude' => $latest->longitude,
                'accuracy' => $latest->accuracy,
                'recorded_at' => $latest->recorded_at,
            ];
        }

        return [
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'accuracy' => $this->accuracy,
            'recorded_at' => $this->activated_at,
        ];
    }

    /**
     * Get duration in seconds
     */
    public function getDurationInSeconds(): int
    {
        $end = $this->deactivated_at ?? now();
        return $this->activated_at->diffInSeconds($end);
    }

    /**
     * Get formatted duration
     */
    public function getFormattedDuration(): string
    {
        $seconds = $this->getDurationInSeconds();
        $hours = floor($seconds / 3600);
        $minutes = floor(($seconds % 3600) / 60);
        $secs = $seconds % 60;

        if ($hours > 0) {
            return sprintf('%dh %dm %ds', $hours, $minutes, $secs);
        } elseif ($minutes > 0) {
            return sprintf('%dm %ds', $minutes, $secs);
        } else {
            return sprintf('%ds', $secs);
        }
    }
}
