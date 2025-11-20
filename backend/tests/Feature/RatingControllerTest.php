<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use App\Models\DriverProfile;
use App\Models\Ride;
use App\Models\Rating;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class RatingControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $passenger;
    protected User $driver;
    protected DriverProfile $driverProfile;
    protected Ride $ride;
    protected string $passengerToken;
    protected string $driverToken;

    protected function setUp(): void
    {
        parent::setUp();

        $this->passenger = User::factory()->create(['user_type' => 'passenger']);
        $this->driver = User::factory()->create([
            'user_type' => 'driver',
            'average_rating' => null,
            'total_ratings' => 0,
        ]);

        $this->driverProfile = DriverProfile::factory()->create([
            'user_id' => $this->driver->id,
        ]);

        $this->ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'driver_id' => $this->driver->id,
            'status' => 'completed',
        ]);

        $this->passengerToken = $this->passenger->createToken('test-token')->plainTextToken;
        $this->driverToken = $this->driver->createToken('test-token')->plainTextToken;
    }

    /**
     * Test passenger can rate driver
     */
    public function test_passenger_can_rate_driver(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 5,
            'comment' => 'Excellent driver!',
            'tags' => ['polite', 'safe_driving'],
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Rating submitted successfully',
            ]);

        $this->assertDatabaseHas('ratings', [
            'ride_id' => $this->ride->id,
            'rater_id' => $this->passenger->id,
            'rated_id' => $this->driver->id,
            'stars' => 5,
            'comment' => 'Excellent driver!',
        ]);
    }

    /**
     * Test driver can rate passenger
     */
    public function test_driver_can_rate_passenger(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->driverToken,
        ])->postJson("/api/v1/driver/rides/{$this->ride->id}/rate", [
            'stars' => 4,
            'comment' => 'Good passenger',
            'tags' => ['polite', 'on_time'],
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Rating submitted successfully',
            ]);

        $this->assertDatabaseHas('ratings', [
            'ride_id' => $this->ride->id,
            'rater_id' => $this->driver->id,
            'rated_id' => $this->passenger->id,
            'stars' => 4,
        ]);
    }

    /**
     * Test cannot rate same ride twice
     */
    public function test_cannot_rate_same_ride_twice(): void
    {
        // Create first rating
        Rating::factory()->create([
            'ride_id' => $this->ride->id,
            'rater_id' => $this->passenger->id,
            'rated_id' => $this->driver->id,
        ]);

        // Try to rate again
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 5,
            'comment' => 'Second rating attempt',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'You have already rated this ride',
            ]);
    }

    /**
     * Test cannot rate uncompleted ride
     */
    public function test_cannot_rate_uncompleted_ride(): void
    {
        $incompleteRide = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'driver_id' => $this->driver->id,
            'status' => 'in_progress',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$incompleteRide->id}/rate", [
            'stars' => 5,
            'comment' => 'Too early',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Can only rate completed rides',
            ]);
    }

    /**
     * Test average rating updates correctly
     */
    public function test_average_rating_updates_correctly(): void
    {
        // Create multiple ratings for driver
        $otherPassenger1 = User::factory()->create(['user_type' => 'passenger']);
        $otherPassenger2 = User::factory()->create(['user_type' => 'passenger']);

        $ride1 = Ride::factory()->create([
            'passenger_id' => $otherPassenger1->id,
            'driver_id' => $this->driver->id,
            'status' => 'completed',
        ]);

        $ride2 = Ride::factory()->create([
            'passenger_id' => $otherPassenger2->id,
            'driver_id' => $this->driver->id,
            'status' => 'completed',
        ]);

        // Create ratings: 5, 4, 3 (average should be 4.0)
        Rating::factory()->create([
            'ride_id' => $ride1->id,
            'rater_id' => $otherPassenger1->id,
            'rated_id' => $this->driver->id,
            'stars' => 5,
        ]);

        Rating::factory()->create([
            'ride_id' => $ride2->id,
            'rater_id' => $otherPassenger2->id,
            'rated_id' => $this->driver->id,
            'stars' => 4,
        ]);

        $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 3,
        ]);

        // Check driver's average rating
        $this->driver->refresh();
        $this->assertEquals(4.0, $this->driver->average_rating);
        $this->assertEquals(3, $this->driver->total_ratings);
    }

    /**
     * Test passenger can view their given ratings
     */
    public function test_passenger_can_view_ratings(): void
    {
        Rating::factory()->count(3)->create([
            'rater_id' => $this->passenger->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->getJson('/api/v1/passenger/ratings');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'ride_id',
                        'stars',
                        'comment',
                        'created_at',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can view their given ratings
     */
    public function test_driver_can_view_ratings(): void
    {
        Rating::factory()->count(5)->create([
            'rater_id' => $this->driver->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->driverToken,
        ])->getJson('/api/v1/driver/ratings');

        $response->assertStatus(200)
            ->assertJsonCount(5, 'data');
    }

    /**
     * Test validation requires stars
     */
    public function test_validation_requires_stars(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'comment' => 'Great!',
            // Missing 'stars'
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['stars']);
    }

    /**
     * Test stars must be between 1 and 5
     */
    public function test_stars_must_be_valid_range(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 6, // Invalid
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['stars']);

        $response2 = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 0, // Invalid
        ]);

        $response2->assertStatus(422)
            ->assertJsonValidationErrors(['stars']);
    }

    /**
     * Test comment is optional
     */
    public function test_comment_is_optional(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 5,
            // No comment
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('ratings', [
            'ride_id' => $this->ride->id,
            'stars' => 5,
            'comment' => null,
        ]);
    }

    /**
     * Test tags are optional
     */
    public function test_tags_are_optional(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 4,
            // No tags
        ]);

        $response->assertStatus(201);
    }

    /**
     * Test passenger cannot rate their own ride as driver
     */
    public function test_passenger_cannot_rate_own_ride(): void
    {
        $rideAsDriver = Ride::factory()->create([
            'passenger_id' => User::factory()->create(),
            'driver_id' => $this->passenger->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/driver/rides/{$rideAsDriver->id}/rate", [
            'stars' => 5,
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test cannot rate ride from different user
     */
    public function test_cannot_rate_other_user_ride(): void
    {
        $otherPassenger = User::factory()->create();
        $otherRide = Ride::factory()->create([
            'passenger_id' => $otherPassenger->id,
            'driver_id' => $this->driver->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->postJson("/api/v1/passenger/rides/{$otherRide->id}/rate", [
            'stars' => 5,
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test ratings are paginated
     */
    public function test_ratings_are_paginated(): void
    {
        Rating::factory()->count(30)->create([
            'rater_id' => $this->passenger->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->passengerToken,
        ])->getJson('/api/v1/passenger/ratings?per_page=10');

        $response->assertStatus(200)
            ->assertJsonCount(10, 'data')
            ->assertJsonStructure([
                'meta' => [
                    'current_page',
                    'total',
                ],
            ]);
    }

    /**
     * Test unauthenticated user cannot rate rides
     */
    public function test_unauthenticated_user_cannot_rate(): void
    {
        $response = $this->postJson("/api/v1/passenger/rides/{$this->ride->id}/rate", [
            'stars' => 5,
        ]);

        $response->assertStatus(401);
    }
}
