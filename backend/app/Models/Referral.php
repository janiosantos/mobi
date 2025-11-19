<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Referral extends Model
{
    use HasFactory;

    protected $fillable = [
        'referrer_id',
        'referred_id',
        'referral_code',
        'referred_email',
        'referred_phone',
        'status',
        'referrer_credit',
        'referred_credit',
        'referrer_credit_applied',
        'referred_credit_applied',
        'registered_at',
        'completed_at',
        'expires_at',
    ];

    protected $casts = [
        'referrer_credit' => 'decimal:2',
        'referred_credit' => 'decimal:2',
        'referrer_credit_applied' => 'boolean',
        'referred_credit_applied' => 'boolean',
        'registered_at' => 'datetime',
        'completed_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    // Default credit amounts
    const REFERRER_CREDIT = 20.00; // R$20 for referrer
    const REFERRED_CREDIT = 15.00; // R$15 for referred user
    const EXPIRATION_DAYS = 30;

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    /**
     * The user who made the referral
     */
    public function referrer()
    {
        return $this->belongsTo(User::class, 'referrer_id');
    }

    /**
     * The user who was referred
     */
    public function referred()
    {
        return $this->belongsTo(User::class, 'referred_id');
    }

    /*
    |--------------------------------------------------------------------------
    | Accessors & Methods
    |--------------------------------------------------------------------------
    */

    /**
     * Check if referral is pending
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if referred user has registered
     */
    public function isRegistered(): bool
    {
        return $this->status === 'registered';
    }

    /**
     * Check if referral is completed
     */
    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    /**
     * Check if referral is expired
     */
    public function isExpired(): bool
    {
        if ($this->status === 'expired') {
            return true;
        }

        return $this->expires_at && now()->isAfter($this->expires_at);
    }

    /**
     * Mark referral as registered
     */
    public function markAsRegistered(User $user): void
    {
        $this->update([
            'referred_id' => $user->id,
            'status' => 'registered',
            'registered_at' => now(),
        ]);

        // Update referrer stats
        $this->referrer->increment('referrals_count');
    }

    /**
     * Complete the referral (when referred user takes first ride)
     */
    public function complete(): void
    {
        if ($this->isCompleted()) {
            return;
        }

        $this->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        // Apply credits
        $this->applyCredits();

        // Update referrer stats
        $this->referrer->increment('successful_referrals_count');
    }

    /**
     * Apply credits to both users
     */
    private function applyCredits(): void
    {
        // Apply credit to referrer
        if (!$this->referrer_credit_applied) {
            $this->referrer->increment('wallet_balance', $this->referrer_credit);
            $this->referrer->increment('referral_credits', $this->referrer_credit);
            $this->update(['referrer_credit_applied' => true]);
        }

        // Apply credit to referred user
        if (!$this->referred_credit_applied && $this->referred) {
            $this->referred->increment('wallet_balance', $this->referred_credit);
            $this->referred->increment('referral_credits', $this->referred_credit);
            $this->update(['referred_credit_applied' => true]);
        }
    }

    /**
     * Generate a unique referral code
     */
    public static function generateUniqueCode(): string
    {
        do {
            $code = strtoupper(Str::random(8));
        } while (self::where('referral_code', $code)->exists());

        return $code;
    }

    /*
    |--------------------------------------------------------------------------
    | Scopes
    |--------------------------------------------------------------------------
    */

    /**
     * Scope pending referrals
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending')
            ->where(function($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            });
    }

    /**
     * Scope registered referrals
     */
    public function scopeRegistered($query)
    {
        return $query->where('status', 'registered');
    }

    /**
     * Scope completed referrals
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Scope for a specific referrer
     */
    public function scopeForReferrer($query, int $userId)
    {
        return $query->where('referrer_id', $userId);
    }

    /**
     * Scope for a specific referred user
     */
    public function scopeForReferred($query, int $userId)
    {
        return $query->where('referred_id', $userId);
    }
}
