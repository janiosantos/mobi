<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\User;
use App\Models\Ride;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
|
| Here you may register all of the event broadcasting channels that your
| application supports. The given channel authorization callbacks are
| used to check if an authenticated user can listen to the channel.
|
*/

// User private channel
Broadcast::channel('user.{userId}', function (User $user, int $userId) {
    return (int) $user->id === (int) $userId;
});

// Driver channel
Broadcast::channel('driver.{driverId}', function (User $user, int $driverId) {
    return $user->user_type === 'driver' && (int) $user->id === (int) $driverId;
});

// Ride channel (accessible by passenger and driver)
Broadcast::channel('ride.{rideId}', function (User $user, int $rideId) {
    $ride = Ride::find($rideId);

    if (!$ride) {
        return false;
    }

    return (int) $user->id === (int) $ride->passenger_id
        || (int) $user->id === (int) $ride->driver_id;
});

// Chat channel (accessible by passenger and driver of the ride)
Broadcast::channel('chat.{rideId}', function (User $user, int $rideId) {
    $ride = Ride::find($rideId);

    if (!$ride) {
        return false;
    }

    return (int) $user->id === (int) $ride->passenger_id
        || (int) $user->id === (int) $ride->driver_id;
});

// Available rides channel (for drivers in specific area)
Broadcast::channel('available-rides', function (User $user) {
    return $user->user_type === 'driver'
        && $user->driverProfile
        && $user->driverProfile->status === 'approved';
});

// Admin monitoring channel
Broadcast::channel('admin', function (User $user) {
    return $user->hasRole(['super_admin', 'admin']);
});

// Presence channel for online drivers (for admin dashboard)
Broadcast::channel('online-drivers', function (User $user) {
    if ($user->user_type === 'driver' && $user->driverProfile && $user->driverProfile->is_online) {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'latitude' => $user->driverProfile->current_latitude,
            'longitude' => $user->driverProfile->current_longitude,
        ];
    }
    return false;
});
