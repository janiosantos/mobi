<?php

namespace Tests\Feature;

use App\Models\EmergencyContact;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EmergencyContactControllerTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    /** @test */
    public function it_can_list_emergency_contacts_for_authenticated_user(): void
    {
        // Create contacts for authenticated user
        EmergencyContact::factory()->count(3)->create([
            'user_id' => $this->user->id,
        ]);

        // Create contacts for another user (should not be returned)
        EmergencyContact::factory()->count(2)->create([
            'user_id' => User::factory()->create()->id,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/emergency-contacts');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'phone',
                        'relationship',
                        'is_primary',
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Emergency contacts retrieved successfully',
            ])
            ->assertJsonCount(3, 'data');
    }

    /** @test */
    public function it_orders_contacts_with_primary_first(): void
    {
        $contact1 = EmergencyContact::factory()->create([
            'user_id' => $this->user->id,
            'is_primary' => false,
            'created_at' => now()->subDays(2),
        ]);

        $contact2 = EmergencyContact::factory()->create([
            'user_id' => $this->user->id,
            'is_primary' => true,
            'created_at' => now()->subDay(),
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/emergency-contacts');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals($contact2->id, $data[0]['id'], 'Primary contact should be first');
    }

    /** @test */
    public function it_requires_authentication_to_list_contacts(): void
    {
        $response = $this->getJson('/api/v1/emergency-contacts');

        $response->assertStatus(401);
    }

    /** @test */
    public function it_can_create_an_emergency_contact(): void
    {
        $contactData = [
            'name' => 'João Silva',
            'phone' => '11987654321',
            'relationship' => 'Pai',
            'is_primary' => false,
        ];

        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/emergency-contacts', $contactData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'name',
                    'phone',
                    'relationship',
                    'is_primary',
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'Emergency contact created successfully',
                'data' => [
                    'name' => 'João Silva',
                    'phone' => '11987654321',
                    'relationship' => 'Pai',
                ],
            ]);

        $this->assertDatabaseHas('emergency_contacts', [
            'user_id' => $this->user->id,
            'name' => 'João Silva',
            'phone' => '11987654321',
        ]);
    }

    /** @test */
    public function it_validates_required_fields_when_creating(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/emergency-contacts', []);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Validation failed',
            ])
            ->assertJsonValidationErrors(['name', 'phone']);
    }

    /** @test */
    public function it_validates_name_max_length(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/emergency-contacts', [
                'name' => str_repeat('a', 101),
                'phone' => '11987654321',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name']);
    }

    /** @test */
    public function it_validates_phone_max_length(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/emergency-contacts', [
                'name' => 'João Silva',
                'phone' => str_repeat('1', 21),
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['phone']);
    }

    /** @test */
    public function it_can_create_contact_as_primary(): void
    {
        $existingPrimary = EmergencyContact::factory()->create([
            'user_id' => $this->user->id,
            'is_primary' => true,
        ]);

        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/emergency-contacts', [
                'name' => 'Maria Silva',
                'phone' => '11987654321',
                'is_primary' => true,
            ]);

        $response->assertStatus(201);

        // New contact should be primary
        $this->assertDatabaseHas('emergency_contacts', [
            'name' => 'Maria Silva',
            'is_primary' => true,
        ]);

        // Old primary should no longer be primary
        $this->assertDatabaseHas('emergency_contacts', [
            'id' => $existingPrimary->id,
            'is_primary' => false,
        ]);
    }

    /** @test */
    public function it_can_update_an_emergency_contact(): void
    {
        $contact = EmergencyContact::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Old Name',
            'phone' => '11999999999',
        ]);

        $response = $this->actingAs($this->user)
            ->putJson("/api/v1/emergency-contacts/{$contact->id}", [
                'name' => 'New Name',
                'phone' => '11988888888',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Emergency contact updated successfully',
                'data' => [
                    'id' => $contact->id,
                    'name' => 'New Name',
                    'phone' => '11988888888',
                ],
            ]);

        $this->assertDatabaseHas('emergency_contacts', [
            'id' => $contact->id,
            'name' => 'New Name',
            'phone' => '11988888888',
        ]);
    }

    /** @test */
    public function it_can_update_contact_to_primary(): void
    {
        $existingPrimary = EmergencyContact::factory()->create([
            'user_id' => $this->user->id,
            'is_primary' => true,
        ]);

        $contact = EmergencyContact::factory()->create([
            'user_id' => $this->user->id,
            'is_primary' => false,
        ]);

        $response = $this->actingAs($this->user)
            ->putJson("/api/v1/emergency-contacts/{$contact->id}", [
                'is_primary' => true,
            ]);

        $response->assertStatus(200);

        // Contact should now be primary
        $this->assertDatabaseHas('emergency_contacts', [
            'id' => $contact->id,
            'is_primary' => true,
        ]);

        // Old primary should no longer be primary
        $this->assertDatabaseHas('emergency_contacts', [
            'id' => $existingPrimary->id,
            'is_primary' => false,
        ]);
    }

    /** @test */
    public function it_prevents_updating_another_users_contact(): void
    {
        $otherUser = User::factory()->create();
        $contact = EmergencyContact::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->actingAs($this->user)
            ->putJson("/api/v1/emergency-contacts/{$contact->id}", [
                'name' => 'New Name',
            ]);

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized',
            ]);
    }

    /** @test */
    public function it_can_delete_an_emergency_contact(): void
    {
        $contact = EmergencyContact::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->actingAs($this->user)
            ->deleteJson("/api/v1/emergency-contacts/{$contact->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Emergency contact deleted successfully',
            ]);

        $this->assertDatabaseMissing('emergency_contacts', [
            'id' => $contact->id,
        ]);
    }

    /** @test */
    public function it_prevents_deleting_another_users_contact(): void
    {
        $otherUser = User::factory()->create();
        $contact = EmergencyContact::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->actingAs($this->user)
            ->deleteJson("/api/v1/emergency-contacts/{$contact->id}");

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized',
            ]);

        $this->assertDatabaseHas('emergency_contacts', [
            'id' => $contact->id,
        ]);
    }

    /** @test */
    public function it_allows_optional_relationship_field(): void
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/v1/emergency-contacts', [
                'name' => 'João Silva',
                'phone' => '11987654321',
                // relationship is optional
            ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('emergency_contacts', [
            'user_id' => $this->user->id,
            'name' => 'João Silva',
            'relationship' => null,
        ]);
    }
}
