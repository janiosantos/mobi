<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Achievement;
use App\Models\Badge;
use App\Models\User;
use App\Models\UserStats;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class GamificationController extends Controller
{
    /**
     * Get user's gamification profile
     */
    public function profile(Request $request): JsonResponse
    {
        $user = $request->user();

        // Ensure user has stats
        $stats = $user->stats()->firstOrCreate([
            'user_id' => $user->id,
        ]);

        // Load badges
        $badges = $user->badges()
            ->withPivot('earned_at')
            ->orderBy('pivot_earned_at', 'desc')
            ->get();

        // Load achievements progress
        $achievements = $user->achievements()
            ->with('achievement')
            ->where('is_completed', true)
            ->orderBy('completed_at', 'desc')
            ->get();

        $inProgress = $user->achievements()
            ->with('achievement')
            ->where('is_completed', false)
            ->where('current_progress', '>', 0)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => [
                    'level' => $stats->level,
                    'current_xp' => $stats->current_xp,
                    'total_xp' => $stats->total_xp,
                    'xp_to_next_level' => $stats->xp_to_next_level,
                    'progress_percentage' => $stats->xp_to_next_level > 0
                        ? round(($stats->current_xp / $stats->xp_to_next_level) * 100, 2)
                        : 0,
                ],
                'rides' => [
                    'total' => $stats->total_rides,
                    'completed' => $stats->completed_rides,
                    'cancelled' => $stats->cancelled_rides,
                    'completion_rate' => $stats->completion_rate,
                ],
                'earnings' => [
                    'total' => (float) $stats->total_earnings,
                ],
                'ratings' => [
                    'average' => (float) $stats->average_rating,
                    'total' => $stats->total_ratings,
                ],
                'streak' => [
                    'current' => $stats->current_streak,
                    'longest' => $stats->longest_streak,
                    'last_ride_date' => $stats->last_ride_date?->format('Y-m-d'),
                ],
                'badges' => [
                    'total' => $badges->count(),
                    'by_rarity' => $badges->groupBy('rarity')->map->count(),
                    'earned' => $badges->map(function ($badge) {
                        return [
                            'id' => $badge->id,
                            'name' => $badge->name,
                            'description' => $badge->description,
                            'icon' => $badge->icon,
                            'category' => $badge->category,
                            'rarity' => $badge->rarity,
                            'points' => $badge->points,
                            'earned_at' => $badge->pivot->earned_at,
                        ];
                    }),
                ],
                'achievements' => [
                    'completed' => $achievements->map(function ($ua) {
                        return [
                            'id' => $ua->achievement->id,
                            'name' => $ua->achievement->name,
                            'description' => $ua->achievement->description,
                            'icon' => $ua->achievement->icon,
                            'type' => $ua->achievement->type,
                            'xp_reward' => $ua->achievement->xp_reward,
                            'money_reward' => (float) $ua->achievement->money_reward,
                            'completed_at' => $ua->completed_at,
                            'times_completed' => $ua->times_completed,
                        ];
                    }),
                    'in_progress' => $inProgress->map(function ($ua) {
                        return [
                            'id' => $ua->achievement->id,
                            'name' => $ua->achievement->name,
                            'description' => $ua->achievement->description,
                            'icon' => $ua->achievement->icon,
                            'type' => $ua->achievement->type,
                            'current_progress' => $ua->current_progress,
                            'target_progress' => $ua->target_progress,
                            'progress_percentage' => $ua->progress_percentage,
                        ];
                    }),
                ],
            ],
        ]);
    }

    /**
     * Get all available badges
     */
    public function badges(Request $request): JsonResponse
    {
        $user = $request->user();

        $badges = Badge::active()
            ->get()
            ->map(function ($badge) use ($user) {
                return [
                    'id' => $badge->id,
                    'name' => $badge->name,
                    'slug' => $badge->slug,
                    'description' => $badge->description,
                    'icon' => $badge->icon,
                    'category' => $badge->category,
                    'rarity' => $badge->rarity,
                    'points' => $badge->points,
                    'is_earned' => $badge->isEarnedBy($user),
                    'earned_at' => $badge->isEarnedBy($user)
                        ? $badge->users()->where('user_id', $user->id)->first()?->pivot?->earned_at
                        : null,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $badges->groupBy('category'),
        ]);
    }

    /**
     * Get all achievements
     */
    public function achievements(Request $request): JsonResponse
    {
        $user = $request->user();

        $achievements = Achievement::active()
            ->with('badge')
            ->get()
            ->map(function ($achievement) use ($user) {
                $userAchievement = $user->achievements()
                    ->where('achievement_id', $achievement->id)
                    ->first();

                return [
                    'id' => $achievement->id,
                    'name' => $achievement->name,
                    'slug' => $achievement->slug,
                    'description' => $achievement->description,
                    'icon' => $achievement->icon,
                    'type' => $achievement->type,
                    'target_value' => $achievement->target_value,
                    'target_metric' => $achievement->target_metric,
                    'xp_reward' => $achievement->xp_reward,
                    'money_reward' => (float) $achievement->money_reward,
                    'badge' => $achievement->badge ? [
                        'name' => $achievement->badge->name,
                        'icon' => $achievement->badge->icon,
                        'rarity' => $achievement->badge->rarity,
                    ] : null,
                    'is_repeatable' => $achievement->is_repeatable,
                    'progress' => $userAchievement ? [
                        'current' => $userAchievement->current_progress,
                        'target' => $userAchievement->target_progress,
                        'percentage' => $userAchievement->progress_percentage,
                        'is_completed' => $userAchievement->is_completed,
                        'completed_at' => $userAchievement->completed_at,
                        'times_completed' => $userAchievement->times_completed,
                    ] : [
                        'current' => 0,
                        'target' => $achievement->target_value,
                        'percentage' => 0,
                        'is_completed' => false,
                        'completed_at' => null,
                        'times_completed' => 0,
                    ],
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $achievements->groupBy('type'),
        ]);
    }

    /**
     * Get leaderboard
     */
    public function leaderboard(Request $request): JsonResponse
    {
        $type = $request->input('type', 'weekly'); // weekly, monthly, all_time
        $category = $request->input('category', 'rides'); // rides, earnings, ratings, xp
        $limit = min($request->input('limit', 50), 100);

        $query = UserStats::query()
            ->with('user:id,name,email,photo_url')
            ->orderByDesc($this->getOrderColumn($category))
            ->limit($limit);

        $leaderboard = $query->get()->map(function ($stats, $index) use ($category) {
            return [
                'rank' => $index + 1,
                'user' => [
                    'id' => $stats->user->id,
                    'name' => $stats->user->name,
                    'photo_url' => $stats->user->photo_url,
                ],
                'score' => $this->getScore($stats, $category),
                'stats' => [
                    'level' => $stats->level,
                    'total_rides' => $stats->total_rides,
                    'total_earnings' => (float) $stats->total_earnings,
                    'average_rating' => (float) $stats->average_rating,
                    'total_xp' => $stats->total_xp,
                ],
            ];
        });

        // Get current user's rank
        $user = $request->user();
        $userRank = $leaderboard->search(function ($item) use ($user) {
            return $item['user']['id'] === $user->id;
        });

        return response()->json([
            'success' => true,
            'data' => [
                'type' => $type,
                'category' => $category,
                'leaderboard' => $leaderboard,
                'current_user' => [
                    'rank' => $userRank !== false ? $userRank + 1 : null,
                    'score' => $this->getScore($user->stats, $category),
                ],
            ],
        ]);
    }

    /**
     * Check and update achievements progress
     */
    public function checkProgress(Request $request): JsonResponse
    {
        $user = $request->user();
        $achievements = Achievement::active()->get();

        $updated = [];
        $completed = [];

        foreach ($achievements as $achievement) {
            $userAchievement = $achievement->checkProgress($user);

            if ($userAchievement->wasRecentlyCreated || $userAchievement->wasChanged()) {
                $updated[] = [
                    'achievement' => $achievement->name,
                    'progress' => $userAchievement->progress_percentage,
                    'is_completed' => $userAchievement->is_completed,
                ];

                if ($userAchievement->is_completed && $userAchievement->wasChanged('is_completed')) {
                    $completed[] = [
                        'name' => $achievement->name,
                        'xp_reward' => $achievement->xp_reward,
                        'money_reward' => (float) $achievement->money_reward,
                    ];
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'updated_count' => count($updated),
                'completed_count' => count($completed),
                'updated' => $updated,
                'newly_completed' => $completed,
            ],
        ]);
    }

    /**
     * Get stats summary
     */
    public function stats(Request $request): JsonResponse
    {
        $totalUsers = User::count();
        $totalBadges = Badge::count();
        $totalAchievements = Achievement::count();

        $stats = [
            'users' => $totalUsers,
            'badges' => [
                'total' => $totalBadges,
                'by_rarity' => Badge::select('rarity', DB::raw('count(*) as count'))
                    ->groupBy('rarity')
                    ->pluck('count', 'rarity'),
            ],
            'achievements' => [
                'total' => $totalAchievements,
                'by_type' => Achievement::select('type', DB::raw('count(*) as count'))
                    ->groupBy('type')
                    ->pluck('count', 'type'),
            ],
            'average_level' => UserStats::avg('level'),
            'highest_level' => UserStats::max('level'),
            'total_xp_earned' => UserStats::sum('total_xp'),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Get order column for leaderboard
     */
    protected function getOrderColumn(string $category): string
    {
        return match ($category) {
            'rides' => 'completed_rides',
            'earnings' => 'total_earnings',
            'ratings' => 'average_rating',
            'xp' => 'total_xp',
            default => 'total_xp',
        };
    }

    /**
     * Get score value for leaderboard
     */
    protected function getScore(UserStats $stats, string $category): float
    {
        return match ($category) {
            'rides' => $stats->completed_rides,
            'earnings' => (float) $stats->total_earnings,
            'ratings' => (float) $stats->average_rating,
            'xp' => $stats->total_xp,
            default => $stats->total_xp,
        };
    }
}
