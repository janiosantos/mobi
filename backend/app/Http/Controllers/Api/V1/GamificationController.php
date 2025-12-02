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
            'message' => 'Gamification profile retrieved successfully',
            'data' => [
                'level' => $stats->level,
                'current_xp' => $stats->current_xp,
                'total_xp' => $stats->total_xp,
                'current_streak' => $stats->current_streak,
                'longest_streak' => $stats->longest_streak,
                'stats' => [
                    'total_rides' => $stats->total_rides,
                    'completed_rides' => $stats->completed_rides,
                    'average_rating' => (float) $stats->average_rating,
                    'total_earnings' => (float) $stats->total_earnings,
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

        // Get user's earned badges
        $badges = $user->badges()
            ->withPivot('earned_at')
            ->get()
            ->map(function ($badge) {
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
            });

        return response()->json([
            'success' => true,
            'message' => 'Badges retrieved successfully',
            'data' => $badges->values(),
        ]);
    }

    /**
     * Get all achievements
     */
    public function achievements(Request $request): JsonResponse
    {
        $user = $request->user();

        $achievements = Achievement::active()
            ->get()
            ->map(function ($achievement) use ($user) {
                $userAchievement = $user->achievements()
                    ->where('achievement_id', $achievement->id)
                    ->first();

                return [
                    'id' => $achievement->id,
                    'name' => $achievement->name,
                    'description' => $achievement->description,
                    'icon' => $achievement->icon ?? '🏆',
                    'type' => $achievement->type,
                    'target_value' => $achievement->target_value,
                    'xp_reward' => $achievement->xp_reward,
                    'current_progress' => $userAchievement ? $userAchievement->current_progress : 0,
                    'completed_at' => $userAchievement ? $userAchievement->completed_at : null,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Achievements retrieved successfully',
            'data' => $achievements->values(),
        ]);
    }

    /**
     * Get leaderboard
     */
    public function leaderboard(Request $request): JsonResponse
    {
        $period = $request->input('period', 'all_time'); // weekly, monthly, all_time
        $limit = min($request->input('limit', 50), 100);
        $currentUser = $request->user();

        // For now, we'll use total_xp for ranking regardless of period
        // TODO: Implement period-specific filtering (weekly/monthly)
        $query = UserStats::query()
            ->with('user:id,name,email,photo_url')
            ->orderByDesc('total_xp')
            ->limit($limit);

        $leaderboard = $query->get()->map(function ($stats, $index) use ($currentUser) {
            return [
                'rank' => $index + 1,
                'user' => [
                    'id' => $stats->user->id,
                    'name' => $stats->user->name,
                    'photo_url' => $stats->user->photo_url,
                ],
                'score' => $stats->total_xp,
                'is_current_user' => $stats->user->id === $currentUser->id,
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Leaderboard retrieved successfully',
            'data' => $leaderboard->values(),
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

}
