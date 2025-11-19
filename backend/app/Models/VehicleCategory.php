<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class VehicleCategory extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon',
        'base_fare',
        'per_km_rate',
        'per_minute_rate',
        'minimum_fare',
        'base_multiplier',
        'capacity',
        'max_passengers', // deprecated, use capacity
        'features',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'base_fare' => 'decimal:2',
            'per_km_rate' => 'decimal:2',
            'per_minute_rate' => 'decimal:2',
            'minimum_fare' => 'decimal:2',
            'base_multiplier' => 'decimal:2',
            'capacity' => 'integer',
            'features' => 'array',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function vehicles()
    {
        return $this->hasMany(Vehicle::class);
    }

    public function rides()
    {
        return $this->hasMany(Ride::class);
    }

    public function pricingRules()
    {
        return $this->hasMany(PricingRule::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true)->orderBy('sort_order');
    }

    /**
     * Scope ordered categories
     */
    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order')->orderBy('name');
    }

    /**
     * Scope by slug
     */
    public function scopeBySlug($query, string $slug)
    {
        return $query->where('slug', $slug);
    }

    /**
     * Calculate price for a ride
     */
    public function calculatePrice(float $distanceKm, int $durationMinutes): float
    {
        $distanceFare = $distanceKm * $this->per_km_rate;
        $timeFare = $durationMinutes * $this->per_minute_rate;
        $totalFare = $this->base_fare + $distanceFare + $timeFare;

        // Apply minimum fare
        return max($totalFare, $this->minimum_fare);
    }

    /**
     * Get estimated price range as string
     */
    public function getPriceRangeAttribute(): string
    {
        return 'A partir de R$ ' . number_format($this->minimum_fare, 2, ',', '.');
    }

    /**
     * Get features as comma-separated string
     */
    public function getFeaturesStringAttribute(): string
    {
        if (!$this->features || !is_array($this->features)) {
            return '';
        }

        return implode(', ', $this->features);
    }
}
