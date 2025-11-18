<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Earning extends Model
{
    use HasFactory;

    protected $fillable = [
        'driver_id', 'ride_id', 'payment_id', 'ride_fare',
        'platform_commission', 'platform_commission_percentage',
        'driver_earnings', 'bonus', 'tip', 'total_earnings',
        'status', 'available_at', 'withdrawal_id',
    ];

    protected function casts(): array
    {
        return [
            'ride_fare' => 'decimal:2',
            'platform_commission' => 'decimal:2',
            'platform_commission_percentage' => 'decimal:2',
            'driver_earnings' => 'decimal:2',
            'bonus' => 'decimal:2',
            'tip' => 'decimal:2',
            'total_earnings' => 'decimal:2',
            'available_at' => 'datetime',
        ];
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    public function payment()
    {
        return $this->belongsTo(Payment::class);
    }

    public function withdrawal()
    {
        return $this->belongsTo(Withdrawal::class);
    }

    public function scopeAvailable($query)
    {
        return $query->where('status', 'available');
    }
}
