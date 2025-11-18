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
        'base_multiplier',
        'max_passengers',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'base_multiplier' => 'decimal:2',
            'is_active' => 'boolean',
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
}
