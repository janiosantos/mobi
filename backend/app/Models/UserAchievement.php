<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserAchievement extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'achievement_id',
        'current_progress',
        'target_progress',
        'is_completed',
        'completed_at',
        'times_completed',
    ];

    protected $casts = [
        'current_progress' => 'integer',
        'target_progress' => 'integer',
        'is_completed' => 'boolean',
        'completed_at' => 'datetime',
        'times_completed' => 'integer',
    ];

    /**
     * User who owns this achievement
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Achievement reference
     */
    public function achievement(): BelongsTo
    {
        return $this->belongsTo(Achievement::class);
    }

    /**
     * Get progress percentage
     */
    public function getProgressPercentageAttribute(): float
    {
        if ($this->target_progress == 0) {
            return 0;
        }

        return min(($this->current_progress / $this->target_progress) * 100, 100);
    }

    /**
     * Scope: Completed achievements
     */
    public function scopeCompleted($query)
    {
        return $query->where('is_completed', true);
    }

    /**
     * Scope: In progress
     */
    public function scopeInProgress($query)
    {
        return $query->where('is_completed', false)
            ->where('current_progress', '>', 0);
    }

    /**
     * Scope: Not started
     */
    public function scopeNotStarted($query)
    {
        return $query->where('is_completed', false)
            ->where('current_progress', 0);
    }
}
