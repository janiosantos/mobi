<?php

use App\Models\Ride;
use Illuminate\Support\Facades\Broadcast;

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

// User's private channel
Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});

// Ride's private channel
Broadcast::channel('ride.{rideId}', function ($user, $rideId) {
    $ride = Ride::find($rideId);

    if (!$ride) {
        return false;
    }

    // Allow passenger and driver to listen
    return (int) $user->id === (int) $ride->passenger_id
        || (int) $user->id === (int) $ride->driver_id;
});

// Driver's presence channel (online drivers)
Broadcast::channel('drivers-online', function ($user) {
    if ($user->user_type !== 'driver') {
        return false;
    }

    return [
        'id' => $user->id,
        'name' => $user->name,
        'latitude' => $user->current_latitude,
        'longitude' => $user->current_longitude,
    ];
});
