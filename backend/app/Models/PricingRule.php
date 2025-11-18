<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PricingRule extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'vehicle_category_id', 'name', 'description', 'base_fare',
        'price_per_km', 'price_per_minute', 'minimum_fare',
        'effective_from_time', 'effective_to_time', 'effective_days',
        'multiplier', 'priority', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'base_fare' => 'decimal:2',
            'price_per_km' => 'decimal:2',
            'price_per_minute' => 'decimal:2',
            'minimum_fare' => 'decimal:2',
            'multiplier' => 'decimal:2',
            'effective_days' => 'array',
            'is_active' => 'boolean',
        ];
    }

    public function category()
    {
        return $this->belongsTo(VehicleCategory::class, 'vehicle_category_id');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true)->orderByDesc('priority');
    }
}
