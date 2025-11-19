<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SOSMonitoringAlert extends Model
{
    use HasFactory;

    protected $table = 'sos_monitoring_alerts';

    protected $fillable = [
        'sos_alert_id',
        'reason',
        'details',
        'status',
        'acknowledged_by',
        'acknowledged_at',
    ];

    protected $casts = [
        'acknowledged_at' => 'datetime',
    ];

    /**
     * Get the SOS alert
     */
    public function sosAlert(): BelongsTo
    {
        return $this->belongsTo(SOSAlert::class);
    }

    /**
     * Get the user who acknowledged
     */
    public function acknowledgedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'acknowledged_by');
    }

    /**
     * Acknowledge the alert
     */
    public function acknowledge(User $user): void
    {
        $this->update([
            'status' => 'acknowledged',
            'acknowledged_by' => $user->id,
            'acknowledged_at' => now(),
        ]);
    }

    /**
     * Mark as resolved
     */
    public function resolve(): void
    {
        $this->update([
            'status' => 'resolved',
        ]);
    }

    /**
     * Check if acknowledged
     */
    public function isAcknowledged(): bool
    {
        return $this->status === 'acknowledged';
    }

    /**
     * Check if resolved
     */
    public function isResolved(): bool
    {
        return $this->status === 'resolved';
    }

    /**
     * Scope for pending alerts
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope for acknowledged alerts
     */
    public function scopeAcknowledged($query)
    {
        return $query->where('status', 'acknowledged');
    }

    /**
     * Scope for resolved alerts
     */
    public function scopeResolved($query)
    {
        return $query->where('status', 'resolved');
    }
}
