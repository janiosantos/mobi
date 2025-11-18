<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Ride;
use App\Models\Vehicle;
use App\Models\DriverProfile;
use App\Models\VehicleCategory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class DriverRideControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $driver;
    protected DriverProfile $driverProfile;
    protected Vehicle $vehicle;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->driver = User::factory()->create([
            'user_type' => 'driver',
        ]);

        $this->driverProfile = DriverProfile::factory()->create([
            'user_id' => $this->driver->id,
            'status' => 'available',
            'is_online' => true,
        ]);

        $category = VehicleCategory::factory()->create();

        $this->vehicle = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
            'category_id' => $category->id,
            'is_active' => true,
        ]);

        $this->token = $this->driver->createToken('test-token')->plainTextToken;
    }

    /**
     * Test driver can view available rides
     */
    public function test_driver_can_view_available_rides(): void
    {
        // Create rides in searching status
        Ride::factory()->count(3)->create([
            'status' => 'searching',
            'pickup_latitude' => $this->driverProfile->current_latitude,
            'pickup_longitude' => $this->driverProfile->current_longitude,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/rides/available');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'ride_number',
                        'pickup_address',
                        'dropoff_address',
                        'estimated_price',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can accept ride
     */
    public function test_driver_can_accept_ride(): void
    {
        $ride = Ride::factory()->create([
            'status' => 'searching',
            'vehicle_category_id' => $this->vehicle->category_id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/accept");

        $response->assertStatus(200);

        $this->assertDatabaseHas('rides', [
            'id' => $ride->id,
            'status' => 'accepted',
            'driver_id' => $this->driver->id,
            'vehicle_id' => $this->vehicle->id,
        ]);

        // Driver should no longer be available
        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'status' => 'on_ride',
        ]);
    }

    /**
     * Test driver cannot accept already accepted ride
     */
    public function test_driver_cannot_accept_already_accepted_ride(): void
    {
        $otherDriver = User::factory()->create(['user_type' => 'driver']);

        $ride = Ride::factory()->create([
            'status' => 'accepted',
            'driver_id' => $otherDriver->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/accept");

        $response->assertStatus(422);
    }

    /**
     * Test driver can mark arrival
     */
    public function test_driver_can_mark_arrival(): void
    {
        $ride = Ride::factory()->create([
            'status' => 'accepted',
            'driver_id' => $this->driver->id,
            'vehicle_id' => $this->vehicle->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/arrive");

        $response->assertStatus(200);

        $this->assertDatabaseHas('rides', [
            'id' => $ride->id,
            'status' => 'arrived',
        ]);

        $ride->refresh();
        $this->assertNotNull($ride->arrived_at);
    }

    /**
     * Test driver can start ride
     */
    public function test_driver_can_start_ride(): void
    {
        $ride = Ride::factory()->create([
            'status' => 'arrived',
            'driver_id' => $this->driver->id,
            'vehicle_id' => $this->vehicle->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/start");

        $response->assertStatus(200);

        $this->assertDatabaseHas('rides', [
            'id' => $ride->id,
            'status' => 'in_progress',
        ]);

        $ride->refresh();
        $this->assertNotNull($ride->started_at);
    }

    /**
     * Test driver can complete ride
     */
    public function test_driver_can_complete_ride(): void
    {
        $ride = Ride::factory()->create([
            'status' => 'in_progress',
            'driver_id' => $this->driver->id,
            'vehicle_id' => $this->vehicle->id,
            'estimated_price' => 25.00,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/complete", [
            'final_latitude' => -23.5629,
            'final_longitude' => -46.6544,
            'actual_distance_meters' => 5000,
            'actual_duration_seconds' => 900,
        ]);

        $response->assertStatus(200);

        $ride->refresh();

        $this->assertEquals('completed', $ride->status);
        $this->assertNotNull($ride->completed_at);
        $this->assertNotNull($ride->final_price);
        $this->assertNotNull($ride->platform_fee);
        $this->assertNotNull($ride->driver_earnings);

        // Driver should be available again
        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'status' => 'available',
        ]);
    }

    /**
     * Test driver can view their active ride
     */
    public function test_driver_can_view_active_ride(): void
    {
        $ride = Ride::factory()->create([
            'status' => 'in_progress',
            'driver_id' => $this->driver->id,
            'vehicle_id' => $this->vehicle->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/rides/active');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'ride_number',
                    'status',
                    'passenger',
                ],
            ]);
    }

    /**
     * Test driver can view ride history
     */
    public function test_driver_can_view_ride_history(): void
    {
        Ride::factory()->count(5)->create([
            'driver_id' => $this->driver->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/rides');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'ride_number',
                        'status',
                        'final_price',
                    ],
                ],
                'meta' => [
                    'current_page',
                    'total',
                ],
            ]);
    }

    /**
     * Test driver can cancel accepted ride
     */
    public function test_driver_can_cancel_accepted_ride(): void
    {
        $ride = Ride::factory()->create([
            'status' => 'accepted',
            'driver_id' => $this->driver->id,
            'vehicle_id' => $this->vehicle->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/cancel", [
            'reason' => 'Emergency situation',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('rides', [
            'id' => $ride->id,
            'status' => 'cancelled',
            'cancelled_by' => 'driver',
            'cancellation_reason' => 'Emergency situation',
        ]);

        // Driver should be available again
        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'status' => 'available',
        ]);
    }

    /**
     * Test driver cannot accept ride when offline
     */
    public function test_driver_cannot_accept_ride_when_offline(): void
    {
        $this->driverProfile->update(['is_online' => false]);

        $ride = Ride::factory()->create([
            'status' => 'searching',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/accept");

        $response->assertStatus(403);
    }

    /**
     * Test driver cannot accept ride when on another ride
     */
    public function test_driver_cannot_accept_ride_when_on_another_ride(): void
    {
        $this->driverProfile->update(['status' => 'on_ride']);

        $ride = Ride::factory()->create([
            'status' => 'searching',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/rides/{$ride->id}/accept");

        $response->assertStatus(403);
    }

    /**
     * Test driver can update location during ride
     */
    public function test_driver_can_update_location_during_ride(): void
    {
        $ride = Ride::factory()->create([
            'status' => 'in_progress',
            'driver_id' => $this->driver->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/location', [
            'latitude' => -23.5505,
            'longitude' => -46.6333,
            'heading' => 90.0,
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'current_latitude' => -23.5505,
            'current_longitude' => -46.6333,
        ]);
    }

    /**
     * Test passenger user cannot access driver endpoints
     */
    public function test_passenger_cannot_access_driver_endpoints(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $passengerToken = $passenger->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $passengerToken,
        ])->getJson('/api/v1/driver/rides/available');

        $response->assertStatus(403);
    }
}
