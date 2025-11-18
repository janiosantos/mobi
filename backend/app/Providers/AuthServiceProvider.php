<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;
use App\Models\Ride;
use App\Models\User;
use App\Models\DriverProfile;
use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Vehicle;
use App\Models\Message;
use App\Models\Rating;
use App\Policies\RidePolicy;
use App\Policies\UserPolicy;
use App\Policies\DriverProfilePolicy;
use App\Policies\PaymentMethodPolicy;
use App\Policies\VehiclePolicy;
use App\Policies\MessagePolicy;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Ride::class => RidePolicy::class,
        User::class => UserPolicy::class,
        DriverProfile::class => DriverProfilePolicy::class,
        PaymentMethod::class => PaymentMethodPolicy::class,
        Vehicle::class => VehiclePolicy::class,
        Message::class => MessagePolicy::class,
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        // Define a Super Admin gate
        Gate::before(function ($user, $ability) {
            return $user->hasRole('super_admin') ? true : null;
        });

        // Driver gates
        Gate::define('act-as-driver', function (User $user) {
            return $user->user_type === 'driver';
        });

        Gate::define('driver-is-approved', function (User $user) {
            return $user->user_type === 'driver'
                && $user->driverProfile
                && $user->driverProfile->status === 'approved';
        });

        Gate::define('driver-is-online', function (User $user) {
            return $user->user_type === 'driver'
                && $user->driverProfile
                && $user->driverProfile->is_online;
        });

        // Passenger gates
        Gate::define('act-as-passenger', function (User $user) {
            return $user->user_type === 'passenger';
        });

        // Admin gates
        Gate::define('access-admin', function (User $user) {
            return $user->hasRole(['super_admin', 'admin', 'moderator']);
        });
    }
}
