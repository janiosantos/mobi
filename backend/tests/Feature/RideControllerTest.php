<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Ride;
use App\Models\VehicleCategory;
use App\Models\Rating;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class RideControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $passenger;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->passenger = User::factory()->create([
            'user_type' => 'passenger',
        ]);
        $this->token = $this->passenger->createToken('test-token')->plainTextToken;
    }

    /**
     * Test passenger can estimate ride price
     */
    public function test_passenger_can_estimate_ride_price(): void
    {
        $category = VehicleCategory::factory()->create([
            'name' => 'Standard',
            'base_price' => 5.00,
            'price_per_km' => 2.50,
            'price_per_minute' => 0.50,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/rides/estimate', [
            'pickup_latitude' => -23.5505,
            'pickup_longitude' => -46.6333,
            'dropoff_latitude' => -23.5629,
            'dropoff_longitude' => -46.6544,
            'vehicle_category_id' => $category->id,
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'estimated_price',
                    'estimated_distance_meters',
                    'estimated_duration_seconds',
                    'surge_multiplier',
                ],
            ]);
    }

    /**
     * Test passenger can request a ride
     */
    public function test_passenger_can_request_ride(): void
    {
        $category = VehicleCategory::factory()->create();

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/rides', [
            'pickup_latitude' => -23.5505,
            'pickup_longitude' => -46.6333,
            'pickup_address' => 'Av. Paulista, 1000',
            'dropoff_latitude' => -23.5629,
            'dropoff_longitude' => -46.6544,
            'dropoff_address' => 'Rua Augusta, 500',
            'vehicle_category_id' => $category->id,
            'payment_method' => 'pix',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'ride_number',
                    'status',
                    'pickup_address',
                    'dropoff_address',
                    'estimated_price',
                ],
            ]);

        $this->assertDatabaseHas('rides', [
            'passenger_id' => $this->passenger->id,
            'status' => 'searching',
        ]);
    }

    /**
     * Test ride request validation
     */
    public function test_ride_request_fails_with_invalid_data(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/rides', [
            'pickup_latitude' => 'invalid',
            'pickup_longitude' => -46.6333,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['pickup_latitude']);
    }

    /**
     * Test passenger can view their rides
     */
    public function test_passenger_can_view_their_rides(): void
    {
        Ride::factory()->count(3)->create([
            'passenger_id' => $this->passenger->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/rides');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'ride_number',
                        'status',
                        'pickup_address',
                        'dropoff_address',
                    ],
                ],
                'meta' => [
                    'current_page',
                    'total',
                ],
            ]);
    }

    /**
     * Test passenger can view specific ride
     */
    public function test_passenger_can_view_specific_ride(): void
    {
        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson("/api/v1/rides/{$ride->id}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'ride_number',
                    'status',
                    'passenger',
                    'category',
                ],
            ]);
    }

    /**
     * Test passenger cannot view other passenger's ride
     */
    public function test_passenger_cannot_view_other_passenger_ride(): void
    {
        $otherPassenger = User::factory()->create(['user_type' => 'passenger']);
        $ride = Ride::factory()->create([
            'passenger_id' => $otherPassenger->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson("/api/v1/rides/{$ride->id}");

        $response->assertStatus(403);
    }

    /**
     * Test passenger can cancel ride before acceptance
     */
    public function test_passenger_can_cancel_ride_before_acceptance(): void
    {
        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'status' => 'searching',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/cancel", [
            'reason' => 'Changed my mind',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('rides', [
            'id' => $ride->id,
            'status' => 'cancelled',
            'cancelled_by' => 'passenger',
            'cancellation_reason' => 'Changed my mind',
        ]);
    }

    /**
     * Test passenger cannot cancel completed ride
     */
    public function test_passenger_cannot_cancel_completed_ride(): void
    {
        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/cancel", [
            'reason' => 'Changed my mind',
        ]);

        $response->assertStatus(422);
    }

    /**
     * Test passenger can rate completed ride
     */
    public function test_passenger_can_rate_completed_ride(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);

        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'driver_id' => $driver->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/rate", [
            'rating' => 5,
            'comment' => 'Excellent driver!',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('ratings', [
            'ride_id' => $ride->id,
            'rater_id' => $this->passenger->id,
            'rated_id' => $driver->id,
            'rating' => 5,
            'comment' => 'Excellent driver!',
        ]);
    }

    /**
     * Test passenger cannot rate ride twice
     */
    public function test_passenger_cannot_rate_ride_twice(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);

        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'driver_id' => $driver->id,
            'status' => 'completed',
        ]);

        // Create existing rating
        Rating::factory()->create([
            'ride_id' => $ride->id,
            'rater_id' => $this->passenger->id,
            'rated_id' => $driver->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/rate", [
            'rating' => 4,
            'comment' => 'Good',
        ]);

        $response->assertStatus(422);
    }

    /**
     * Test rating validation
     */
    public function test_rating_fails_with_invalid_data(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);

        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'driver_id' => $driver->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/rate", [
            'rating' => 6, // Invalid: should be 1-5
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['rating']);
    }

    /**
     * Test unauthenticated user cannot access rides
     */
    public function test_unauthenticated_user_cannot_access_rides(): void
    {
        $response = $this->getJson('/api/v1/rides');

        $response->assertStatus(401);
    }
}
