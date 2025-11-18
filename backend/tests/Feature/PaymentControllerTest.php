<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Ride;
use App\Models\Payment;
use App\Models\PaymentMethod;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class PaymentControllerTest extends TestCase
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
     * Test passenger can view payment methods
     */
    public function test_passenger_can_view_payment_methods(): void
    {
        PaymentMethod::factory()->count(3)->create([
            'user_id' => $this->passenger->id,
            'is_active' => true,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/payment-methods');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'type',
                        'card_brand',
                        'card_last_four',
                        'is_default',
                    ],
                ],
            ]);
    }

    /**
     * Test passenger can add credit card payment method
     */
    public function test_passenger_can_add_credit_card(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', [
            'type' => 'credit_card',
            'card_token' => 'test_token_' . $this->faker->uuid,
            'card_brand' => 'visa',
            'card_last_four' => '4242',
            'cardholder_name' => 'John Doe',
            'is_default' => true,
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'type',
                    'card_brand',
                    'card_last_four',
                ],
            ]);

        $this->assertDatabaseHas('payment_methods', [
            'user_id' => $this->passenger->id,
            'type' => 'credit_card',
            'card_brand' => 'visa',
            'card_last_four' => '4242',
        ]);
    }

    /**
     * Test payment method validation
     */
    public function test_payment_method_creation_fails_with_invalid_data(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/payment-methods', [
            'type' => 'invalid_type',
            'card_brand' => 'visa',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /**
     * Test passenger can set default payment method
     */
    public function test_passenger_can_set_default_payment_method(): void
    {
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $this->passenger->id,
            'is_default' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->patchJson("/api/v1/payment-methods/{$paymentMethod->id}/default");

        $response->assertStatus(200);

        $this->assertDatabaseHas('payment_methods', [
            'id' => $paymentMethod->id,
            'is_default' => true,
        ]);
    }

    /**
     * Test passenger can delete payment method
     */
    public function test_passenger_can_delete_payment_method(): void
    {
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $this->passenger->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/payment-methods/{$paymentMethod->id}");

        $response->assertStatus(200);

        $this->assertDatabaseHas('payment_methods', [
            'id' => $paymentMethod->id,
            'is_active' => false,
        ]);
    }

    /**
     * Test passenger cannot delete other user's payment method
     */
    public function test_passenger_cannot_delete_other_user_payment_method(): void
    {
        $otherUser = User::factory()->create(['user_type' => 'passenger']);
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->deleteJson("/api/v1/payment-methods/{$paymentMethod->id}");

        $response->assertStatus(403);
    }

    /**
     * Test passenger can view payment history
     */
    public function test_passenger_can_view_payment_history(): void
    {
        $rides = Ride::factory()->count(3)->create([
            'passenger_id' => $this->passenger->id,
            'status' => 'completed',
        ]);

        foreach ($rides as $ride) {
            Payment::factory()->create([
                'ride_id' => $ride->id,
                'user_id' => $this->passenger->id,
                'status' => 'completed',
            ]);
        }

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/payments');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'payment_number',
                        'amount',
                        'status',
                        'payment_type',
                    ],
                ],
                'meta' => [
                    'current_page',
                    'total',
                ],
            ]);
    }

    /**
     * Test passenger can view specific payment
     */
    public function test_passenger_can_view_specific_payment(): void
    {
        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
        ]);

        $payment = Payment::factory()->create([
            'ride_id' => $ride->id,
            'user_id' => $this->passenger->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson("/api/v1/payments/{$payment->id}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'payment_number',
                    'amount',
                    'status',
                    'ride',
                ],
            ]);
    }

    /**
     * Test passenger can create PIX payment for ride
     */
    public function test_passenger_can_create_pix_payment(): void
    {
        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'status' => 'completed',
            'final_price' => 25.00,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/payment", [
            'payment_method' => 'pix',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'payment_type',
                    'amount',
                    'pix_qr_code',
                ],
            ]);

        $this->assertDatabaseHas('payments', [
            'ride_id' => $ride->id,
            'user_id' => $this->passenger->id,
            'payment_type' => 'pix',
        ]);
    }

    /**
     * Test passenger can create card payment for ride
     */
    public function test_passenger_can_create_card_payment(): void
    {
        $paymentMethod = PaymentMethod::factory()->create([
            'user_id' => $this->passenger->id,
            'type' => 'credit_card',
        ]);

        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'status' => 'completed',
            'final_price' => 35.00,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/payment", [
            'payment_method_id' => $paymentMethod->id,
            'installments' => 1,
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'payment_type',
                    'amount',
                    'status',
                ],
            ]);

        $this->assertDatabaseHas('payments', [
            'ride_id' => $ride->id,
            'user_id' => $this->passenger->id,
            'payment_method_id' => $paymentMethod->id,
        ]);
    }

    /**
     * Test driver can view earnings
     */
    public function test_driver_can_view_earnings(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        $driverToken = $driver->createToken('test-token')->plainTextToken;

        $rides = Ride::factory()->count(3)->create([
            'driver_id' => $driver->id,
            'status' => 'completed',
            'final_price' => 30.00,
            'driver_earnings' => 24.00,
        ]);

        foreach ($rides as $ride) {
            Payment::factory()->create([
                'ride_id' => $ride->id,
                'user_id' => $ride->passenger_id,
                'status' => 'completed',
                'driver_amount' => 24.00,
            ]);
        }

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $driverToken,
        ])->getJson('/api/v1/driver/earnings');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'total_earnings',
                    'available_balance',
                    'pending_amount',
                    'payments' => [
                        '*' => [
                            'id',
                            'amount',
                            'driver_amount',
                            'ride',
                        ],
                    ],
                ],
            ]);
    }

    /**
     * Test payment cannot be created for unpaid ride status
     */
    public function test_payment_cannot_be_created_for_searching_ride(): void
    {
        $ride = Ride::factory()->create([
            'passenger_id' => $this->passenger->id,
            'status' => 'searching',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson("/api/v1/rides/{$ride->id}/payment", [
            'payment_method' => 'pix',
        ]);

        $response->assertStatus(422);
    }

    /**
     * Test unauthenticated user cannot access payments
     */
    public function test_unauthenticated_user_cannot_access_payments(): void
    {
        $response = $this->getJson('/api/v1/payments');

        $response->assertStatus(401);
    }
}
