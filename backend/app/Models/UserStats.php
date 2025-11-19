<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserStats extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'level',
        'current_xp',
        'total_xp',
        'xp_to_next_level',
        'total_rides',
        'completed_rides',
        'cancelled_rides',
        'total_earnings',
        'average_rating',
        'total_ratings',
        'current_streak',
        'longest_streak',
        'last_ride_date',
        'monthly_stats',
    ];

    protected $casts = [
        'level' => 'integer',
        'current_xp' => 'integer',
        'total_xp' => 'integer',
        'xp_to_next_level' => 'integer',
        'total_rides' => 'integer',
        'completed_rides' => 'integer',
        'cancelled_rides' => 'integer',
        'total_earnings' => 'decimal:2',
        'average_rating' => 'decimal:2',
        'total_ratings' => 'integer',
        'current_streak' => 'integer',
        'longest_streak' => 'integer',
        'last_ride_date' => 'date',
        'monthly_stats' => 'array',
    ];

    /**
     * User who owns these stats
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Calculate XP required for next level
     */
    public static function calculateXpForLevel(int $level): int
    {
        // Formula: 100 * level^1.5
        return (int) (100 * pow($level, 1.5));
    }

    /**
     * Get level from total XP
     */
    public static function getLevelFromXp(int $totalXp): int
    {
        $level = 1;
        $xpRequired = 0;

        while ($totalXp >= $xpRequired) {
            $level++;
            $xpRequired += self::calculateXpForLevel($level - 1);
        }

        return $level - 1;
    }

    /**
     * Update streak
     */
    public function updateStreak(): void
    {
        $today = today();

        if ($this->last_ride_date === null) {
            // First ride
            $this->current_streak = 1;
            $this->longest_streak = 1;
        } elseif ($this->last_ride_date->isSameDay($today)) {
            // Same day, no change
            return;
        } elseif ($this->last_ride_date->addDay()->isSameDay($today)) {
            // Consecutive day
            $this->current_streak++;
            $this->longest_streak = max($this->longest_streak, $this->current_streak);
        } else {
            // Streak broken
            $this->current_streak = 1;
        }

        $this->last_ride_date = $today;
        $this->save();
    }

    /**
     * Add ride to stats
     */
    public function addRide(Ride $ride): void
    {
        $this->increment('total_rides');

        if ($ride->status === 'completed') {
            $this->increment('completed_rides');
            $this->increment('total_earnings', $ride->final_price ?? 0);
            $this->updateStreak();
            $this->updateMonthlyStats($ride);
        } elseif (str_contains($ride->status, 'cancelled')) {
            $this->increment('cancelled_rides');
        }
    }

    /**
     * Update monthly statistics
     */
    protected function updateMonthlyStats(Ride $ride): void
    {
        $monthKey = $ride->created_at->format('Y-m');
        $monthlyStats = $this->monthly_stats ?? [];

        if (!isset($monthlyStats[$monthKey])) {
            $monthlyStats[$monthKey] = [
                'rides' => 0,
                'earnings' => 0,
                'cancelled' => 0,
            ];
        }

        $monthlyStats[$monthKey]['rides']++;
        $monthlyStats[$monthKey]['earnings'] += $ride->final_price ?? 0;

        $this->monthly_stats = $monthlyStats;
        $this->save();
    }

    /**
     * Update rating
     */
    public function updateRating(float $newRating): void
    {
        $totalRatings = $this->total_ratings;
        $currentAverage = $this->average_rating;

        // Calculate new average
        $newAverage = (($currentAverage * $totalRatings) + $newRating) / ($totalRatings + 1);

        $this->average_rating = round($newAverage, 2);
        $this->total_ratings++;
        $this->save();
    }

    /**
     * Get completion rate
     */
    public function getCompletionRateAttribute(): float
    {
        if ($this->total_rides == 0) {
            return 0;
        }

        return round(($this->completed_rides / $this->total_rides) * 100, 2);
    }

    /**
     * Get cancellation rate
     */
    public function getCancellationRateAttribute(): float
    {
        if ($this->total_rides == 0) {
            return 0;
        }

        return round(($this->cancelled_rides / $this->total_rides) * 100, 2);
    }
}
