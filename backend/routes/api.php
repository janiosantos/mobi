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
        Route::prefix('rides/{ride}')->group(function () {
            Route::get('/messages', [\App\Http\Controllers\ChatController::class, 'index']);
            Route::post('/messages', [\App\Http\Controllers\ChatController::class, 'store']);
            Route::put('/messages/{message}/read', [\App\Http\Controllers\ChatController::class, 'markAsRead']);
            Route::put('/messages/read-all', [\App\Http\Controllers\ChatController::class, 'markAllAsRead']);
            Route::get('/messages/unread-count', [\App\Http\Controllers\ChatController::class, 'unreadCount']);
        });

        // Shared Rides (Carpooling)
        Route::prefix('shared-rides')->group(function () {
            Route::get('/search', [\App\Http\Controllers\SharedRideController::class, 'search']);
            Route::post('/', [\App\Http\Controllers\SharedRideController::class, 'store']);
            Route::get('/{sharedRide}', [\App\Http\Controllers\SharedRideController::class, 'show']);
            Route::post('/{sharedRide}/join', [\App\Http\Controllers\SharedRideController::class, 'join']);
            Route::post('/{sharedRide}/leave', [\App\Http\Controllers\SharedRideController::class, 'leave']);
            Route::post('/{sharedRide}/cancel', [\App\Http\Controllers\SharedRideController::class, 'cancel']);
            Route::post('/{sharedRide}/start', [\App\Http\Controllers\SharedRideController::class, 'start']);
            Route::post('/{sharedRide}/passengers/{passenger}/pickup', [\App\Http\Controllers\SharedRideController::class, 'pickupPassenger']);
            Route::post('/{sharedRide}/passengers/{passenger}/dropoff', [\App\Http\Controllers\SharedRideController::class, 'dropoffPassenger']);
            Route::get('/my-rides/driver', [\App\Http\Controllers\SharedRideController::class, 'myRidesAsDriver']);
            Route::get('/my-rides/passenger', [\App\Http\Controllers\SharedRideController::class, 'myRidesAsPassenger']);
        });

        // Saved Places / Favorites
        Route::prefix('saved-places')->group(function () {
            Route::get('/', [\App\Http\Controllers\SavedPlaceController::class, 'index']);
            Route::post('/', [\App\Http\Controllers\SavedPlaceController::class, 'store']);
            Route::get('/type/{type}', [\App\Http\Controllers\SavedPlaceController::class, 'byType']);
            Route::get('/{savedPlace}', [\App\Http\Controllers\SavedPlaceController::class, 'show']);
            Route::put('/{savedPlace}', [\App\Http\Controllers\SavedPlaceController::class, 'update']);
            Route::delete('/{savedPlace}', [\App\Http\Controllers\SavedPlaceController::class, 'destroy']);
            Route::post('/{savedPlace}/set-default', [\App\Http\Controllers\SavedPlaceController::class, 'setAsDefault']);
        });

        // Tips
        Route::prefix('rides/{ride}/tip')->group(function () {
            Route::post('/', [\App\Http\Controllers\TipController::class, 'addTip']);
            Route::get('/suggestions', [\App\Http\Controllers\TipController::class, 'getSuggestions']);
        });

        // Emergency Contacts
        Route::prefix('emergency-contacts')->group(function () {
            Route::get('/', [\App\Http\Controllers\EmergencyContactController::class, 'index']);
            Route::post('/', [\App\Http\Controllers\EmergencyContactController::class, 'store']);
            Route::put('/{contact}', [\App\Http\Controllers\EmergencyContactController::class, 'update']);
            Route::delete('/{contact}', [\App\Http\Controllers\EmergencyContactController::class, 'destroy']);
        });

        // Safety Features
        Route::prefix('rides/{ride}')->group(function () {
            Route::post('/share', [\App\Http\Controllers\SafetyController::class, 'shareTrip']);
            Route::post('/sos', [\App\Http\Controllers\SafetyController::class, 'triggerSOS']);
            Route::delete('/sos', [\App\Http\Controllers\SafetyController::class, 'cancelSOS']);

            // Multiple Stops
            Route::prefix('stops')->group(function () {
                Route::get('/', [\App\Http\Controllers\RideStopController::class, 'index']);
                Route::post('/', [\App\Http\Controllers\RideStopController::class, 'store']);
                Route::put('/{stop}', [\App\Http\Controllers\RideStopController::class, 'update']);
                Route::delete('/{stop}', [\App\Http\Controllers\RideStopController::class, 'destroy']);
                Route::post('/{stop}/arrive', [\App\Http\Controllers\RideStopController::class, 'arrive']);
                Route::post('/{stop}/depart', [\App\Http\Controllers\RideStopController::class, 'depart']);
            });
        });

        // Vehicle Categories
        Route::prefix('vehicle-categories')->group(function () {
            Route::get('/', [\App\Http\Controllers\VehicleCategoryController::class, 'index']);
            Route::get('/{slug}', [\App\Http\Controllers\VehicleCategoryController::class, 'show']);
            Route::post('/{slug}/estimate', [\App\Http\Controllers\VehicleCategoryController::class, 'estimatePrice']);
            Route::post('/compare-price', [\App\Http\Controllers\VehicleCategoryController::class, 'comparePrice']);
        });

        // Scheduled Rides
        Route::prefix('scheduled-rides')->group(function () {
            Route::post('/', [\App\Http\Controllers\ScheduledRideController::class, 'schedule']);
            Route::get('/', [\App\Http\Controllers\ScheduledRideController::class, 'index']);
            Route::get('/upcoming', [\App\Http\Controllers\ScheduledRideController::class, 'upcoming']);
            Route::put('/{ride}', [\App\Http\Controllers\ScheduledRideController::class, 'update']);
            Route::post('/{ride}/cancel', [\App\Http\Controllers\ScheduledRideController::class, 'cancel']);
        });

        // Split Fare (Split Payment)
        Route::prefix('split-fare')->group(function () {
            Route::post('/rides/{ride}', [\App\Http\Controllers\SplitFareController::class, 'create']);
            Route::get('/rides/{ride}', [\App\Http\Controllers\SplitFareController::class, 'index']);
            Route::get('/invitations', [\App\Http\Controllers\SplitFareController::class, 'myInvitations']);
            Route::get('/{inviteCode}', [\App\Http\Controllers\SplitFareController::class, 'show']);
            Route::post('/{inviteCode}/accept', [\App\Http\Controllers\SplitFareController::class, 'accept']);
            Route::post('/{inviteCode}/decline', [\App\Http\Controllers\SplitFareController::class, 'decline']);
            Route::post('/{inviteCode}/pay', [\App\Http\Controllers\SplitFareController::class, 'pay']);
        });

        // Referral System
        Route::prefix('referrals')->group(function () {
            Route::get('/me', [\App\Http\Controllers\ReferralController::class, 'me']);
            Route::get('/', [\App\Http\Controllers\ReferralController::class, 'index']);
            Route::post('/invite', [\App\Http\Controllers\ReferralController::class, 'invite']);
            Route::post('/apply', [\App\Http\Controllers\ReferralController::class, 'apply']);
            Route::get('/leaderboard', [\App\Http\Controllers\ReferralController::class, 'leaderboard']);
            Route::get('/{code}', [\App\Http\Controllers\ReferralController::class, 'show']);
        });

        // Reports & Insights
        Route::prefix('reports')->group(function () {
            Route::get('/rides', [\App\Http\Controllers\ReportController::class, 'rideHistory']);
            Route::get('/spending', [\App\Http\Controllers\ReportController::class, 'spendingSummary']);
            Route::get('/earnings', [\App\Http\Controllers\ReportController::class, 'earningsSummary']);
            Route::get('/stats', [\App\Http\Controllers\ReportController::class, 'userStats']);
            Route::get('/export', [\App\Http\Controllers\ReportController::class, 'export']);
        });

        // SOS Emergency System
        Route::prefix('sos')->group(function () {
            Route::post('/activate', [\App\Http\Controllers\SOSController::class, 'activate']);
            Route::post('/deactivate', [\App\Http\Controllers\SOSController::class, 'deactivate']);
            Route::post('/update-location', [\App\Http\Controllers\SOSController::class, 'updateLocation']);
            Route::post('/heartbeat', [\App\Http\Controllers\SOSController::class, 'heartbeat']);
            Route::get('/tracking-link', [\App\Http\Controllers\SOSController::class, 'getTrackingLink']);
            Route::post('/alert-monitoring', [\App\Http\Controllers\SOSController::class, 'alertMonitoringCenter']);
            Route::post('/start-recording', [\App\Http\Controllers\SOSController::class, 'startAudioRecording']);
            Route::post('/share-location', [\App\Http\Controllers\SOSController::class, 'shareLocation']);
            Route::get('/nearest-services', [\App\Http\Controllers\SOSController::class, 'getNearestEmergencyServices']);
            Route::get('/active', [\App\Http\Controllers\SOSController::class, 'getActive']);
            Route::get('/history', [\App\Http\Controllers\SOSController::class, 'getHistory']);
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
    | Public Routes
    |--------------------------------------------------------------------------
    */
    // Shared Trip View (Public - no auth required)
    Route::get('/shared-trip/{code}', [\App\Http\Controllers\SafetyController::class, 'getSharedTrip']);

    // SOS Tracking (Public - no auth required)
    Route::get('/track-sos/{trackingCode}', [\App\Http\Controllers\SOSController::class, 'track']);

    /*
    |--------------------------------------------------------------------------
    | Webhooks (Public but should be validated)
    |--------------------------------------------------------------------------
    */
    Route::prefix('webhooks')->group(function () {
        Route::post('/mercadopago', [\App\Http\Controllers\Api\V1\WebhookController::class, 'mercadopago']);
        Route::post('/notifications', [\App\Http\Controllers\Api\V1\WebhookController::class, 'notifications']);

        // Payment Gateway Webhooks
        Route::post('/efi', [\App\Http\Controllers\PaymentWebhookController::class, 'efi']);
        Route::post('/stone', [\App\Http\Controllers\PaymentWebhookController::class, 'stone']);
        Route::post('/pagseguro', [\App\Http\Controllers\PaymentWebhookController::class, 'pagseguro']);
        Route::post('/cielo', [\App\Http\Controllers\PaymentWebhookController::class, 'cielo']);
    });
});
