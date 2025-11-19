<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Badge extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon',
        'category',
        'rarity',
        'points',
        'criteria',
        'is_active',
    ];

    protected $casts = [
        'criteria' => 'array',
        'is_active' => 'boolean',
        'points' => 'integer',
    ];

    /**
     * Users who earned this badge
     */
    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_badges')
            ->withTimestamps()
            ->withPivot('earned_at');
    }

    /**
     * Achievements that award this badge
     */
    public function achievements(): HasMany
    {
        return $this->hasMany(Achievement::class);
    }

    /**
     * Check if user has earned this badge
     */
    public function isEarnedBy(User $user): bool
    {
        return $this->users()->where('user_id', $user->id)->exists();
    }

    /**
     * Award badge to user
     */
    public function awardTo(User $user): void
    {
        if (!$this->isEarnedBy($user)) {
            $this->users()->attach($user->id, [
                'earned_at' => now(),
            ]);

            // Add XP to user
            $user->stats()->increment('total_xp', $this->points);
            $user->stats()->increment('current_xp', $this->points);

            // Check for level up
            $user->checkLevelUp();
        }
    }

    /**
     * Get badge color based on rarity
     */
    public function getColorAttribute(): string
    {
        return match ($this->rarity) {
            'common' => '#94A3B8',
            'rare' => '#3B82F6',
            'epic' => '#8B5CF6',
            'legendary' => '#F59E0B',
            default => '#94A3B8',
        };
    }

    /**
     * Scope: Active badges
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope: By category
     */
    public function scopeCategory($query, string $category)
    {
        return $query->where('category', $category);
    }

    /**
     * Scope: By rarity
     */
    public function scopeRarity($query, string $rarity)
    {
        return $query->where('rarity', $rarity);
    }
}
