<?php

namespace App\Http\Controllers;

use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SafetyController extends Controller
{
    /**
     * Share trip with emergency contacts.
     */
    public function shareTrip(Request $request, Ride $ride): JsonResponse
    {
        // Verify user is the passenger
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Verify ride is active
        if (!in_array($ride->status, ['searching', 'accepted', 'arrived', 'in_progress'])) {
            return response()->json(['message' => 'Cannot share inactive ride'], 400);
        }

        // Generate share code if not exists
        if (!$ride->share_code) {
            $ride->share_code = $this->generateShareCode();
            $ride->share_trip = true;
            $ride->share_expires_at = now()->addHours(6);
            $ride->save();
        }

        $shareUrl = config('app.url') . '/shared-trip/' . $ride->share_code;

        // TODO: Send SMS/notification to emergency contacts

        return response()->json([
            'data' => [
                'share_code' => $ride->share_code,
                'share_url' => $shareUrl,
                'expires_at' => $ride->share_expires_at,
            ]
        ]);
    }

    /**
     * Get shared trip details (public endpoint).
     */
    public function getSharedTrip(string $code): JsonResponse
    {
        $ride = Ride::where('share_code', $code)
            ->where('share_trip', true)
            ->where('share_expires_at', '>', now())
            ->with(['passenger:id,name,photo_url', 'driver:id,name,photo_url,rating'])
            ->first();

        if (!$ride) {
            return response()->json(['message' => 'Shared trip not found or expired'], 404);
        }

        return response()->json([
            'data' => [
                'ride_id' => $ride->id,
                'status' => $ride->status,
                'passenger' => $ride->passenger,
                'driver' => $ride->driver,
                'pickup_address' => $ride->pickup_address,
                'dropoff_address' => $ride->dropoff_address,
                'pickup_location' => [
                    'latitude' => $ride->pickup_latitude,
                    'longitude' => $ride->pickup_longitude,
                ],
                'dropoff_location' => [
                    'latitude' => $ride->dropoff_latitude,
                    'longitude' => $ride->dropoff_longitude,
                ],
                'current_location' => $ride->driver ? [
                    'latitude' => $ride->driver->current_latitude,
                    'longitude' => $ride->driver->current_longitude,
                ] : null,
                'estimated_arrival' => $ride->estimated_arrival_time,
                'started_at' => $ride->started_at,
            ]
        ]);
    }

    /**
     * Trigger SOS alert.
     */
    public function triggerSOS(Request $request, Ride $ride): JsonResponse
    {
        // Verify user is passenger or driver
        $user = $request->user();
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Mark SOS
        $ride->update([
            'sos_triggered_at' => now(),
            'sos_note' => $request->input('note'),
        ]);

        // TODO: Implement emergency actions:
        // 1. Send SMS to emergency contacts
        // 2. Notify admin/support team
        // 3. Alert authorities if configured
        // 4. Start audio recording
        // 5. Share location in real-time

        // Get emergency contacts
        $contacts = $user->emergencyContacts()->get();

        return response()->json([
            'message' => 'SOS alert triggered',
            'data' => [
                'triggered_at' => $ride->sos_triggered_at,
                'contacts_notified' => $contacts->count(),
                'support_ticket' => 'SOS-' . $ride->id . '-' . now()->timestamp,
            ]
        ]);
    }

    /**
     * Cancel SOS alert.
     */
    public function cancelSOS(Request $request, Ride $ride): JsonResponse
    {
        // Verify user is passenger or driver
        $user = $request->user();
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $ride->update([
            'sos_triggered_at' => null,
            'sos_note' => null,
        ]);

        return response()->json(['message' => 'SOS alert cancelled']);
    }

    /**
     * Generate unique share code.
     */
    private function generateShareCode(): string
    {
        do {
            $code = strtoupper(Str::random(6));
        } while (Ride::where('share_code', $code)->exists());

        return $code;
    }
}
