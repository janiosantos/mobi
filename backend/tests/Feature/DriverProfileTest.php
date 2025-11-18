<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\DriverProfile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DriverProfileTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $driver;
    protected DriverProfile $driverProfile;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->driver = User::factory()->create([
            'user_type' => 'driver',
        ]);

        $this->driverProfile = DriverProfile::factory()->create([
            'user_id' => $this->driver->id,
        ]);

        $this->token = $this->driver->createToken('test-token')->plainTextToken;

        Storage::fake('public');
    }

    /**
     * Test driver can view their profile
     */
    public function test_driver_can_view_profile(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/profile');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'cnh',
                    'status',
                    'is_online',
                    'total_rides',
                    'average_rating',
                    'total_earnings',
                ],
            ]);
    }

    /**
     * Test driver can update profile
     */
    public function test_driver_can_update_profile(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/driver/profile', [
            'cnh' => '12345678901',
            'cnh_category' => 'AB',
            'cnh_expiry_date' => '2028-12-31',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'cnh' => '12345678901',
            'cnh_category' => 'AB',
        ]);
    }

    /**
     * Test driver can toggle online status
     */
    public function test_driver_can_toggle_online_status(): void
    {
        $this->driverProfile->update(['is_online' => false]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/toggle-online');

        $response->assertStatus(200);

        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'is_online' => true,
        ]);

        // Toggle back to offline
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/toggle-online');

        $response->assertStatus(200);

        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'is_online' => false,
        ]);
    }

    /**
     * Test driver can update location
     */
    public function test_driver_can_update_location(): void
    {
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

        $this->driverProfile->refresh();
        $this->assertNotNull($this->driverProfile->last_location_update);
    }

    /**
     * Test driver can upload CNH document
     */
    public function test_driver_can_upload_cnh_document(): void
    {
        $file = UploadedFile::fake()->image('cnh.jpg', 1000, 600);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents/cnh', [
            'cnh_document' => $file,
        ]);

        $response->assertStatus(200);

        $this->driverProfile->refresh();
        $this->assertNotNull($this->driverProfile->cnh_document_url);

        Storage::disk('public')->assertExists($this->driverProfile->cnh_document_url);
    }

    /**
     * Test driver can upload background check document
     */
    public function test_driver_can_upload_background_check(): void
    {
        $file = UploadedFile::fake()->create('background_check.pdf', 1000);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents/background-check', [
            'background_check_document' => $file,
        ]);

        $response->assertStatus(200);

        $this->driverProfile->refresh();
        $this->assertNotNull($this->driverProfile->background_check_document_url);
    }

    /**
     * Test document validation
     */
    public function test_document_upload_fails_with_invalid_file(): void
    {
        $file = UploadedFile::fake()->create('document.txt', 1000);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents/cnh', [
            'cnh_document' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['cnh_document']);
    }

    /**
     * Test driver can view statistics
     */
    public function test_driver_can_view_statistics(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/statistics');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'total_rides',
                    'completed_rides',
                    'cancelled_rides',
                    'acceptance_rate',
                    'cancellation_rate',
                    'average_rating',
                    'total_earnings',
                    'available_balance',
                ],
            ]);
    }

    /**
     * Test driver cannot go online with incomplete profile
     */
    public function test_driver_cannot_go_online_with_incomplete_profile(): void
    {
        $this->driverProfile->update([
            'cnh' => null,
            'is_online' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/toggle-online');

        $response->assertStatus(422);

        $this->assertDatabaseHas('driver_profiles', [
            'user_id' => $this->driver->id,
            'is_online' => false,
        ]);
    }

    /**
     * Test driver cannot go online with pending status
     */
    public function test_driver_cannot_go_online_with_pending_status(): void
    {
        $this->driverProfile->update([
            'status' => 'pending',
            'is_online' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/toggle-online');

        $response->assertStatus(403);
    }

    /**
     * Test driver with suspended status cannot go online
     */
    public function test_suspended_driver_cannot_go_online(): void
    {
        $this->driverProfile->update([
            'status' => 'suspended',
            'is_online' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/toggle-online');

        $response->assertStatus(403);
    }

    /**
     * Test location update validation
     */
    public function test_location_update_fails_with_invalid_coordinates(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/location', [
            'latitude' => 999, // Invalid
            'longitude' => -46.6333,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['latitude']);
    }

    /**
     * Test passenger cannot access driver profile endpoints
     */
    public function test_passenger_cannot_access_driver_profile_endpoints(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $passengerToken = $passenger->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $passengerToken,
        ])->getJson('/api/v1/driver/profile');

        $response->assertStatus(403);
    }

    /**
     * Test driver profile CNH expiry validation
     */
    public function test_cnh_expiry_date_must_be_future(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson('/api/v1/driver/profile', [
            'cnh' => '12345678901',
            'cnh_category' => 'AB',
            'cnh_expiry_date' => '2020-01-01', // Past date
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['cnh_expiry_date']);
    }

    /**
     * Test driver can view earnings breakdown
     */
    public function test_driver_can_view_earnings_breakdown(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings/breakdown');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'today',
                    'this_week',
                    'this_month',
                    'all_time',
                ],
            ]);
    }
}
