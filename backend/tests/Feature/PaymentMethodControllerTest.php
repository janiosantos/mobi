<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use App\Models\PaymentMethod;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class PaymentMethodControllerTest extends TestCase
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
     * Test user can list their payment methods
     */
    public function test_user_can_list_payment_methods(): void
    {
        PaymentMethod::factory()->count(3)->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/payment-methods');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'type',
                        'last_four',
                        'brand',
                        'is_default',
                        'created_at',
                    ],
                ],
            ]);
    }

    /**
     * Test user can create a payment method
     */
    public function test_user_can_create_payment_method(): void
    {
        $data = [
            'type' => 'credit_card',
            'last_four' => '1234',
            'brand' => 'visa',
            'token' => 'tok_' . $this->faker->uuid,
        ];

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', $data);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'type',
                    'last_four',
                    'brand',
                    'is_default',
                ],
            ]);

        $this->assertDatabaseHas('payment_methods', [
            'user_id' => $this->user->id,
            'type' => 'credit_card',
            'last_four' => '1234',
            'brand' => 'visa',
        ]);
    }

    /**
     * Test first payment method is automatically set as default
     */
    public function test_first_payment_method_is_default(): void
    {
        $data = [
            'type' => 'credit_card',
            'last_four' => '1234',
            'brand' => 'visa',
            'token' => 'tok_test',
        ];

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', $data);

        $response->assertStatus(201)
            ->assertJsonPath('data.is_default', true);

        $this->assertDatabaseHas('payment_methods', [
            'user_id' => $this->user->id,
            'is_default' => true,
        ]);
    }

    /**
     * Test subsequent payment methods are not default
     */
    public function test_subsequent_payment_methods_not_default(): void
    {
        // Create first payment method
        PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => true,
        ]);

        // Create second payment method
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', [
            'type' => 'debit_card',
            'last_four' => '5678',
            'brand' => 'mastercard',
            'token' => 'tok_test2',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.is_default', false);
    }

    /**
     * Test user can view specific payment method
     */
    public function test_user_can_view_payment_method(): void
    {
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson("/api/v1/payment-methods/{$paymentMethod->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $paymentMethod->id,
                    'type' => $paymentMethod->type,
                ],
            ]);
    }

    /**
     * Test user can update payment method
     */
    public function test_user_can_update_payment_method(): void
    {
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
            'last_four' => '1234',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson("/api/v1/payment-methods/{$paymentMethod->id}", [
            'last_four' => '5678',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('payment_methods', [
            'id' => $paymentMethod->id,
            'last_four' => '5678',
        ]);
    }

    /**
     * Test user can delete payment method
     */
    public function test_user_can_delete_payment_method(): void
    {
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/payment-methods/{$paymentMethod->id}");

        $response->assertStatus(200);

        $this->assertDatabaseMissing('payment_methods', [
            'id' => $paymentMethod->id,
        ]);
    }

    /**
     * Test user can set payment method as default
     */
    public function test_user_can_set_default_payment_method(): void
    {
        $default = PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => true,
        ]);

        $newDefault = PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson("/api/v1/payment-methods/{$newDefault->id}/default");

        $response->assertStatus(200);

        // Old default should no longer be default
        $this->assertDatabaseHas('payment_methods', [
            'id' => $default->id,
            'is_default' => false,
        ]);

        // New one should be default
        $this->assertDatabaseHas('payment_methods', [
            'id' => $newDefault->id,
            'is_default' => true,
        ]);
    }

    /**
     * Test user cannot access other user's payment methods
     */
    public function test_user_cannot_access_other_user_payment_methods(): void
    {
        $otherUser = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson("/api/v1/payment-methods/{$paymentMethod->id}");

        $response->assertStatus(403);
    }

    /**
     * Test user cannot update other user's payment methods
     */
    public function test_user_cannot_update_other_user_payment_methods(): void
    {
        $otherUser = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson("/api/v1/payment-methods/{$paymentMethod->id}", [
            'last_four' => '9999',
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test user cannot delete other user's payment methods
     */
    public function test_user_cannot_delete_other_user_payment_methods(): void
    {
        $otherUser = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/payment-methods/{$paymentMethod->id}");

        $response->assertStatus(403);
    }

    /**
     * Test validation requires type
     */
    public function test_validation_requires_type(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', [
            'last_four' => '1234',
            'brand' => 'visa',
            // Missing 'type'
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /**
     * Test validation requires valid type
     */
    public function test_validation_requires_valid_type(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', [
            'type' => 'invalid_type',
            'last_four' => '1234',
            'brand' => 'visa',
            'token' => 'tok_test',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /**
     * Test validation for last_four digits
     */
    public function test_validation_for_last_four(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', [
            'type' => 'credit_card',
            'last_four' => '12', // Too short
            'brand' => 'visa',
            'token' => 'tok_test',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['last_four']);
    }

    /**
     * Test user can create PIX payment method
     */
    public function test_user_can_create_pix_payment_method(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', [
            'type' => 'pix',
            'last_four' => '',
            'brand' => 'pix',
            'token' => 'pix_key_' . $this->faker->uuid,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.type', 'pix');
    }

    /**
     * Test unauthenticated user cannot access payment methods
     */
    public function test_unauthenticated_user_cannot_access_payment_methods(): void
    {
        $response = $this->getJson('/api/v1/payment-methods');

        $response->assertStatus(401);
    }

    /**
     * Test only one payment method can be default at a time
     */
    public function test_only_one_default_payment_method(): void
    {
        $method1 = PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => true,
        ]);

        $method2 = PaymentMethod::factory()->create([
            'user_id' => $this->user->id,
            'is_default' => false,
        ]);

        // Set method2 as default
        $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->putJson("/api/v1/payment-methods/{$method2->id}/default");

        // Verify only method2 is default
        $this->assertEquals(1, PaymentMethod::where('user_id', $this->user->id)
            ->where('is_default', true)
            ->count());

        $method1->refresh();
        $method2->refresh();

        $this->assertFalse($method1->is_default);
        $this->assertTrue($method2->is_default);
    }
}
