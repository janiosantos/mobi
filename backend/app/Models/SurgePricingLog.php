<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SurgePricingLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'vehicle_category_id', 'latitude', 'longitude', 'radius',
        'area_name', 'multiplier', 'demand_level', 'supply_level',
        'starts_at', 'ends_at', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'radius' => 'decimal:2',
            'multiplier' => 'decimal:2',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    public function category()
    {
        return $this->belongsTo(VehicleCategory::class, 'vehicle_category_id');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
