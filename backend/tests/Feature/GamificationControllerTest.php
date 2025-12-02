<?php

namespace Tests\Feature;

use App\Models\Achievement;
use App\Models\Badge;
use App\Models\User;
use App\Models\UserAchievement;
use App\Models\UserStats;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GamificationControllerTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    /** @test */
    public function it_can_get_user_gamification_profile(): void
    {
        // Create user stats
        UserStats::factory()->create([
            'user_id' => $this->user->id,
            'level' => 5,
            'current_xp' => 250,
            'total_xp' => 1250,
            'current_streak' => 7,
            'longest_streak' => 15,
            'total_rides' => 42,
            'completed_rides' => 40,
            'average_rating' => 4.8,
            'total_earnings' => 1500.50,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/profile');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'level',
                    'current_xp',
                    'total_xp',
                    'current_streak',
                    'longest_streak',
                    'stats' => [
                        'total_rides',
                        'completed_rides',
                        'average_rating',
                        'total_earnings',
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Gamification profile retrieved successfully',
                'data' => [
                    'level' => 5,
                    'current_xp' => 250,
                    'total_xp' => 1250,
                    'current_streak' => 7,
                    'longest_streak' => 15,
                ],
            ]);
    }

    /** @test */
    public function it_creates_user_stats_if_not_exists(): void
    {
        // Ensure no stats exist
        $this->assertDatabaseMissing('user_stats', [
            'user_id' => $this->user->id,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/profile');

        $response->assertStatus(200);

        // Stats should be created
        $this->assertDatabaseHas('user_stats', [
            'user_id' => $this->user->id,
        ]);
    }

    /** @test */
    public function it_requires_authentication_to_get_profile(): void
    {
        $response = $this->getJson('/api/v1/gamification/profile');

        $response->assertStatus(401);
    }

    /** @test */
    public function it_can_get_user_badges(): void
    {
        // Create badges
        $badge1 = Badge::factory()->create([
            'name' => 'Iniciante',
            'icon' => '🚗',
            'rarity' => 'common',
        ]);

        $badge2 = Badge::factory()->create([
            'name' => 'Veterano',
            'icon' => '🏆',
            'rarity' => 'rare',
        ]);

        // Attach badges to user
        $this->user->badges()->attach($badge1->id, [
            'earned_at' => now()->subDays(5),
        ]);

        $this->user->badges()->attach($badge2->id, [
            'earned_at' => now()->subDay(),
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/badges');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'description',
                        'icon',
                        'category',
                        'rarity',
                        'points',
                        'earned_at',
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Badges retrieved successfully',
            ])
            ->assertJsonCount(2, 'data');
    }

    /** @test */
    public function it_returns_empty_array_when_user_has_no_badges(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/badges');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [],
            ]);
    }

    /** @test */
    public function it_can_get_achievements_list(): void
    {
        // Create achievements
        $achievement1 = Achievement::factory()->create([
            'name' => 'Primeira Corrida',
            'description' => 'Complete 1 corrida',
            'type' => 'progressive',
            'target_value' => 1,
            'xp_reward' => 50,
            'is_active' => true,
        ]);

        $achievement2 = Achievement::factory()->create([
            'name' => 'Centenário',
            'description' => 'Complete 100 corridas',
            'type' => 'progressive',
            'target_value' => 100,
            'xp_reward' => 500,
            'is_active' => true,
        ]);

        // User has completed achievement1
        UserAchievement::factory()->create([
            'user_id' => $this->user->id,
            'achievement_id' => $achievement1->id,
            'current_progress' => 1,
            'completed_at' => now(),
        ]);

        // User is working on achievement2
        UserAchievement::factory()->create([
            'user_id' => $this->user->id,
            'achievement_id' => $achievement2->id,
            'current_progress' => 50,
            'completed_at' => null,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/achievements');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'description',
                        'icon',
                        'type',
                        'target_value',
                        'xp_reward',
                        'current_progress',
                        'completed_at',
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Achievements retrieved successfully',
            ])
            ->assertJsonCount(2, 'data');

        // Verify first achievement is completed
        $data = $response->json('data');
        $completedAchievement = collect($data)->firstWhere('id', $achievement1->id);
        $this->assertEquals(1, $completedAchievement['current_progress']);
        $this->assertNotNull($completedAchievement['completed_at']);

        // Verify second achievement is not completed
        $inProgressAchievement = collect($data)->firstWhere('id', $achievement2->id);
        $this->assertEquals(50, $inProgressAchievement['current_progress']);
        $this->assertNull($inProgressAchievement['completed_at']);
    }

    /** @test */
    public function it_shows_zero_progress_for_achievements_user_hasnt_started(): void
    {
        $achievement = Achievement::factory()->create([
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/achievements');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals(0, $data[0]['current_progress']);
        $this->assertNull($data[0]['completed_at']);
    }

    /** @test */
    public function it_can_get_leaderboard(): void
    {
        // Create multiple users with stats
        $user1 = User::factory()->create(['name' => 'Top Player']);
        UserStats::factory()->create([
            'user_id' => $user1->id,
            'total_xp' => 5000,
        ]);

        $user2 = User::factory()->create(['name' => 'Second Player']);
        UserStats::factory()->create([
            'user_id' => $user2->id,
            'total_xp' => 3000,
        ]);

        // Current user
        UserStats::factory()->create([
            'user_id' => $this->user->id,
            'total_xp' => 1000,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/leaderboard');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'rank',
                        'user' => [
                            'id',
                            'name',
                            'photo_url',
                        ],
                        'score',
                        'is_current_user',
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Leaderboard retrieved successfully',
            ]);

        $data = $response->json('data');

        // Verify ranking order
        $this->assertEquals(1, $data[0]['rank']);
        $this->assertEquals('Top Player', $data[0]['user']['name']);
        $this->assertEquals(5000, $data[0]['score']);
        $this->assertFalse($data[0]['is_current_user']);

        $this->assertEquals(2, $data[1]['rank']);
        $this->assertEquals('Second Player', $data[1]['user']['name']);

        // Find current user
        $currentUserEntry = collect($data)->firstWhere('is_current_user', true);
        $this->assertNotNull($currentUserEntry);
        $this->assertEquals(3, $currentUserEntry['rank']);
        $this->assertEquals(1000, $currentUserEntry['score']);
    }

    /** @test */
    public function it_can_filter_leaderboard_by_period(): void
    {
        UserStats::factory()->create([
            'user_id' => $this->user->id,
            'total_xp' => 1000,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/leaderboard?period=weekly');

        $response->assertStatus(200);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/leaderboard?period=monthly');

        $response->assertStatus(200);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/leaderboard?period=all_time');

        $response->assertStatus(200);
    }

    /** @test */
    public function it_limits_leaderboard_results(): void
    {
        // Create 60 users
        for ($i = 0; $i < 60; $i++) {
            $user = User::factory()->create();
            UserStats::factory()->create([
                'user_id' => $user->id,
                'total_xp' => rand(100, 10000),
            ]);
        }

        // Default limit is 50
        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/leaderboard');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertLessThanOrEqual(50, count($data));

        // Custom limit
        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/leaderboard?limit=10');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertLessThanOrEqual(10, count($data));

        // Max limit is 100
        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/leaderboard?limit=200');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertLessThanOrEqual(100, count($data));
    }

    /** @test */
    public function it_can_check_achievements_progress(): void
    {
        Achievement::factory()->create([
            'is_active' => true,
            'target_value' => 10,
        ]);

        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/gamification/achievements/check');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'updated_count',
                    'completed_count',
                    'updated',
                    'newly_completed',
                ],
            ])
            ->assertJson([
                'success' => true,
            ]);
    }

    /** @test */
    public function it_can_get_gamification_stats(): void
    {
        // Create some data
        Badge::factory()->count(5)->create();
        Achievement::factory()->count(3)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/gamification/stats');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'users',
                    'badges' => [
                        'total',
                        'by_rarity',
                    ],
                    'achievements' => [
                        'total',
                        'by_type',
                    ],
                    'average_level',
                    'highest_level',
                    'total_xp_earned',
                ],
            ])
            ->assertJson([
                'success' => true,
            ]);
    }
}
