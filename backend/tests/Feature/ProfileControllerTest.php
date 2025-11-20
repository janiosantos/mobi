<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProfileControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $user;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create([
            'email' => 'test@example.com',
            'phone' => '11987654321',
        ]);
        $this->token = $this->user->createToken('test-token')->plainTextToken;
    }

    /**
     * Test user can view their profile
     */
    public function test_user_can_view_profile(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/profile');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'id',
                    'name',
                    'email',
                    'phone',
                    'cpf',
                    'birth_date',
                    'gender',
                    'profile_photo_url',
                    'created_at',
                ],
            ])
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $this->user->id,
                    'email' => $this->user->email,
                ],
            ]);
    }

    /**
     * Test user can update their profile
     */
    public function test_user_can_update_profile(): void
    {
        $newData = [
            'name' => 'Updated Name',
            'phone' => '11999999999',
            'birth_date' => '1990-01-01',
            'gender' => 'male',
        ];

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/profile', $newData);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'name' => 'Updated Name',
                    'phone' => '11999999999',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $this->user->id,
            'name' => 'Updated Name',
            'phone' => '11999999999',
        ]);
    }

    /**
     * Test email must be unique when updating
     */
    public function test_email_must_be_unique(): void
    {
        $otherUser = User::factory()->create([
            'email' => 'other@example.com',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/profile', [
            'name' => $this->user->name,
            'email' => 'other@example.com',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test phone must be unique when updating
     */
    public function test_phone_must_be_unique(): void
    {
        $otherUser = User::factory()->create([
            'phone' => '11988888888',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/profile', [
            'name' => $this->user->name,
            'phone' => '11988888888',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['phone']);
    }

    /**
     * Test user can keep their own email when updating
     */
    public function test_user_can_keep_own_email(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/profile', [
            'name' => 'Updated Name',
            'email' => $this->user->email, // Same email
        ]);

        $response->assertStatus(200);
    }

    /**
     * Test user can upload profile photo
     */
    public function test_user_can_upload_profile_photo(): void
    {
        Storage::fake('public');

        $file = UploadedFile::fake()->image('profile.jpg', 500, 500);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/profile/photo', [
            'photo' => $file,
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'profile_photo_url',
                ],
            ]);

        $this->user->refresh();
        $this->assertNotNull($this->user->profile_photo_url);
    }

    /**
     * Test user can delete profile photo
     */
    public function test_user_can_delete_profile_photo(): void
    {
        Storage::fake('public');

        // First upload a photo
        $file = UploadedFile::fake()->image('profile.jpg');
        $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/profile/photo', [
            'photo' => $file,
        ]);

        $this->user->refresh();
        $this->assertNotNull($this->user->profile_photo_url);

        // Now delete it
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson('/api/v1/profile/photo');

        $response->assertStatus(200);

        $this->user->refresh();
        $this->assertNull($this->user->profile_photo_url);
    }

    /**
     * Test photo must be valid image
     */
    public function test_photo_must_be_valid_image(): void
    {
        Storage::fake('public');

        $file = UploadedFile::fake()->create('document.pdf', 1000);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/profile/photo', [
            'photo' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['photo']);
    }

    /**
     * Test photo cannot exceed max size
     */
    public function test_photo_cannot_exceed_max_size(): void
    {
        Storage::fake('public');

        // Create a 6MB file (max is usually 5MB)
        $file = UploadedFile::fake()->image('large.jpg')->size(6144);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/profile/photo', [
            'photo' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['photo']);
    }

    /**
     * Test unauthenticated user cannot access profile
     */
    public function test_unauthenticated_user_cannot_access_profile(): void
    {
        $response = $this->getJson('/api/v1/profile');

        $response->assertStatus(401);
    }

    /**
     * Test user cannot update with invalid data
     */
    public function test_user_cannot_update_with_invalid_data(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/profile', [
            'name' => '', // Empty name
            'email' => 'invalid-email', // Invalid email format
            'phone' => '123', // Too short
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name', 'email', 'phone']);
    }

    /**
     * Test user can update only some fields
     */
    public function test_user_can_update_partial_profile(): void
    {
        $originalEmail = $this->user->email;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/profile', [
            'name' => 'New Name Only',
        ]);

        $response->assertStatus(200);

        $this->user->refresh();
        $this->assertEquals('New Name Only', $this->user->name);
        $this->assertEquals($originalEmail, $this->user->email); // Email unchanged
    }
}
