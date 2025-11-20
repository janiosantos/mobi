<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Requests\Driver\UpdateLocationRequest;
use App\Models\RideLocation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    /**
     * Update driver location
     *
     * @param UpdateLocationRequest $request
     * @return JsonResponse
     */
    public function update(UpdateLocationRequest $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        // Update driver profile location
        $driverProfile->update([
            'current_latitude' => $request->input('latitude'),
            'current_longitude' => $request->input('longitude'),
        ]);

        // If driver has active ride, also store location in ride_locations
        $activeRide = $user->ridesAsDriver()
            ->whereIn('status', ['accepted', 'driver_arrived', 'in_progress'])
            ->first();

        if ($activeRide) {
            RideLocation::create([
                'ride_id' => $activeRide->id,
                'latitude' => $request->input('latitude'),
                'longitude' => $request->input('longitude'),
                'recorded_at' => now(),
            ]);

            // Broadcast location to passenger
            broadcast(new \App\Events\DriverLocationUpdated($activeRide, [
                'latitude' => $request->input('latitude'),
                'longitude' => $request->input('longitude'),
            ]))->toOthers();
        }

        return response()->json([
            'success' => true,
            'message' => 'Location updated successfully',
            'data' => [
                'latitude' => $driverProfile->current_latitude,
                'longitude' => $driverProfile->current_longitude,
                'updated_at' => $driverProfile->updated_at,
                'active_ride_id' => $activeRide?->id,
            ],
        ]);
    }

    /**
     * Get current driver location
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function current(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        if (!$driverProfile->current_latitude || !$driverProfile->current_longitude) {
            return response()->json([
                'success' => false,
                'message' => 'Location not available',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Current location retrieved successfully',
            'data' => [
                'latitude' => $driverProfile->current_latitude,
                'longitude' => $driverProfile->current_longitude,
                'is_online' => $driverProfile->is_online,
                'last_updated' => $driverProfile->updated_at,
            ],
        ]);
    }
}
