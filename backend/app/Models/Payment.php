<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Payment extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'payment_number', 'ride_id', 'user_id', 'payment_method_id',
        'payment_type', 'amount', 'platform_fee', 'driver_amount',
        'status', 'gateway', 'gateway_transaction_id', 'gateway_payment_id',
        'gateway_response', 'pix_qr_code', 'pix_qr_code_base64',
        'pix_transaction_id', 'pix_expires_at', 'card_brand',
        'card_last_four', 'installments', 'refund_amount',
        'refund_reason', 'refunded_at', 'processed_at',
        'failed_at', 'failure_reason',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'platform_fee' => 'decimal:2',
            'driver_amount' => 'decimal:2',
            'refund_amount' => 'decimal:2',
            'pix_expires_at' => 'datetime',
            'refunded_at' => 'datetime',
            'processed_at' => 'datetime',
            'failed_at' => 'datetime',
        ];
    }

    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function paymentMethod()
    {
        return $this->belongsTo(PaymentMethod::class);
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }
}
