<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Notification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class NotificationControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $user;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $this->token = $this->user->createToken('test-token')->plainTextToken;
    }

    /**
     * Test user can view notifications
     */
    public function test_user_can_view_notifications(): void
    {
        // Create notifications for the user
        Notification::factory()->count(5)->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/notifications');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'message',
                        'type',
                        'is_read',
                        'created_at',
                    ],
                ],
                'meta' => [
                    'current_page',
                    'total',
                    'unread_count',
                ],
            ]);
    }

    /**
     * Test user can view unread notifications only
     */
    public function test_user_can_filter_unread_notifications(): void
    {
        // Create read and unread notifications
        Notification::factory()->count(3)->create([
            'user_id' => $this->user->id,
            'is_read' => false,
        ]);

        Notification::factory()->count(2)->create([
            'user_id' => $this->user->id,
            'is_read' => true,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/notifications?unread=true');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    /**
     * Test user can mark notification as read
     */
    public function test_user_can_mark_notification_as_read(): void
    {
        $notification = Notification::factory()->create([
            'user_id' => $this->user->id,
            'is_read' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->patchJson("/api/v1/notifications/{$notification->id}/read");

        $response->assertStatus(200);

        $this->assertDatabaseHas('notifications', [
            'id' => $notification->id,
            'is_read' => true,
        ]);

        $notification->refresh();
        $this->assertNotNull($notification->read_at);
    }

    /**
     * Test user can mark all notifications as read
     */
    public function test_user_can_mark_all_notifications_as_read(): void
    {
        Notification::factory()->count(5)->create([
            'user_id' => $this->user->id,
            'is_read' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/notifications/read-all');

        $response->assertStatus(200);

        $this->assertEquals(0, Notification::where('user_id', $this->user->id)
            ->where('is_read', false)
            ->count());
    }

    /**
     * Test user can delete notification
     */
    public function test_user_can_delete_notification(): void
    {
        $notification = Notification::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/notifications/{$notification->id}");

        $response->assertStatus(200);

        $this->assertDatabaseMissing('notifications', [
            'id' => $notification->id,
        ]);
    }

    /**
     * Test user cannot view other user's notifications
     */
    public function test_user_cannot_view_other_user_notifications(): void
    {
        $otherUser = User::factory()->create();
        $notification = Notification::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->patchJson("/api/v1/notifications/{$notification->id}/read");

        $response->assertStatus(403);
    }

    /**
     * Test user can get unread count
     */
    public function test_user_can_get_unread_count(): void
    {
        Notification::factory()->count(7)->create([
            'user_id' => $this->user->id,
            'is_read' => false,
        ]);

        Notification::factory()->count(3)->create([
            'user_id' => $this->user->id,
            'is_read' => true,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/notifications/unread-count');

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'unread_count' => 7,
                ],
            ]);
    }

    /**
     * Test user can update device token for push notifications
     */
    public function test_user_can_update_device_token(): void
    {
        $deviceToken = 'fcm_token_' . $this->faker->uuid;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/notifications/device-token', [
            'device_token' => $deviceToken,
            'platform' => 'android',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('users', [
            'id' => $this->user->id,
            'device_token' => $deviceToken,
        ]);
    }

    /**
     * Test unauthenticated user cannot access notifications
     */
    public function test_unauthenticated_user_cannot_access_notifications(): void
    {
        $response = $this->getJson('/api/v1/notifications');

        $response->assertStatus(401);
    }

    /**
     * Test notifications are paginated
     */
    public function test_notifications_are_paginated(): void
    {
        Notification::factory()->count(30)->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/notifications?per_page=10');

        $response->assertStatus(200)
            ->assertJsonCount(10, 'data')
            ->assertJsonStructure([
                'meta' => [
                    'current_page',
                    'last_page',
                    'per_page',
                    'total',
                ],
            ]);
    }
}
