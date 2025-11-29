<?php

declare(strict_types=1);

namespace Tests\Feature\Driver;

use App\Models\User;
use App\Models\DriverProfile;
use App\Models\Ride;
use App\Models\Earning;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class EarningControllerTest extends TestCase
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
            'total_earnings' => 500.00,
            'available_balance' => 300.00,
            'withdrawn_balance' => 200.00,
        ]);
        $this->token = $this->driver->createToken('test-token')->plainTextToken;
    }

    /**
     * Test driver can view earnings list
     */
    public function test_driver_can_view_earnings(): void
    {
        $rides = Ride::factory()->count(5)->create([
            'driver_id' => $this->driver->id,
            'status' => 'completed',
        ]);

        foreach ($rides as $ride) {
            Earning::factory()->create([
                'driver_id' => $this->driver->id,
                'ride_id' => $ride->id,
            ]);
        }

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings');

        $response->assertStatus(200)
            ->assertJsonCount(5, 'data')
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'ride_id',
                        'amount',
                        'platform_fee',
                        'driver_amount',
                        'status',
                        'created_at',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can view earnings summary
     */
    public function test_driver_can_view_earnings_summary(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings/summary');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'total_earnings' => 500.00,
                    'available_balance' => 300.00,
                    'withdrawn_balance' => 200.00,
                ],
            ])
            ->assertJsonStructure([
                'data' => [
                    'total_earnings',
                    'available_balance',
                    'withdrawn_balance',
                    'pending_balance',
                ],
            ]);
    }

    /**
     * Test driver can view daily earnings breakdown
     */
    public function test_driver_can_view_daily_breakdown(): void
    {
        // Create earnings for different days
        Earning::factory()->create([
            'driver_id' => $this->driver->id,
            'driver_amount' => 50.00,
            'created_at' => now(),
        ]);

        Earning::factory()->create([
            'driver_id' => $this->driver->id,
            'driver_amount' => 75.00,
            'created_at' => now(),
        ]);

        Earning::factory()->create([
            'driver_id' => $this->driver->id,
            'driver_amount' => 100.00,
            'created_at' => now()->subDay(),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings/daily');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'date',
                        'total_amount',
                        'rides_count',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can view weekly earnings breakdown
     */
    public function test_driver_can_view_weekly_breakdown(): void
    {
        // Create earnings for this week
        Earning::factory()->count(10)->create([
            'driver_id' => $this->driver->id,
            'created_at' => now()->startOfWeek()->addDays(2),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings/weekly');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'week',
                        'year',
                        'total_amount',
                        'rides_count',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can view monthly earnings breakdown
     */
    public function test_driver_can_view_monthly_breakdown(): void
    {
        Earning::factory()->count(15)->create([
            'driver_id' => $this->driver->id,
            'created_at' => now()->startOfMonth(),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings/monthly');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'month',
                        'year',
                        'total_amount',
                        'rides_count',
                    ],
                ],
            ]);
    }

    /**
     * Test driver can request withdrawal
     */
    public function test_driver_can_request_withdrawal(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/earnings/withdraw', [
            'amount' => 100.00,
            'bank_account' => [
                'bank_code' => '001',
                'agency' => '1234',
                'account' => '56789-0',
                'account_type' => 'checking',
            ],
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Withdrawal request created successfully',
            ]);

        $this->assertDatabaseHas('withdrawals', [
            'driver_id' => $this->driver->id,
            'amount' => 100.00,
            'status' => 'pending',
        ]);
    }

    /**
     * Test withdrawal requires sufficient balance
     */
    public function test_withdrawal_requires_sufficient_balance(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/earnings/withdraw', [
            'amount' => 500.00, // More than available balance (300.00)
            'bank_account' => [
                'bank_code' => '001',
                'agency' => '1234',
                'account' => '56789-0',
                'account_type' => 'checking',
            ],
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Insufficient balance for withdrawal',
            ]);
    }

    /**
     * Test withdrawal requires minimum amount
     */
    public function test_withdrawal_requires_minimum_amount(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/earnings/withdraw', [
            'amount' => 5.00, // Below minimum (usually R$10)
            'bank_account' => [
                'bank_code' => '001',
                'agency' => '1234',
                'account' => '56789-0',
                'account_type' => 'checking',
            ],
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['amount']);
    }

    /**
     * Test withdrawal validation requires bank account details
     */
    public function test_withdrawal_requires_bank_account(): void
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/driver/earnings/withdraw', [
            'amount' => 100.00,
            // Missing bank_account
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['bank_account']);
    }

    /**
     * Test passenger cannot access earnings
     */
    public function test_passenger_cannot_access_earnings(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $passengerToken = $passenger->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $passengerToken,
        ])->getJson('/api/v1/driver/earnings');

        $response->assertStatus(403);
    }

    /**
     * Test driver can filter earnings by date range
     */
    public function test_driver_can_filter_earnings_by_date(): void
    {
        Earning::factory()->create([
            'driver_id' => $this->driver->id,
            'created_at' => now()->subDays(5),
        ]);

        Earning::factory()->create([
            'driver_id' => $this->driver->id,
            'created_at' => now()->subDays(2),
        ]);

        Earning::factory()->create([
            'driver_id' => $this->driver->id,
            'created_at' => now(),
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings?from=' . now()->subDays(3)->toDateString() . '&to=' . now()->toDateString());

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    /**
     * Test earnings are paginated
     */
    public function test_earnings_are_paginated(): void
    {
        Earning::factory()->count(25)->create([
            'driver_id' => $this->driver->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/driver/earnings?per_page=10');

        $response->assertStatus(200)
            ->assertJsonCount(10, 'data')
            ->assertJsonStructure([
                'meta' => [
                    'current_page',
                    'last_page',
                    'total',
                ],
            ]);
    }

    /**
     * Test unauthenticated user cannot access earnings
     */
    public function test_unauthenticated_user_cannot_access_earnings(): void
    {
        $response = $this->getJson('/api/v1/driver/earnings');

        $response->assertStatus(401);
    }
}
