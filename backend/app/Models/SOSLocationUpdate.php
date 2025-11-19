<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SOSLocationUpdate extends Model
{
    use HasFactory;

    protected $table = 'sos_location_updates';

    protected $fillable = [
        'sos_alert_id',
        'latitude',
        'longitude',
        'accuracy',
        'recorded_at',
    ];

    protected $casts = [
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
        'accuracy' => 'decimal:2',
        'recorded_at' => 'datetime',
    ];

    /**
     * Get the SOS alert
     */
    public function sosAlert(): BelongsTo
    {
        return $this->belongsTo(SOSAlert::class);
    }

    /**
     * Get coordinates as array
     */
    public function getCoordinates(): array
    {
        return [
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
        ];
    }

    /**
     * Calculate distance from another location in meters
     */
    public function distanceFrom(float $lat, float $lng): float
    {
        $earthRadius = 6371000; // meters

        $latFrom = deg2rad($this->latitude);
        $lonFrom = deg2rad($this->longitude);
        $latTo = deg2rad($lat);
        $lonTo = deg2rad($lng);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $a = sin($latDelta / 2) * sin($latDelta / 2) +
             cos($latFrom) * cos($latTo) *
             sin($lonDelta / 2) * sin($lonDelta / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }
}
