<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SOSNotification extends Model
{
    use HasFactory;

    protected $table = 'sos_notifications';

    protected $fillable = [
        'sos_alert_id',
        'emergency_contact_id',
        'status',
        'sent_at',
        'error_message',
    ];

    protected $casts = [
        'sent_at' => 'datetime',
    ];

    /**
     * Get the SOS alert
     */
    public function sosAlert(): BelongsTo
    {
        return $this->belongsTo(SOSAlert::class);
    }

    /**
     * Get the emergency contact
     */
    public function emergencyContact(): BelongsTo
    {
        return $this->belongsTo(EmergencyContact::class);
    }

    /**
     * Mark as sent
     */
    public function markAsSent(): void
    {
        $this->update([
            'status' => 'sent',
            'sent_at' => now(),
        ]);
    }

    /**
     * Mark as failed
     */
    public function markAsFailed(string $errorMessage): void
    {
        $this->update([
            'status' => 'failed',
            'error_message' => $errorMessage,
        ]);
    }

    /**
     * Check if sent
     */
    public function isSent(): bool
    {
        return $this->status === 'sent';
    }

    /**
     * Check if failed
     */
    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Scope for pending notifications
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope for sent notifications
     */
    public function scopeSent($query)
    {
        return $query->where('status', 'sent');
    }

    /**
     * Scope for failed notifications
     */
    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }
}
