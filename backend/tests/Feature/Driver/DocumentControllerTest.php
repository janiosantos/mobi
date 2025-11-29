<?php

declare(strict_types=1);

namespace Tests\Feature\Driver;

use App\Models\User;
use App\Models\DriverProfile;
use App\Models\Document;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DocumentControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $driver;
    protected DriverProfile $driverProfile;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->driver = User::factory()->create(['user_type' => 'driver']);
        $this->driverProfile = DriverProfile::factory()->create([
            'user_id' => $this->driver->id,
        ]);
        $this->token = $this->driver->createToken('test-token')->plainTextToken;
    }

    /**
     * Test driver can list their documents
     */
    public function test_driver_can_list_documents(): void
    {
        Document::factory()->count(3)->create([
            'driver_profile_id' => $this->driverProfile->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/documents');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'type',
                        'file_url',
                        'status',
                        'created_at',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can upload document
     */
    public function test_driver_can_upload_document(): void
    {
        Storage::fake('private');

        $file = UploadedFile::fake()->image('cnh.jpg', 1200, 800);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents', [
            'type' => 'cnh',
            'file' => $file,
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'type',
                    'file_url',
                    'status',
                ],
            ]);

        $this->assertDatabaseHas('documents', [
            'driver_profile_id' => $this->driverProfile->id,
            'type' => 'cnh',
            'status' => 'pending',
        ]);
    }

    /**
     * Test driver can view specific document
     */
    public function test_driver_can_view_document(): void
    {
        $document = Document::factory()->create([
            'driver_profile_id' => $this->driverProfile->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson("/api/v1/driver/documents/{$document->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $document->id,
                    'type' => $document->type,
                ],
            ]);
    }

    /**
     * Test driver can delete pending document
     */
    public function test_driver_can_delete_pending_document(): void
    {
        $document = Document::factory()->create([
            'driver_profile_id' => $this->driverProfile->id,
            'status' => 'pending',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/driver/documents/{$document->id}");

        $response->assertStatus(200);

        $this->assertDatabaseMissing('documents', [
            'id' => $document->id,
        ]);
    }

    /**
     * Test driver cannot delete approved document
     */
    public function test_driver_cannot_delete_approved_document(): void
    {
        $document = Document::factory()->create([
            'driver_profile_id' => $this->driverProfile->id,
            'status' => 'approved',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/driver/documents/{$document->id}");

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Cannot delete approved documents',
            ]);

        $this->assertDatabaseHas('documents', [
            'id' => $document->id,
        ]);
    }

    /**
     * Test driver can check approval status
     */
    public function test_driver_can_check_approval_status(): void
    {
        Document::factory()->create([
            'driver_profile_id' => $this->driverProfile->id,
            'type' => 'cnh',
            'status' => 'approved',
        ]);

        Document::factory()->create([
            'driver_profile_id' => $this->driverProfile->id,
            'type' => 'vehicle_registration',
            'status' => 'pending',
        ]);

        Document::factory()->create([
            'driver_profile_id' => $this->driverProfile->id,
            'type' => 'insurance',
            'status' => 'rejected',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/documents/status');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'total_documents' => 3,
                    'approved_count' => 1,
                    'pending_count' => 1,
                    'rejected_count' => 1,
                    'all_approved' => false,
                ],
            ]);
    }

    /**
     * Test passenger cannot access driver documents
     */
    public function test_passenger_cannot_access_driver_documents(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $passengerToken = $passenger->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $passengerToken,
        ])->getJson('/api/v1/driver/documents');

        $response->assertStatus(403);
    }

    /**
     * Test driver cannot access other driver's documents
     */
    public function test_driver_cannot_access_other_driver_documents(): void
    {
        $otherDriver = User::factory()->create(['user_type' => 'driver']);
        $otherProfile = DriverProfile::factory()->create([
            'user_id' => $otherDriver->id,
        ]);

        $document = Document::factory()->create([
            'driver_profile_id' => $otherProfile->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson("/api/v1/driver/documents/{$document->id}");

        $response->assertStatus(403);
    }

    /**
     * Test validation requires document type
     */
    public function test_validation_requires_type(): void
    {
        Storage::fake('private');

        $file = UploadedFile::fake()->image('doc.jpg');

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents', [
            'file' => $file,
            // Missing 'type'
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /**
     * Test validation requires valid document type
     */
    public function test_validation_requires_valid_type(): void
    {
        Storage::fake('private');

        $file = UploadedFile::fake()->image('doc.jpg');

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents', [
            'type' => 'invalid_type',
            'file' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /**
     * Test validation requires file
     */
    public function test_validation_requires_file(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents', [
            'type' => 'cnh',
            // Missing 'file'
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['file']);
    }

    /**
     * Test file must be image
     */
    public function test_file_must_be_image(): void
    {
        Storage::fake('private');

        $file = UploadedFile::fake()->create('document.pdf', 1000);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents', [
            'type' => 'cnh',
            'file' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['file']);
    }

    /**
     * Test file size limit
     */
    public function test_file_size_limit(): void
    {
        Storage::fake('private');

        // Create 11MB file (limit is usually 10MB)
        $file = UploadedFile::fake()->image('large.jpg')->size(11264);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/documents', [
            'type' => 'cnh',
            'file' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['file']);
    }

    /**
     * Test can upload different document types
     */
    public function test_can_upload_different_document_types(): void
    {
        Storage::fake('private');

        $types = ['cnh', 'vehicle_registration', 'insurance', 'photo'];

        foreach ($types as $type) {
            $file = UploadedFile::fake()->image("{$type}.jpg");

            $response = $this->withHeaders([
                'Authorization' => 'Bearer ' . $this->token,
            ])->postJson('/api/v1/driver/documents', [
                'type' => $type,
                'file' => $file,
            ]);

            $response->assertStatus(201);
        }

        $this->assertEquals(4, Document::where('driver_profile_id', $this->driverProfile->id)->count());
    }

    /**
     * Test unauthenticated user cannot access documents
     */
    public function test_unauthenticated_user_cannot_access_documents(): void
    {
        $response = $this->getJson('/api/v1/driver/documents');

        $response->assertStatus(401);
    }
}
