<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PaymentMethod extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id', 'type', 'is_default', 'card_token', 'card_brand',
        'card_last_four', 'card_holder_name', 'card_expiry_month',
        'card_expiry_year', 'pix_key', 'pix_key_type', 'gateway',
        'gateway_customer_id', 'gateway_payment_method_id', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_default' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function isCard(): bool
    {
        return in_array($this->type, ['credit_card', 'debit_card']);
    }

    public function isPix(): bool
    {
        return $this->type === 'pix';
    }
}
