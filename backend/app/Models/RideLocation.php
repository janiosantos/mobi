<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RideLocation extends Model
{
    use HasFactory;

    protected $fillable = [
        'ride_id', 'driver_id', 'latitude', 'longitude',
        'heading', 'speed', 'accuracy', 'recorded_at',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'heading' => 'decimal:2',
            'speed' => 'decimal:2',
            'accuracy' => 'decimal:2',
            'recorded_at' => 'datetime',
        ];
    }

    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }
}
