<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RideSplitPayment extends Model
{
    use HasFactory;

    protected $fillable = [
        'ride_id',
        'user_id',
        'invited_by',
        'invite_code',
        'amount',
        'percentage',
        'status',
        'accepted_at',
        'paid_at',
        'declined_at',
        'expires_at',
        'decline_reason',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'percentage' => 'decimal:2',
        'accepted_at' => 'datetime',
        'paid_at' => 'datetime',
        'declined_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    /**
     * The ride this split payment belongs to
     */
    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    /**
     * The user who will pay this split
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * The user who invited this person to split
     */
    public function inviter()
    {
        return $this->belongsTo(User::class, 'invited_by');
    }

    /*
    |--------------------------------------------------------------------------
    | Accessors & Methods
    |--------------------------------------------------------------------------
    */

    /**
     * Check if split payment is pending
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if split payment was accepted
     */
    public function isAccepted(): bool
    {
        return $this->status === 'accepted';
    }

    /**
     * Check if split payment was paid
     */
    public function isPaid(): bool
    {
        return $this->status === 'paid';
    }

    /**
     * Check if split payment was declined
     */
    public function isDeclined(): bool
    {
        return $this->status === 'declined';
    }

    /**
     * Check if split payment is expired
     */
    public function isExpired(): bool
    {
        if ($this->status === 'expired') {
            return true;
        }

        return $this->expires_at && now()->isAfter($this->expires_at);
    }

    /**
     * Accept the split payment invitation
     */
    public function accept(): void
    {
        $this->update([
            'status' => 'accepted',
            'accepted_at' => now(),
        ]);
    }

    /**
     * Decline the split payment invitation
     */
    public function decline(string $reason = null): void
    {
        $this->update([
            'status' => 'declined',
            'declined_at' => now(),
            'decline_reason' => $reason,
        ]);
    }

    /**
     * Mark split payment as paid
     */
    public function markAsPaid(): void
    {
        $this->update([
            'status' => 'paid',
            'paid_at' => now(),
        ]);
    }

    /*
    |--------------------------------------------------------------------------
    | Scopes
    |--------------------------------------------------------------------------
    */

    /**
     * Scope pending split payments
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
     * Scope accepted split payments
     */
    public function scopeAccepted($query)
    {
        return $query->where('status', 'accepted');
    }

    /**
     * Scope paid split payments
     */
    public function scopePaid($query)
    {
        return $query->where('status', 'paid');
    }

    /**
     * Scope for a specific ride
     */
    public function scopeForRide($query, int $rideId)
    {
        return $query->where('ride_id', $rideId);
    }

    /**
     * Scope for a specific user
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }
}
