<?php

namespace Tests\Feature;

use App\Models\SavedPlace;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SavedPlaceControllerTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    /** @test */
    public function it_can_list_saved_places_for_authenticated_user(): void
    {
        // Create places for authenticated user
        SavedPlace::factory()->count(3)->create([
            'user_id' => $this->user->id,
        ]);

        // Create places for another user (should not be returned)
        SavedPlace::factory()->count(2)->create([
            'user_id' => User::factory()->create()->id,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/saved-places');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'type',
                        'label',
                        'address',
                        'latitude',
                        'longitude',
                        'is_default',
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Saved places retrieved successfully',
            ])
            ->assertJsonCount(3, 'data');
    }

    /** @test */
    public function it_requires_authentication_to_list_saved_places(): void
    {
        $response = $this->getJson('/api/v1/saved-places');

        $response->assertStatus(401);
    }

    /** @test */
    public function it_can_create_a_saved_place(): void
    {
        $placeData = [
            'type' => 'home',
            'label' => 'Minha Casa',
            'address' => 'Rua Exemplo, 123',
            'latitude' => -23.5505,
            'longitude' => -46.6333,
            'is_default' => false,
        ];

        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/saved-places', $placeData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'type',
                    'label',
                    'address',
                    'latitude',
                    'longitude',
                    'is_default',
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Saved place created successfully',
                'data' => [
                    'type' => 'home',
                    'label' => 'Minha Casa',
                    'address' => 'Rua Exemplo, 123',
                ],
            ]);

        $this->assertDatabaseHas('saved_places', [
            'user_id' => $this->user->id,
            'type' => 'home',
            'label' => 'Minha Casa',
        ]);
    }

    /** @test */
    public function it_validates_required_fields_when_creating(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/saved-places', []);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Validation failed',
            ])
            ->assertJsonValidationErrors(['type', 'label', 'address', 'latitude', 'longitude']);
    }

    /** @test */
    public function it_validates_type_is_valid(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/saved-places', [
                'type' => 'invalid_type',
                'label' => 'Test',
                'address' => 'Test Address',
                'latitude' => -23.5505,
                'longitude' => -46.6333,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /** @test */
    public function it_validates_latitude_is_between_minus_90_and_90(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/saved-places', [
                'type' => 'home',
                'label' => 'Test',
                'address' => 'Test Address',
                'latitude' => 100,
                'longitude' => -46.6333,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['latitude']);
    }

    /** @test */
    public function it_validates_longitude_is_between_minus_180_and_180(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/saved-places', [
                'type' => 'home',
                'label' => 'Test',
                'address' => 'Test Address',
                'latitude' => -23.5505,
                'longitude' => 200,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['longitude']);
    }

    /** @test */
    public function it_can_show_a_saved_place(): void
    {
        $place = SavedPlace::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson("/api/v1/saved-places/{$place->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Saved place retrieved successfully',
                'data' => [
                    'id' => $place->id,
                    'type' => $place->type,
                    'label' => $place->label,
                ],
            ]);
    }

    /** @test */
    public function it_prevents_viewing_another_users_saved_place(): void
    {
        $otherUser = User::factory()->create();
        $place = SavedPlace::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson("/api/v1/saved-places/{$place->id}");

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized',
            ]);
    }

    /** @test */
    public function it_can_update_a_saved_place(): void
    {
        $place = SavedPlace::factory()->create([
            'user_id' => $this->user->id,
            'label' => 'Old Label',
        ]);

        $response = $this->actingAs($this->user)
            ->putJson("/api/v1/saved-places/{$place->id}", [
                'label' => 'New Label',
                'address' => 'New Address',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Saved place updated successfully',
                'data' => [
                    'id' => $place->id,
                    'label' => 'New Label',
                    'address' => 'New Address',
                ],
            ]);

        $this->assertDatabaseHas('saved_places', [
            'id' => $place->id,
            'label' => 'New Label',
            'address' => 'New Address',
        ]);
    }

    /** @test */
    public function it_prevents_updating_another_users_saved_place(): void
    {
        $otherUser = User::factory()->create();
        $place = SavedPlace::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->actingAs($this->user)
            ->putJson("/api/v1/saved-places/{$place->id}", [
                'label' => 'New Label',
            ]);

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized',
            ]);
    }

    /** @test */
    public function it_can_delete_a_saved_place(): void
    {
        $place = SavedPlace::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->actingAs($this->user)
            ->deleteJson("/api/v1/saved-places/{$place->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Saved place deleted successfully',
            ]);

        $this->assertSoftDeleted('saved_places', [
            'id' => $place->id,
        ]);
    }

    /** @test */
    public function it_prevents_deleting_another_users_saved_place(): void
    {
        $otherUser = User::factory()->create();
        $place = SavedPlace::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->actingAs($this->user)
            ->deleteJson("/api/v1/saved-places/{$place->id}");

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized',
            ]);

        $this->assertDatabaseHas('saved_places', [
            'id' => $place->id,
        ]);
    }

    /** @test */
    public function it_can_set_a_place_as_default(): void
    {
        $place1 = SavedPlace::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => true,
        ]);

        $place2 = SavedPlace::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => false,
        ]);

        $response = $this->actingAs($this->user)
            ->postJson("/api/v1/saved-places/{$place2->id}/set-default");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Default place updated successfully',
            ]);

        // Verify place2 is now default
        $this->assertDatabaseHas('saved_places', [
            'id' => $place2->id,
            'is_default' => true,
        ]);

        // Verify place1 is no longer default
        $this->assertDatabaseHas('saved_places', [
            'id' => $place1->id,
            'is_default' => false,
        ]);
    }

    /** @test */
    public function it_can_get_places_by_type(): void
    {
        SavedPlace::factory()->count(2)->create([
            'user_id' => $this->user->id,
            'type' => 'home',
        ]);

        SavedPlace::factory()->count(3)->create([
            'user_id' => $this->user->id,
            'type' => 'work',
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/saved-places/type/home');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Saved places retrieved successfully',
            ])
            ->assertJsonCount(2, 'data');
    }

    /** @test */
    public function it_validates_type_parameter_in_by_type_endpoint(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/saved-places/type/invalid');

        $response->assertStatus(400)
            ->assertJson([
                'success' => false,
                'message' => 'Invalid type',
            ]);
    }
}
