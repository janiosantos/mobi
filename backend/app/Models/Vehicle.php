<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Vehicle extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'driver_profile_id',
        'vehicle_category_id',
        'make',
        'model',
        'year',
        'color',
        'license_plate',
        'renavam',
        'seats',
        'photo',
        'has_air_conditioning',
        'is_active',
        'is_primary',
    ];

    protected function casts(): array
    {
        return [
            'has_air_conditioning' => 'boolean',
            'is_active' => 'boolean',
            'is_primary' => 'boolean',
        ];
    }

    public function driverProfile()
    {
        return $this->belongsTo(DriverProfile::class);
    }

    public function category()
    {
        return $this->belongsTo(VehicleCategory::class, 'vehicle_category_id');
    }

    public function rides()
    {
        return $this->hasMany(Ride::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopePrimary($query)
    {
        return $query->where('is_primary', true);
    }
}
