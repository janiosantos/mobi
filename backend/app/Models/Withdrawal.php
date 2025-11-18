<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Withdrawal extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'withdrawal_number', 'driver_id', 'amount', 'method', 'status',
        'bank_name', 'bank_account_type', 'bank_agency', 'bank_account',
        'pix_key', 'pix_key_type', 'gateway', 'gateway_transaction_id',
        'gateway_response', 'notes', 'failure_reason', 'processed_at',
        'completed_at', 'failed_at', 'processed_by',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'processed_at' => 'datetime',
            'completed_at' => 'datetime',
            'failed_at' => 'datetime',
        ];
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function processor()
    {
        return $this->belongsTo(User::class, 'processed_by');
    }

    public function earnings()
    {
        return $this->hasMany(Earning::class);
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }
}
