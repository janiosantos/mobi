<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Auth\PasswordResetController;
use App\Http\Controllers\Api\V1\Passenger\RideController;
use App\Http\Controllers\Api\V1\Passenger\PaymentMethodController;
use App\Http\Controllers\Api\V1\Passenger\CouponController;
use App\Http\Controllers\Api\V1\Passenger\RatingController as PassengerRatingController;
use App\Http\Controllers\Api\V1\Driver\DriverRideController;
use App\Http\Controllers\Api\V1\Driver\DriverController;
use App\Http\Controllers\Api\V1\Driver\DocumentController;
use App\Http\Controllers\Api\V1\Driver\EarningController;
use App\Http\Controllers\Api\V1\Driver\LocationController;
use App\Http\Controllers\Api\V1\Driver\RatingController as DriverRatingController;
use App\Http\Controllers\Api\V1\ChatController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ProfileController;

/*
|--------------------------------------------------------------------------
| API Routes - Version 1
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    /*
    |--------------------------------------------------------------------------
    | Authentication Routes (Public)
    |--------------------------------------------------------------------------
    */
    Route::prefix('auth')->group(function () {
        // Registration
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/register/driver', [AuthController::class, 'registerDriver']);

        // Login
        Route::post('/login', [AuthController::class, 'login']);

        // Password Reset
        Route::post('/forgot-password', [PasswordResetController::class, 'sendResetLink']);
        Route::post('/reset-password', [PasswordResetController::class, 'reset']);

        // Protected Auth Routes
        Route::middleware('auth:sanctum')->group(function () {
            Route::get('/me', [AuthController::class, 'me']);
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::post('/refresh', [AuthController::class, 'refresh']);
            Route::delete('/account', [AuthController::class, 'deleteAccount']);
        });
    });

    /*
    |--------------------------------------------------------------------------
    | Protected Routes (Requires Authentication)
    |--------------------------------------------------------------------------
    */
    Route::middleware('auth:sanctum')->group(function () {

        // Profile Management
        Route::prefix('profile')->group(function () {
            Route::get('/', [ProfileController::class, 'show']);
            Route::put('/', [ProfileController::class, 'update']);
            Route::post('/photo', [ProfileController::class, 'updatePhoto']);
            Route::delete('/photo', [ProfileController::class, 'deletePhoto']);
        });

        // Notifications
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::get('/{id}', [NotificationController::class, 'show']);
            Route::post('/{id}/read', [NotificationController::class, 'markAsRead']);
            Route::post('/read-all', [NotificationController::class, 'markAllAsRead']);
            Route::delete('/{id}', [NotificationController::class, 'destroy']);
        });

        // Chat (Shared between Passenger and Driver)
        Route::prefix('chat')->group(function () {
            Route::get('/rides/{ride}/messages', [ChatController::class, 'index']);
            Route::post('/rides/{ride}/messages', [ChatController::class, 'store']);
            Route::post('/messages/{message}/read', [ChatController::class, 'markAsRead']);
        });

        /*
        |--------------------------------------------------------------------------
        | Passenger Routes
        |--------------------------------------------------------------------------
        */
        Route::middleware('passenger')->prefix('passenger')->group(function () {

            // Rides
            Route::prefix('rides')->group(function () {
                Route::post('/estimate', [RideController::class, 'estimate']);
                Route::post('/', [RideController::class, 'store']);
                Route::get('/', [RideController::class, 'index']);
                Route::get('/active', [RideController::class, 'active']);
                Route::get('/{ride}', [RideController::class, 'show']);
                Route::post('/{ride}/cancel', [RideController::class, 'cancel']);
                Route::get('/{ride}/track', [RideController::class, 'track']);
            });

            // Payment Methods
            Route::prefix('payment-methods')->group(function () {
                Route::get('/', [PaymentMethodController::class, 'index']);
                Route::post('/', [PaymentMethodController::class, 'store']);
                Route::get('/{paymentMethod}', [PaymentMethodController::class, 'show']);
                Route::put('/{paymentMethod}', [PaymentMethodController::class, 'update']);
                Route::delete('/{paymentMethod}', [PaymentMethodController::class, 'destroy']);
                Route::post('/{paymentMethod}/set-default', [PaymentMethodController::class, 'setDefault']);
            });

            // Coupons
            Route::prefix('coupons')->group(function () {
                Route::get('/', [CouponController::class, 'index']);
                Route::post('/validate', [CouponController::class, 'validate']);
            });

            // Ratings (as Passenger)
            Route::prefix('ratings')->group(function () {
                Route::post('/rides/{ride}', [PassengerRatingController::class, 'store']);
                Route::get('/', [PassengerRatingController::class, 'index']);
            });
        });

        /*
        |--------------------------------------------------------------------------
        | Driver Routes
        |--------------------------------------------------------------------------
        */
        Route::middleware('driver')->prefix('driver')->group(function () {

            // Driver Profile
            Route::get('/profile', [DriverController::class, 'profile']);
            Route::put('/profile', [DriverController::class, 'updateProfile']);

            // Online/Offline Status
            Route::post('/online', [DriverController::class, 'goOnline']);
            Route::post('/offline', [DriverController::class, 'goOffline']);
            Route::get('/status', [DriverController::class, 'status']);

            // Document Management
            Route::prefix('documents')->group(function () {
                Route::get('/', [DocumentController::class, 'index']);
                Route::post('/', [DocumentController::class, 'upload']);
                Route::get('/{document}', [DocumentController::class, 'show']);
                Route::delete('/{document}', [DocumentController::class, 'destroy']);
                Route::get('/status', [DocumentController::class, 'status']);
            });

            // Location Updates
            Route::prefix('location')->group(function () {
                Route::post('/', [LocationController::class, 'update'])
                    ->middleware('throttle:driver_location');
                Route::get('/', [LocationController::class, 'current']);
            });

            // Ride Management (Requires Approved Driver)
            Route::middleware('driver.approved')->prefix('rides')->group(function () {
                // Available rides
                Route::get('/available', [DriverRideController::class, 'available']);

                // Current/Active rides
                Route::get('/current', [DriverRideController::class, 'current']);
                Route::get('/active', [DriverRideController::class, 'active']);

                // History
                Route::get('/', [DriverRideController::class, 'index']);
                Route::get('/{ride}', [DriverRideController::class, 'show']);

                // Ride Actions
                Route::post('/{ride}/accept', [DriverRideController::class, 'accept']);
                Route::post('/{ride}/reject', [DriverRideController::class, 'reject']);
                Route::post('/{ride}/arrive', [DriverRideController::class, 'arrive']);
                Route::post('/{ride}/start', [DriverRideController::class, 'start']);
                Route::post('/{ride}/complete', [DriverRideController::class, 'complete']);
                Route::post('/{ride}/cancel', [DriverRideController::class, 'cancel']);
            });

            // Earnings
            Route::prefix('earnings')->group(function () {
                Route::get('/', [EarningController::class, 'index']);
                Route::get('/summary', [EarningController::class, 'summary']);
                Route::get('/daily', [EarningController::class, 'daily']);
                Route::get('/weekly', [EarningController::class, 'weekly']);
                Route::get('/monthly', [EarningController::class, 'monthly']);
                Route::post('/withdraw', [EarningController::class, 'withdraw']);
            });

            // Ratings (as Driver)
            Route::prefix('ratings')->group(function () {
                Route::post('/rides/{ride}', [DriverRatingController::class, 'store']);
                Route::get('/', [DriverRatingController::class, 'index']);
                Route::get('/summary', [DriverRatingController::class, 'summary']);
            });
        });
    });

    /*
    |--------------------------------------------------------------------------
    | Webhooks (Public but should be validated)
    |--------------------------------------------------------------------------
    */
    Route::prefix('webhooks')->group(function () {
        Route::post('/mercadopago', [\App\Http\Controllers\Api\V1\WebhookController::class, 'mercadopago']);
        Route::post('/notifications', [\App\Http\Controllers\Api\V1\WebhookController::class, 'notifications']);
    });
});
