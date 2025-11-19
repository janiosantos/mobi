<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Achievement extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon',
        'type',
        'target_value',
        'target_metric',
        'xp_reward',
        'money_reward',
        'badge_id',
        'requirements',
        'is_repeatable',
        'is_active',
    ];

    protected $casts = [
        'target_value' => 'integer',
        'xp_reward' => 'integer',
        'money_reward' => 'decimal:2',
        'requirements' => 'array',
        'is_repeatable' => 'boolean',
        'is_active' => 'boolean',
    ];

    /**
     * Badge awarded for this achievement
     */
    public function badge(): BelongsTo
    {
        return $this->belongsTo(Badge::class);
    }

    /**
     * User achievements
     */
    public function userAchievements(): HasMany
    {
        return $this->hasMany(UserAchievement::class);
    }

    /**
     * Check achievement progress for user
     */
    public function checkProgress(User $user): ?UserAchievement
    {
        $userAchievement = UserAchievement::firstOrCreate(
            [
                'user_id' => $user->id,
                'achievement_id' => $this->id,
            ],
            [
                'current_progress' => 0,
                'target_progress' => $this->target_value,
            ]
        );

        // Get current metric value
        $currentValue = $this->getCurrentMetricValue($user);

        // Update progress
        $userAchievement->current_progress = $currentValue;

        // Check if completed
        if (!$userAchievement->is_completed && $currentValue >= $this->target_value) {
            $this->complete($user, $userAchievement);
        }

        $userAchievement->save();

        return $userAchievement;
    }

    /**
     * Complete achievement for user
     */
    protected function complete(User $user, UserAchievement $userAchievement): void
    {
        $userAchievement->is_completed = true;
        $userAchievement->completed_at = now();
        $userAchievement->times_completed++;

        // Award XP
        if ($this->xp_reward > 0) {
            $user->stats()->increment('total_xp', $this->xp_reward);
            $user->stats()->increment('current_xp', $this->xp_reward);
            $user->checkLevelUp();
        }

        // Award money
        if ($this->money_reward > 0) {
            $user->wallet()->increment('balance', $this->money_reward);
        }

        // Award badge
        if ($this->badge_id) {
            $this->badge->awardTo($user);
        }

        // Fire event
        event(new \App\Events\AchievementCompleted($user, $this));

        // If repeatable, reset progress
        if ($this->is_repeatable) {
            $userAchievement->is_completed = false;
            $userAchievement->current_progress = 0;
        }
    }

    /**
     * Get current value for target metric
     */
    protected function getCurrentMetricValue(User $user): int
    {
        $stats = $user->stats;

        return match ($this->target_metric) {
            'rides_count' => $stats->total_rides ?? 0,
            'completed_rides' => $stats->completed_rides ?? 0,
            'total_earnings' => (int) ($stats->total_earnings ?? 0),
            'average_rating' => (int) (($stats->average_rating ?? 0) * 10),
            'streak_days' => $stats->current_streak ?? 0,
            'daily_rides' => $this->getDailyRides($user),
            'weekly_rides' => $this->getWeeklyRides($user),
            'night_rides' => $this->getNightRides($user),
            'weekend_rides' => $this->getWeekendRides($user),
            default => 0,
        };
    }

    /**
     * Get daily rides count
     */
    protected function getDailyRides(User $user): int
    {
        return $user->rides()
            ->whereDate('created_at', today())
            ->where('status', 'completed')
            ->count();
    }

    /**
     * Get weekly rides count
     */
    protected function getWeeklyRides(User $user): int
    {
        return $user->rides()
            ->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()])
            ->where('status', 'completed')
            ->count();
    }

    /**
     * Get night rides count (22h - 6h)
     */
    protected function getNightRides(User $user): int
    {
        return $user->rides()
            ->where('status', 'completed')
            ->where(function ($query) {
                $query->whereTime('created_at', '>=', '22:00:00')
                      ->orWhereTime('created_at', '<', '06:00:00');
            })
            ->count();
    }

    /**
     * Get weekend rides count
     */
    protected function getWeekendRides(User $user): int
    {
        return $user->rides()
            ->where('status', 'completed')
            ->whereRaw('DAYOFWEEK(created_at) IN (1, 7)') // Sunday = 1, Saturday = 7
            ->count();
    }

    /**
     * Scope: Active achievements
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope: By type
     */
    public function scopeType($query, string $type)
    {
        return $query->where('type', $type);
    }
}
