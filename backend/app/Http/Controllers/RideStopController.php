<?php

namespace App\Http\Controllers;

use App\Models\Ride;
use App\Models\RideStop;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RideStopController extends Controller
{
    const MAX_STOPS = 3;
    const PRICE_PER_STOP = 5.00; // Additional R$5 per stop

    /**
     * Get all stops for a ride.
     */
    public function index(Request $request, Ride $ride): JsonResponse
    {
        // Verify user is the passenger or driver
        if ($ride->passenger_id !== $request->user()->id &&
            $ride->driver_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $stops = $ride->stops()->get();

        return response()->json([
            'data' => $stops
        ]);
    }

    /**
     * Add a stop to a ride.
     */
    public function store(Request $request, Ride $ride): JsonResponse
    {
        // Only passenger can add stops
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Can only add stops before ride is accepted
        if (!in_array($ride->status, ['requested', 'searching'])) {
            return response()->json([
                'message' => 'Cannot add stops after ride is accepted'
            ], 400);
        }

        // Check max stops limit
        if ($ride->stops_count >= self::MAX_STOPS) {
            return response()->json([
                'message' => 'Maximum number of stops reached (3)'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'address' => 'required|string|max:255',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'wait_time_minutes' => 'integer|min:1|max:15',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Get next stop number
        $stopNumber = $ride->stops_count + 1;

        $stop = RideStop::create([
            'ride_id' => $ride->id,
            'stop_number' => $stopNumber,
            'address' => $request->input('address'),
            'latitude' => $request->input('latitude'),
            'longitude' => $request->input('longitude'),
            'wait_time_minutes' => $request->input('wait_time_minutes', 3),
        ]);

        // Update ride
        $ride->update([
            'has_stops' => true,
            'stops_count' => $stopNumber,
        ]);

        // Recalculate price
        $this->recalculatePrice($ride);

        return response()->json([
            'data' => $stop,
            'ride' => [
                'id' => $ride->id,
                'stops_count' => $ride->stops_count,
                'estimated_price' => $ride->estimated_price,
            ],
            'message' => 'Stop added successfully'
        ], 201);
    }

    /**
     * Update a stop.
     */
    public function update(Request $request, Ride $ride, RideStop $stop): JsonResponse
    {
        // Verify stop belongs to ride
        if ($stop->ride_id !== $ride->id) {
            return response()->json([
                'message' => 'Stop does not belong to this ride'
            ], 404);
        }

        // Only passenger can update stops
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Can only update stops before ride starts
        if (!in_array($ride->status, ['requested', 'searching', 'accepted', 'driver_arrived'])) {
            return response()->json([
                'message' => 'Cannot update stops after ride has started'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'address' => 'string|max:255',
            'latitude' => 'numeric|between:-90,90',
            'longitude' => 'numeric|between:-180,180',
            'wait_time_minutes' => 'integer|min:1|max:15',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $stop->update($request->only([
            'address',
            'latitude',
            'longitude',
            'wait_time_minutes',
        ]));

        return response()->json([
            'data' => $stop->fresh(),
            'message' => 'Stop updated successfully'
        ]);
    }

    /**
     * Remove a stop from a ride.
     */
    public function destroy(Request $request, Ride $ride, RideStop $stop): JsonResponse
    {
        // Verify stop belongs to ride
        if ($stop->ride_id !== $ride->id) {
            return response()->json([
                'message' => 'Stop does not belong to this ride'
            ], 404);
        }

        // Only passenger can remove stops
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Can only remove stops before ride is accepted
        if (!in_array($ride->status, ['requested', 'searching'])) {
            return response()->json([
                'message' => 'Cannot remove stops after ride is accepted'
            ], 400);
        }

        $deletedStopNumber = $stop->stop_number;
        $stop->delete();

        // Renumber remaining stops
        RideStop::where('ride_id', $ride->id)
            ->where('stop_number', '>', $deletedStopNumber)
            ->decrement('stop_number');

        // Update ride
        $newStopsCount = $ride->stops()->count();
        $ride->update([
            'has_stops' => $newStopsCount > 0,
            'stops_count' => $newStopsCount,
        ]);

        // Recalculate price
        $this->recalculatePrice($ride);

        return response()->json([
            'message' => 'Stop removed successfully',
            'ride' => [
                'id' => $ride->id,
                'stops_count' => $ride->stops_count,
                'estimated_price' => $ride->estimated_price,
            ]
        ]);
    }

    /**
     * Mark driver arrival at a stop.
     */
    public function arrive(Request $request, Ride $ride, RideStop $stop): JsonResponse
    {
        // Verify stop belongs to ride
        if ($stop->ride_id !== $ride->id) {
            return response()->json([
                'message' => 'Stop does not belong to this ride'
            ], 404);
        }

        // Only driver can mark arrival
        if ($ride->driver_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Must be in progress
        if ($ride->status !== 'in_progress') {
            return response()->json([
                'message' => 'Ride must be in progress'
            ], 400);
        }

        if ($stop->hasArrived()) {
            return response()->json([
                'message' => 'Already arrived at this stop'
            ], 400);
        }

        $stop->update([
            'arrived_at' => now(),
        ]);

        return response()->json([
            'data' => $stop->fresh(),
            'message' => 'Arrival marked successfully'
        ]);
    }

    /**
     * Mark driver departure from a stop.
     */
    public function depart(Request $request, Ride $ride, RideStop $stop): JsonResponse
    {
        // Verify stop belongs to ride
        if ($stop->ride_id !== $ride->id) {
            return response()->json([
                'message' => 'Stop does not belong to this ride'
            ], 404);
        }

        // Only driver can mark departure
        if ($ride->driver_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Must be in progress
        if ($ride->status !== 'in_progress') {
            return response()->json([
                'message' => 'Ride must be in progress'
            ], 400);
        }

        if (!$stop->hasArrived()) {
            return response()->json([
                'message' => 'Must arrive at stop before departing'
            ], 400);
        }

        if ($stop->hasDeparted()) {
            return response()->json([
                'message' => 'Already departed from this stop'
            ], 400);
        }

        $stop->update([
            'departed_at' => now(),
        ]);

        return response()->json([
            'data' => $stop->fresh(),
            'message' => 'Departure marked successfully'
        ]);
    }

    /**
     * Recalculate ride price based on stops.
     */
    private function recalculatePrice(Ride $ride): void
    {
        $stopsCount = $ride->stops_count;
        $additionalCost = $stopsCount * self::PRICE_PER_STOP;

        // Add to estimated price
        $basePrice = $ride->estimated_price - ($ride->stops_count * self::PRICE_PER_STOP);
        $newPrice = $basePrice + $additionalCost;

        $ride->update([
            'estimated_price' => $newPrice,
        ]);
    }
}
