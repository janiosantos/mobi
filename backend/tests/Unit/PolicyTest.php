<?php

namespace Tests\Unit;

use App\Models\User;
use App\Models\Ride;
use App\Models\Vehicle;
use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\DriverProfile;
use App\Policies\RidePolicy;
use App\Policies\VehiclePolicy;
use App\Policies\PaymentPolicy;
use App\Policies\PaymentMethodPolicy;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PolicyTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test RidePolicy - passenger can view own ride
     */
    public function test_passenger_can_view_own_ride(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $ride = Ride::factory()->create(['passenger_id' => $passenger->id]);

        $policy = new RidePolicy();
        $this->assertTrue($policy->view($passenger, $ride));
    }

    /**
     * Test RidePolicy - passenger cannot view other's ride
     */
    public function test_passenger_cannot_view_others_ride(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $otherPassenger = User::factory()->create(['user_type' => 'passenger']);
        $ride = Ride::factory()->create(['passenger_id' => $otherPassenger->id]);

        $policy = new RidePolicy();
        $this->assertFalse($policy->view($passenger, $ride));
    }

    /**
     * Test RidePolicy - driver can view assigned ride
     */
    public function test_driver_can_view_assigned_ride(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        $ride = Ride::factory()->create(['driver_id' => $driver->id]);

        $policy = new RidePolicy();
        $this->assertTrue($policy->view($driver, $ride));
    }

    /**
     * Test RidePolicy - driver cannot view unassigned ride
     */
    public function test_driver_cannot_view_unassigned_ride(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        $otherDriver = User::factory()->create(['user_type' => 'driver']);
        $ride = Ride::factory()->create(['driver_id' => $otherDriver->id]);

        $policy = new RidePolicy();
        $this->assertFalse($policy->view($driver, $ride));
    }

    /**
     * Test RidePolicy - passenger can cancel own ride
     */
    public function test_passenger_can_cancel_own_ride(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $ride = Ride::factory()->create([
            'passenger_id' => $passenger->id,
            'status' => 'searching',
        ]);

        $policy = new RidePolicy();
        $this->assertTrue($policy->cancel($passenger, $ride));
    }

    /**
     * Test RidePolicy - passenger cannot cancel completed ride
     */
    public function test_passenger_cannot_cancel_completed_ride(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);
        $ride = Ride::factory()->create([
            'passenger_id' => $passenger->id,
            'status' => 'completed',
        ]);

        $policy = new RidePolicy();
        $this->assertFalse($policy->cancel($passenger, $ride));
    }

    /**
     * Test RidePolicy - driver can cancel accepted ride
     */
    public function test_driver_can_cancel_accepted_ride(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        $ride = Ride::factory()->create([
            'driver_id' => $driver->id,
            'status' => 'accepted',
        ]);

        $policy = new RidePolicy();
        $this->assertTrue($policy->cancel($driver, $ride));
    }

    /**
     * Test VehiclePolicy - driver can view own vehicle
     */
    public function test_driver_can_view_own_vehicle(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        DriverProfile::factory()->create(['user_id' => $driver->id]);
        $vehicle = Vehicle::factory()->create(['driver_id' => $driver->id]);

        $policy = new VehiclePolicy();
        $this->assertTrue($policy->view($driver, $vehicle));
    }

    /**
     * Test VehiclePolicy - driver cannot view other's vehicle
     */
    public function test_driver_cannot_view_others_vehicle(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        $otherDriver = User::factory()->create(['user_type' => 'driver']);
        DriverProfile::factory()->create(['user_id' => $driver->id]);
        DriverProfile::factory()->create(['user_id' => $otherDriver->id]);
        $vehicle = Vehicle::factory()->create(['driver_id' => $otherDriver->id]);

        $policy = new VehiclePolicy();
        $this->assertFalse($policy->view($driver, $vehicle));
    }

    /**
     * Test VehiclePolicy - driver can update own vehicle
     */
    public function test_driver_can_update_own_vehicle(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        DriverProfile::factory()->create(['user_id' => $driver->id]);
        $vehicle = Vehicle::factory()->create(['driver_id' => $driver->id]);

        $policy = new VehiclePolicy();
        $this->assertTrue($policy->update($driver, $vehicle));
    }

    /**
     * Test VehiclePolicy - passenger cannot create vehicle
     */
    public function test_passenger_cannot_create_vehicle(): void
    {
        $passenger = User::factory()->create(['user_type' => 'passenger']);

        $policy = new VehiclePolicy();
        $this->assertFalse($policy->create($passenger));
    }

    /**
     * Test VehiclePolicy - driver can create vehicle
     */
    public function test_driver_can_create_vehicle(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        DriverProfile::factory()->create(['user_id' => $driver->id]);

        $policy = new VehiclePolicy();
        $this->assertTrue($policy->create($driver));
    }

    /**
     * Test PaymentPolicy - user can view own payment
     */
    public function test_user_can_view_own_payment(): void
    {
        $user = User::factory()->create();
        $payment = Payment::factory()->create(['user_id' => $user->id]);

        $policy = new PaymentPolicy();
        $this->assertTrue($policy->view($user, $payment));
    }

    /**
     * Test PaymentPolicy - user cannot view other's payment
     */
    public function test_user_cannot_view_others_payment(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $payment = Payment::factory()->create(['user_id' => $otherUser->id]);

        $policy = new PaymentPolicy();
        $this->assertFalse($policy->view($user, $payment));
    }

    /**
     * Test PaymentPolicy - driver can view payment for their ride
     */
    public function test_driver_can_view_payment_for_their_ride(): void
    {
        $driver = User::factory()->create(['user_type' => 'driver']);
        $passenger = User::factory()->create(['user_type' => 'passenger']);

        $ride = Ride::factory()->create([
            'driver_id' => $driver->id,
            'passenger_id' => $passenger->id,
        ]);

        $payment = Payment::factory()->create([
            'ride_id' => $ride->id,
            'user_id' => $passenger->id,
        ]);

        $policy = new PaymentPolicy();
        $this->assertTrue($policy->view($driver, $payment));
    }

    /**
     * Test PaymentMethodPolicy - user can view own payment method
     */
    public function test_user_can_view_own_payment_method(): void
    {
        $user = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create(['user_id' => $user->id]);

        $policy = new PaymentMethodPolicy();
        $this->assertTrue($policy->view($user, $paymentMethod));
    }

    /**
     * Test PaymentMethodPolicy - user cannot view other's payment method
     */
    public function test_user_cannot_view_others_payment_method(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create(['user_id' => $otherUser->id]);

        $policy = new PaymentMethodPolicy();
        $this->assertFalse($policy->view($user, $paymentMethod));
    }

    /**
     * Test PaymentMethodPolicy - user can update own payment method
     */
    public function test_user_can_update_own_payment_method(): void
    {
        $user = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create(['user_id' => $user->id]);

        $policy = new PaymentMethodPolicy();
        $this->assertTrue($policy->update($user, $paymentMethod));
    }

    /**
     * Test PaymentMethodPolicy - user can delete own payment method
     */
    public function test_user_can_delete_own_payment_method(): void
    {
        $user = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create(['user_id' => $user->id]);

        $policy = new PaymentMethodPolicy();
        $this->assertTrue($policy->delete($user, $paymentMethod));
    }

    /**
     * Test PaymentMethodPolicy - user cannot delete other's payment method
     */
    public function test_user_cannot_delete_others_payment_method(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $paymentMethod = PaymentMethod::factory()->create(['user_id' => $otherUser->id]);

        $policy = new PaymentMethodPolicy();
        $this->assertFalse($policy->delete($user, $paymentMethod));
    }
}
