<?php

namespace App\Http\Controllers;

use App\Models\SharedRide;
use App\Models\SharedRidePassenger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SharedRideController extends Controller
{
    /**
     * Search for available shared rides.
     */
    public function search(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'pickup_latitude' => 'required|numeric|between:-90,90',
            'pickup_longitude' => 'required|numeric|between:-180,180',
            'dropoff_latitude' => 'required|numeric|between:-90,90',
            'dropoff_longitude' => 'required|numeric|between:-180,180',
            'departure_time' => 'date',
            'limit' => 'integer|min:1|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = SharedRide::query()
            ->with(['driver:id,name,photo_url,rating', 'vehicle'])
            ->scheduled()
            ->withAvailableSeats()
            ->searchByRoute(
                $request->input('pickup_latitude'),
                $request->input('pickup_longitude'),
                $request->input('dropoff_latitude'),
                $request->input('dropoff_longitude')
            );

        if ($request->has('departure_time')) {
            $departureTime = \Carbon\Carbon::parse($request->input('departure_time'));
            $query->whereBetween('departure_time', [
                $departureTime->copy()->subHours(2),
                $departureTime->copy()->addHours(2),
            ]);
        }

        $limit = $request->input('limit', 20);
        $rides = $query->limit($limit)->get();

        return response()->json([
            'data' => $rides
        ]);
    }

    /**
     * Create a new shared ride.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'pickup_latitude' => 'required|numeric|between:-90,90',
            'pickup_longitude' => 'required|numeric|between:-180,180',
            'pickup_address' => 'required|string|max:255',
            'dropoff_latitude' => 'required|numeric|between:-90,90',
            'dropoff_longitude' => 'required|numeric|between:-180,180',
            'dropoff_address' => 'required|string|max:255',
            'departure_time' => 'required|date|after:now',
            'max_passengers' => 'required|integer|min:1|max:7',
            'price_per_seat' => 'required|numeric|min:1',
            'vehicle_id' => 'exists:vehicles,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Verify user is a driver
        if ($user->role !== 'driver') {
            return response()->json([
                'message' => 'Only drivers can create shared rides'
            ], 403);
        }

        $sharedRide = SharedRide::create([
            'driver_id' => $user->id,
            'vehicle_id' => $request->input('vehicle_id'),
            'pickup_latitude' => $request->input('pickup_latitude'),
            'pickup_longitude' => $request->input('pickup_longitude'),
            'pickup_address' => $request->input('pickup_address'),
            'dropoff_latitude' => $request->input('dropoff_latitude'),
            'dropoff_longitude' => $request->input('dropoff_longitude'),
            'dropoff_address' => $request->input('dropoff_address'),
            'departure_time' => $request->input('departure_time'),
            'max_passengers' => $request->input('max_passengers'),
            'price_per_seat' => $request->input('price_per_seat'),
            'status' => 'scheduled',
        ]);

        $sharedRide->load(['driver', 'vehicle', 'passengers']);

        return response()->json([
            'data' => $sharedRide
        ], 201);
    }

    /**
     * Get shared ride details.
     */
    public function show(SharedRide $sharedRide): JsonResponse
    {
        $sharedRide->load(['driver:id,name,photo_url,rating', 'vehicle', 'passengers.passenger:id,name,photo_url']);

        return response()->json([
            'data' => $sharedRide
        ]);
    }

    /**
     * Join a shared ride.
     */
    public function join(Request $request, SharedRide $sharedRide): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'pickup_latitude' => 'required|numeric|between:-90,90',
            'pickup_longitude' => 'required|numeric|between:-180,180',
            'pickup_address' => 'required|string|max:255',
            'dropoff_latitude' => 'required|numeric|between:-90,90',
            'dropoff_longitude' => 'required|numeric|between:-180,180',
            'dropoff_address' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check if ride is available
        if (!$sharedRide->has_available_seats) {
            return response()->json([
                'message' => 'No available seats'
            ], 400);
        }

        // Check if user is already in this ride
        $existingPassenger = SharedRidePassenger::where('shared_ride_id', $sharedRide->id)
            ->where('passenger_id', $user->id)
            ->first();

        if ($existingPassenger) {
            return response()->json([
                'message' => 'Already joined this ride'
            ], 400);
        }

        DB::beginTransaction();
        try {
            $passenger = SharedRidePassenger::create([
                'shared_ride_id' => $sharedRide->id,
                'passenger_id' => $user->id,
                'pickup_latitude' => $request->input('pickup_latitude'),
                'pickup_longitude' => $request->input('pickup_longitude'),
                'pickup_address' => $request->input('pickup_address'),
                'dropoff_latitude' => $request->input('dropoff_latitude'),
                'dropoff_longitude' => $request->input('dropoff_longitude'),
                'dropoff_address' => $request->input('dropoff_address'),
                'price' => $sharedRide->price_per_seat,
                'status' => 'confirmed',
            ]);

            $sharedRide->updatePassengerCount();

            DB::commit();

            $passenger->load('passenger:id,name,photo_url');

            return response()->json([
                'data' => $passenger
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to join ride: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Leave a shared ride.
     */
    public function leave(Request $request, SharedRide $sharedRide): JsonResponse
    {
        $user = $request->user();

        $passenger = SharedRidePassenger::where('shared_ride_id', $sharedRide->id)
            ->where('passenger_id', $user->id)
            ->whereIn('status', ['confirmed', 'pending'])
            ->first();

        if (!$passenger) {
            return response()->json([
                'message' => 'Not found in this ride'
            ], 404);
        }

        $passenger->cancel();

        return response()->json([
            'message' => 'Left ride successfully'
        ]);
    }

    /**
     * Cancel shared ride (driver only).
     */
    public function cancel(Request $request, SharedRide $sharedRide): JsonResponse
    {
        $user = $request->user();

        if ($sharedRide->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $sharedRide->update(['status' => 'cancelled']);

        return response()->json([
            'message' => 'Ride cancelled successfully'
        ]);
    }

    /**
     * Start shared ride (driver only).
     */
    public function start(Request $request, SharedRide $sharedRide): JsonResponse
    {
        $user = $request->user();

        if ($sharedRide->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        if ($sharedRide->status !== 'scheduled') {
            return response()->json([
                'message' => 'Ride cannot be started'
            ], 400);
        }

        $sharedRide->update(['status' => 'in_progress']);
        $sharedRide->load(['driver', 'vehicle', 'passengers.passenger']);

        return response()->json([
            'data' => $sharedRide
        ]);
    }

    /**
     * Mark passenger as picked up.
     */
    public function pickupPassenger(Request $request, SharedRide $sharedRide, SharedRidePassenger $passenger): JsonResponse
    {
        $user = $request->user();

        if ($sharedRide->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        if ($passenger->shared_ride_id !== $sharedRide->id) {
            return response()->json([
                'message' => 'Passenger not found'
            ], 404);
        }

        $passenger->markAsPickedUp();

        return response()->json([
            'message' => 'Passenger picked up'
        ]);
    }

    /**
     * Mark passenger as dropped off.
     */
    public function dropoffPassenger(Request $request, SharedRide $sharedRide, SharedRidePassenger $passenger): JsonResponse
    {
        $user = $request->user();

        if ($sharedRide->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        if ($passenger->shared_ride_id !== $sharedRide->id) {
            return response()->json([
                'message' => 'Passenger not found'
            ], 404);
        }

        $passenger->markAsDroppedOff();

        return response()->json([
            'message' => 'Passenger dropped off'
        ]);
    }

    /**
     * Get my shared rides as driver.
     */
    public function myRidesAsDriver(Request $request): JsonResponse
    {
        $user = $request->user();

        $rides = SharedRide::where('driver_id', $user->id)
            ->with(['passengers.passenger:id,name,photo_url'])
            ->orderBy('departure_time', 'desc')
            ->get();

        return response()->json([
            'data' => $rides
        ]);
    }

    /**
     * Get my shared rides as passenger.
     */
    public function myRidesAsPassenger(Request $request): JsonResponse
    {
        $user = $request->user();

        $rides = SharedRide::whereHas('passengers', function ($query) use ($user) {
            $query->where('passenger_id', $user->id);
        })
            ->with(['driver:id,name,photo_url,rating', 'vehicle', 'passengers.passenger:id,name,photo_url'])
            ->orderBy('departure_time', 'desc')
            ->get();

        return response()->json([
            'data' => $rides
        ]);
    }
}
