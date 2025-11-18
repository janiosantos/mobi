<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\DriverProfile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class VehicleControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $driver;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->driver = User::factory()->create([
            'user_type' => 'driver',
        ]);

        DriverProfile::factory()->create([
            'user_id' => $this->driver->id,
        ]);

        $this->token = $this->driver->createToken('test-token')->plainTextToken;

        Storage::fake('public');
    }

    /**
     * Test driver can view their vehicles
     */
    public function test_driver_can_view_their_vehicles(): void
    {
        Vehicle::factory()->count(2)->create([
            'driver_id' => $this->driver->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/vehicles');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'make',
                        'model',
                        'year',
                        'license_plate',
                        'category',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can add new vehicle
     */
    public function test_driver_can_add_vehicle(): void
    {
        $category = VehicleCategory::factory()->create();

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/vehicles', [
            'category_id' => $category->id,
            'make' => 'Toyota',
            'model' => 'Corolla',
            'year' => 2022,
            'color' => 'White',
            'license_plate' => 'ABC-1234',
            'renavam' => '12345678901',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'make',
                    'model',
                    'license_plate',
                ],
            ]);

        $this->assertDatabaseHas('vehicles', [
            'driver_id' => $this->driver->id,
            'make' => 'Toyota',
            'model' => 'Corolla',
            'license_plate' => 'ABC-1234',
        ]);
    }

    /**
     * Test vehicle creation validation
     */
    public function test_vehicle_creation_fails_with_invalid_data(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/vehicles', [
            'make' => 'Toyota',
            'year' => 1899, // Too old
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['year', 'category_id', 'license_plate']);
    }

    /**
     * Test driver can update vehicle
     */
    public function test_driver_can_update_vehicle(): void
    {
        $vehicle = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
            'color' => 'Black',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson("/api/v1/driver/vehicles/{$vehicle->id}", [
            'category_id' => $vehicle->category_id,
            'make' => $vehicle->make,
            'model' => $vehicle->model,
            'year' => $vehicle->year,
            'color' => 'White',
            'license_plate' => $vehicle->license_plate,
            'renavam' => $vehicle->renavam,
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('vehicles', [
            'id' => $vehicle->id,
            'color' => 'White',
        ]);
    }

    /**
     * Test driver cannot update other driver's vehicle
     */
    public function test_driver_cannot_update_other_driver_vehicle(): void
    {
        $otherDriver = User::factory()->create(['user_type' => 'driver']);
        $vehicle = Vehicle::factory()->create([
            'driver_id' => $otherDriver->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson("/api/v1/driver/vehicles/{$vehicle->id}", [
            'color' => 'Red',
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test driver can delete vehicle
     */
    public function test_driver_can_delete_vehicle(): void
    {
        $vehicle = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
            'is_active' => true,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/driver/vehicles/{$vehicle->id}");

        $response->assertStatus(200);

        $this->assertDatabaseHas('vehicles', [
            'id' => $vehicle->id,
            'is_active' => false,
        ]);
    }

    /**
     * Test driver can upload vehicle photo
     */
    public function test_driver_can_upload_vehicle_photo(): void
    {
        $vehicle = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
        ]);

        $file = UploadedFile::fake()->image('vehicle.jpg', 1000, 1000);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/vehicles/{$vehicle->id}/photo", [
            'photo' => $file,
        ]);

        $response->assertStatus(200);

        $vehicle->refresh();
        $this->assertNotNull($vehicle->vehicle_photo_url);

        // Verify file was stored
        Storage::disk('public')->assertExists($vehicle->vehicle_photo_url);
    }

    /**
     * Test photo upload validation
     */
    public function test_photo_upload_fails_with_invalid_file(): void
    {
        $vehicle = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
        ]);

        $file = UploadedFile::fake()->create('document.pdf', 1000);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/vehicles/{$vehicle->id}/photo", [
            'photo' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['photo']);
    }

    /**
     * Test driver can upload vehicle documents
     */
    public function test_driver_can_upload_vehicle_documents(): void
    {
        $vehicle = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
        ]);

        $crlv = UploadedFile::fake()->image('crlv.jpg');

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/vehicles/{$vehicle->id}/documents", [
            'crlv_document_url' => $crlv,
        ]);

        $response->assertStatus(200);

        $vehicle->refresh();
        $this->assertNotNull($vehicle->crlv_document_url);

        Storage::disk('public')->assertExists($vehicle->crlv_document_url);
    }

    /**
     * Test driver can view vehicle categories
     */
    public function test_driver_can_view_vehicle_categories(): void
    {
        VehicleCategory::factory()->count(4)->create([
            'is_active' => true,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/vehicle-categories');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'description',
                        'base_price',
                        'price_per_km',
                        'price_per_minute',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can set active vehicle
     */
    public function test_driver_can_set_active_vehicle(): void
    {
        $vehicle1 = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
            'is_active' => true,
        ]);

        $vehicle2 = Vehicle::factory()->create([
            'driver_id' => $this->driver->id,
            'is_active' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/driver/vehicles/{$vehicle2->id}/activate");

        $response->assertStatus(200);

        // Old vehicle should be inactive
        $this->assertDatabaseHas('vehicles', [
            'id' => $vehicle1->id,
            'is_active' => false,
        ]);

        // New vehicle should be active
        $this->assertDatabaseHas('vehicles', [
            'id' => $vehicle2->id,
            'is_active' => true,
        ]);
    }

    /**
     * Test passenger cannot access driver vehicle endpoints
     */
    public function test_passenger_cannot_access_driver_vehicle_endpoints(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $passengerToken = $passenger->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $passengerToken,
        ])->getJson('/api/v1/driver/vehicles');

        $response->assertStatus(403);
    }

    /**
     * Test duplicate license plate validation
     */
    public function test_duplicate_license_plate_is_rejected(): void
    {
        $category = VehicleCategory::factory()->create();

        Vehicle::factory()->create([
            'license_plate' => 'ABC-1234',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/vehicles', [
            'category_id' => $category->id,
            'make' => 'Toyota',
            'model' => 'Corolla',
            'year' => 2022,
            'color' => 'White',
            'license_plate' => 'ABC-1234', // Duplicate
            'renavam' => '12345678901',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['license_plate']);
    }
}
