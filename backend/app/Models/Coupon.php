<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Coupon extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'code', 'description', 'type', 'discount_value',
        'max_discount_amount', 'min_ride_amount', 'max_uses',
        'max_uses_per_user', 'current_uses', 'starts_at',
        'expires_at', 'is_active', 'first_ride_only',
        'allowed_categories', 'allowed_user_ids',
    ];

    protected function casts(): array
    {
        return [
            'discount_value' => 'decimal:2',
            'max_discount_amount' => 'decimal:2',
            'min_ride_amount' => 'decimal:2',
            'starts_at' => 'datetime',
            'expires_at' => 'datetime',
            'is_active' => 'boolean',
            'first_ride_only' => 'boolean',
            'allowed_categories' => 'array',
            'allowed_user_ids' => 'array',
        ];
    }

    public function usages()
    {
        return $this->hasMany(CouponUsage::class);
    }

    public function isValid(): bool
    {
        return $this->is_active
            && (!$this->starts_at || $this->starts_at->isPast())
            && (!$this->expires_at || $this->expires_at->isFuture())
            && (!$this->max_uses || $this->current_uses < $this->max_uses);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
