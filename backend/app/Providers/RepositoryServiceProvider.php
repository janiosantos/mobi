<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        // Bind Repository Interfaces to Implementations
        $this->app->bind(
            \App\Repositories\Contracts\UserRepositoryInterface::class,
            \App\Repositories\UserRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\RideRepositoryInterface::class,
            \App\Repositories\RideRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\DriverRepositoryInterface::class,
            \App\Repositories\DriverRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\PaymentRepositoryInterface::class,
            \App\Repositories\PaymentRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\RatingRepositoryInterface::class,
            \App\Repositories\RatingRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\CouponRepositoryInterface::class,
            \App\Repositories\CouponRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\VehicleCategoryRepositoryInterface::class,
            \App\Repositories\VehicleCategoryRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\NotificationRepositoryInterface::class,
            \App\Repositories\NotificationRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\MessageRepositoryInterface::class,
            \App\Repositories\MessageRepository::class
        );
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
