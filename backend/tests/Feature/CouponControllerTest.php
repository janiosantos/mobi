<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use App\Models\Coupon;
use App\Models\CouponUsage;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class CouponControllerTest extends TestCase
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
     * Test user can list available coupons
     */
    public function test_user_can_list_available_coupons(): void
    {
        // Create active coupons
        Coupon::factory()->count(3)->create([
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
        ]);

        // Create inactive coupon (should not appear)
        Coupon::factory()->create([
            'is_active' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/coupons');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'code',
                        'type',
                        'value',
                        'description',
                        'valid_until',
                    ],
                ],
            ]);
    }

    /**
     * Test user can validate a valid percentage coupon
     */
    public function test_user_can_validate_percentage_coupon(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'PERCENT10',
            'type' => 'percentage',
            'value' => 10,
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
            'min_ride_value' => 20.00,
            'max_discount' => null,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'PERCENT10',
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'valid' => true,
                    'discount_amount' => 5.00, // 10% of 50
                    'final_price' => 45.00,
                ],
            ]);
    }

    /**
     * Test user can validate a fixed value coupon
     */
    public function test_user_can_validate_fixed_coupon(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'FIXED15',
            'type' => 'fixed',
            'value' => 15,
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'FIXED15',
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'valid' => true,
                    'discount_amount' => 15.00,
                    'final_price' => 35.00,
                ],
            ]);
    }

    /**
     * Test expired coupon validation fails
     */
    public function test_expired_coupon_validation_fails(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'EXPIRED',
            'is_active' => true,
            'valid_from' => now()->subMonth(),
            'valid_until' => now()->subDay(), // Expired yesterday
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'EXPIRED',
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Coupon has expired',
            ]);
    }

    /**
     * Test max uses coupon validation fails when limit reached
     */
    public function test_max_uses_coupon_validation_fails(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'LIMITED',
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
            'max_uses' => 5,
            'uses_count' => 5, // Already used 5 times
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'LIMITED',
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Coupon has reached maximum uses',
            ]);
    }

    /**
     * Test already used coupon validation fails
     */
    public function test_already_used_coupon_validation_fails(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'ONEPERUSER',
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
        ]);

        // User has already used this coupon
        CouponUsage::factory()->create([
            'coupon_id' => $coupon->id,
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'ONEPERUSER',
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'You have already used this coupon',
            ]);
    }

    /**
     * Test min ride value validation
     */
    public function test_min_ride_value_validation(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'MINVALUE',
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
            'min_ride_value' => 30.00,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'MINVALUE',
            'ride_value' => 20.00, // Below minimum
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Ride value must be at least R$ 30.00 to use this coupon',
            ]);
    }

    /**
     * Test discount calculation with max_discount cap
     */
    public function test_discount_calculation_with_max_discount(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'CAPPED',
            'type' => 'percentage',
            'value' => 50, // 50% discount
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
            'max_discount' => 15.00, // But capped at R$15
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'CAPPED',
            'ride_value' => 100.00, // 50% would be R$50, but capped at R$15
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'valid' => true,
                    'discount_amount' => 15.00, // Capped
                    'final_price' => 85.00,
                ],
            ]);
    }

    /**
     * Test percentage discount calculation without cap
     */
    public function test_discount_calculation_percentage(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'PERCENT20',
            'type' => 'percentage',
            'value' => 20,
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'PERCENT20',
            'ride_value' => 100.00,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'valid' => true,
                    'discount_amount' => 20.00, // 20% of 100
                    'final_price' => 80.00,
                ],
            ]);
    }

    /**
     * Test fixed discount calculation
     */
    public function test_discount_calculation_fixed(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'FIXED25',
            'type' => 'fixed',
            'value' => 25,
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'FIXED25',
            'ride_value' => 100.00,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'valid' => true,
                    'discount_amount' => 25.00,
                    'final_price' => 75.00,
                ],
            ]);
    }

    /**
     * Test inactive coupon cannot be validated
     */
    public function test_inactive_coupon_validation_fails(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'INACTIVE',
            'is_active' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'INACTIVE',
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Coupon is not active',
            ]);
    }

    /**
     * Test non-existent coupon validation fails
     */
    public function test_nonexistent_coupon_validation_fails(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'DOESNOTEXIST',
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Coupon not found',
            ]);
    }

    /**
     * Test code is case insensitive
     */
    public function test_coupon_code_is_case_insensitive(): void
    {
        $coupon = Coupon::factory()->create([
            'code' => 'WELCOME10',
            'is_active' => true,
            'valid_from' => now()->subDay(),
            'valid_until' => now()->addMonth(),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/coupons/validate', [
            'code' => 'welcome10', // lowercase
            'ride_value' => 50.00,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.valid', true);
    }

    /**
     * Test unauthenticated user cannot access coupons
     */
    public function test_unauthenticated_user_cannot_access_coupons(): void
    {
        $response = $this->getJson('/api/v1/coupons');

        $response->assertStatus(401);
    }
}
