<?php

namespace App\Http\Controllers;

use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ScheduledRideController extends Controller
{
    /**
     * Schedule a new ride.
     */
    public function schedule(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'scheduled_at' => 'required|date|after:30 minutes|before:30 days',
            'vehicle_category_id' => 'required|exists:vehicle_categories,id',
            'pickup_latitude' => 'required|numeric|between:-90,90',
            'pickup_longitude' => 'required|numeric|between:-180,180',
            'pickup_address' => 'required|string',
            'dropoff_latitude' => 'required|numeric|between:-90,90',
            'dropoff_longitude' => 'required|numeric|between:-180,180',
            'dropoff_address' => 'required|string',
            'passenger_notes' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $scheduledAt = \Carbon\Carbon::parse($request->input('scheduled_at'));

        // Create 15-minute pickup window
        $pickupWindowStart = $scheduledAt->copy()->subMinutes(5);
        $pickupWindowEnd = $scheduledAt->copy()->addMinutes(10);

        $ride = Ride::create([
            'ride_number' => 'RIDE-' . strtoupper(Str::random(8)),
            'passenger_id' => $request->user()->id,
            'vehicle_category_id' => $request->input('vehicle_category_id'),
            'pickup_latitude' => $request->input('pickup_latitude'),
            'pickup_longitude' => $request->input('pickup_longitude'),
            'pickup_address' => $request->input('pickup_address'),
            'dropoff_latitude' => $request->input('dropoff_latitude'),
            'dropoff_longitude' => $request->input('dropoff_longitude'),
            'dropoff_address' => $request->input('dropoff_address'),
            'passenger_notes' => $request->input('passenger_notes'),
            'is_scheduled' => true,
            'scheduled_at' => $scheduledAt,
            'scheduled_pickup_window_start' => $pickupWindowStart,
            'scheduled_pickup_window_end' => $pickupWindowEnd,
            'scheduled_status' => 'pending',
            'status' => 'scheduled',
            'payment_status' => 'pending',
        ]);

        return response()->json([
            'data' => $ride,
            'message' => 'Ride scheduled successfully'
        ], 201);
    }

    /**
     * Get upcoming scheduled rides for the authenticated user.
     */
    public function upcoming(Request $request): JsonResponse
    {
        $rides = Ride::where('passenger_id', $request->user()->id)
            ->upcoming()
            ->with(['category', 'stops'])
            ->get();

        return response()->json([
            'data' => $rides
        ]);
    }

    /**
     * Get all scheduled rides for the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Ride::where('passenger_id', $request->user()->id)
            ->scheduled()
            ->with(['category', 'stops']);

        // Filter by status
        if ($request->has('scheduled_status')) {
            $query->where('scheduled_status', $request->input('scheduled_status'));
        }

        $rides = $query->orderBy('scheduled_at', 'desc')->paginate(20);

        return response()->json($rides);
    }

    /**
     * Update a scheduled ride.
     */
    public function update(Request $request, Ride $ride): JsonResponse
    {
        // Verify ownership
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Can only update pending scheduled rides
        if (!$ride->isScheduledRide() || $ride->scheduled_status !== 'pending') {
            return response()->json([
                'message' => 'Can only update pending scheduled rides'
            ], 400);
        }

        // Cannot update rides scheduled within 30 minutes
        if ($ride->scheduled_at && $ride->scheduled_at->diffInMinutes(now()) < 30) {
            return response()->json([
                'message' => 'Cannot update rides scheduled within 30 minutes'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'scheduled_at' => 'date|after:30 minutes|before:30 days',
            'pickup_latitude' => 'numeric|between:-90,90',
            'pickup_longitude' => 'numeric|between:-180,180',
            'pickup_address' => 'string',
            'dropoff_latitude' => 'numeric|between:-90,90',
            'dropoff_longitude' => 'numeric|between:-180,180',
            'dropoff_address' => 'string',
            'passenger_notes' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = $request->only([
            'pickup_latitude',
            'pickup_longitude',
            'pickup_address',
            'dropoff_latitude',
            'dropoff_longitude',
            'dropoff_address',
            'passenger_notes',
        ]);

        // Update scheduled time if provided
        if ($request->has('scheduled_at')) {
            $scheduledAt = \Carbon\Carbon::parse($request->input('scheduled_at'));
            $updateData['scheduled_at'] = $scheduledAt;
            $updateData['scheduled_pickup_window_start'] = $scheduledAt->copy()->subMinutes(5);
            $updateData['scheduled_pickup_window_end'] = $scheduledAt->copy()->addMinutes(10);
        }

        $ride->update($updateData);

        return response()->json([
            'data' => $ride->fresh(),
            'message' => 'Scheduled ride updated successfully'
        ]);
    }

    /**
     * Cancel a scheduled ride.
     */
    public function cancel(Request $request, Ride $ride): JsonResponse
    {
        // Verify ownership
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Can only cancel pending or confirmed scheduled rides
        if (!$ride->isScheduledRide() || !in_array($ride->scheduled_status, ['pending', 'confirmed'])) {
            return response()->json([
                'message' => 'Can only cancel pending or confirmed scheduled rides'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $ride->update([
            'scheduled_status' => 'cancelled',
            'status' => 'cancelled_by_passenger',
            'cancelled_at' => now(),
            'cancelled_by' => $request->user()->id,
            'cancellation_reason' => $request->input('reason'),
        ]);

        return response()->json([
            'data' => $ride->fresh(),
            'message' => 'Scheduled ride cancelled successfully'
        ]);
    }

    /**
     * Get scheduled rides ready for driver assignment (for internal use/cron).
     */
    public function readyForAssignment(): JsonResponse
    {
        // Get rides scheduled within the next 60 minutes that need drivers
        $rides = Ride::where('is_scheduled', true)
            ->where('scheduled_status', 'pending')
            ->whereNull('driver_id')
            ->where('scheduled_at', '>', now())
            ->where('scheduled_at', '<=', now()->addMinutes(60))
            ->with(['passenger', 'category'])
            ->get();

        return response()->json([
            'data' => $rides,
            'count' => $rides->count()
        ]);
    }
}
