<?php

namespace App\Http\Controllers;

use App\Models\SOSAlert;
use App\Models\SOSMonitoringAlert;
use App\Models\EmergencyContact;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Notification;
use App\Notifications\SOSActivatedNotification;
use App\Notifications\SOSDeactivatedNotification;
use App\Http\Requests\SOS\ActivateSOSRequest;
use App\Http\Requests\SOS\DeactivateSOSRequest;
use App\Http\Requests\SOS\UpdateSOSLocationRequest;
use App\Http\Requests\SOS\AlertMonitoringCenterRequest;
use App\Http\Requests\SOS\ShareSOSLocationRequest;
use App\Http\Requests\SOS\GetNearestEmergencyServicesRequest;

class SOSController extends Controller
{
    /**
     * Activate SOS alert
     */
    public function activate(ActivateSOSRequest $request): JsonResponse
    {
        $user = $request->user();

        // Check if user already has an active SOS
        $existingSOS = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if ($existingSOS) {
            return response()->json([
                'message' => 'You already have an active SOS alert',
                'data' => [
                    'sos_alert' => $existingSOS,
                    'tracking_url' => $existingSOS->getTrackingUrl(),
                ]
            ], 409);
        }

        // Create SOS alert
        $sosAlert = SOSAlert::create([
            'user_id' => $user->id,
            'ride_id' => $request->input('ride_id'),
            'latitude' => $request->input('latitude'),
            'longitude' => $request->input('longitude'),
            'accuracy' => $request->input('accuracy'),
            'note' => $request->input('note'),
            'status' => 'active',
        ]);

        // Notify emergency contacts
        $this->notifyEmergencyContacts($sosAlert);

        // Notify monitoring center
        $this->notifyMonitoringCenter($sosAlert);

        return response()->json([
            'message' => 'SOS alert activated successfully',
            'data' => [
                'sos_alert' => $sosAlert,
                'tracking_url' => $sosAlert->getTrackingUrl(),
                'tracking_code' => $sosAlert->tracking_code,
            ]
        ], 200);
    }

    /**
     * Deactivate SOS alert
     */
    public function deactivate(DeactivateSOSRequest $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found'
            ], 404);
        }

        $sosAlert->deactivate($request->input('resolution'));

        // Notify emergency contacts that SOS is deactivated
        $this->notifySOSDeactivated($sosAlert);

        return response()->json([
            'message' => 'SOS alert deactivated successfully',
            'data' => [
                'sos_alert' => $sosAlert,
                'duration' => $sosAlert->getFormattedDuration(),
            ]
        ], 200);
    }

    /**
     * Update location during active SOS
     */
    public function updateLocation(UpdateSOSLocationRequest $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found'
            ], 404);
        }

        // Add location update
        $locationUpdate = $sosAlert->addLocationUpdate(
            $request->input('latitude'),
            $request->input('longitude'),
            $request->input('accuracy')
        );

        return response()->json([
            'message' => 'Location updated successfully',
            'data' => [
                'location_update' => $locationUpdate,
            ]
        ], 200);
    }

    /**
     * Send heartbeat to keep SOS alive
     */
    public function heartbeat(Request $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found'
            ], 404);
        }

        $sosAlert->heartbeat();

        return response()->json([
            'message' => 'Heartbeat received',
            'data' => [
                'last_heartbeat_at' => $sosAlert->last_heartbeat_at,
            ]
        ], 200);
    }

    /**
     * Get tracking link for sharing
     */
    public function getTrackingLink(Request $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found'
            ], 404);
        }

        return response()->json([
            'message' => 'Tracking link retrieved successfully',
            'data' => [
                'link' => $sosAlert->getTrackingUrl(),
                'tracking_code' => $sosAlert->tracking_code,
            ]
        ], 200);
    }

    /**
     * Alert monitoring center
     */
    public function alertMonitoringCenter(AlertMonitoringCenterRequest $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found'
            ], 404);
        }

        $monitoringAlert = SOSMonitoringAlert::create([
            'sos_alert_id' => $sosAlert->id,
            'reason' => $request->input('reason'),
            'details' => $request->input('details'),
            'status' => 'pending',
        ]);

        // TODO: Send notification to monitoring center staff

        return response()->json([
            'message' => 'Monitoring center alerted successfully',
            'data' => [
                'monitoring_alert' => $monitoringAlert,
            ]
        ], 200);
    }

    /**
     * Start audio recording (placeholder for actual implementation)
     */
    public function startAudioRecording(Request $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found'
            ], 404);
        }

        // TODO: Implement actual audio recording logic
        // This might involve:
        // 1. Notifying backend to start recording from mobile device
        // 2. Using WebRTC or similar to stream audio
        // 3. Storing audio files securely

        return response()->json([
            'message' => 'Audio recording started',
            'data' => [
                'recording_status' => 'active',
                'sos_alert_id' => $sosAlert->id,
            ]
        ], 200);
    }

    /**
     * Share location with specific contact
     */
    public function shareLocation(ShareSOSLocationRequest $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found'
            ], 404);
        }

        $contact = EmergencyContact::where('id', $request->input('contact_id'))
            ->where('user_id', $user->id)
            ->first();

        if (!$contact) {
            return response()->json([
                'message' => 'Emergency contact not found or does not belong to you'
            ], 404);
        }

        // Create notification record
        $notification = $sosAlert->notifications()->create([
            'emergency_contact_id' => $contact->id,
            'status' => 'pending',
        ]);

        // Send notification
        try {
            // TODO: Implement actual SMS/Email sending
            $notification->markAsSent();
        } catch (\Exception $e) {
            $notification->markAsFailed($e->getMessage());
        }

        return response()->json([
            'message' => 'Location shared successfully',
            'data' => [
                'notification' => $notification,
                'contact' => $contact,
            ]
        ], 200);
    }

    /**
     * Get nearest emergency services (police, hospital, etc.)
     */
    public function getNearestEmergencyServices(GetNearestEmergencyServicesRequest $request): JsonResponse
    {
        // TODO: Integrate with Google Places API or similar to find:
        // - Nearest police station
        // - Nearest hospital
        // - Nearest fire station
        // For now, returning mock data

        $mockData = [
            'police' => [
                'name' => 'Delegacia de Polícia',
                'address' => 'Rua Example, 123',
                'distance' => 1.5, // km
                'phone' => '190',
                'latitude' => -23.550520,
                'longitude' => -46.633308,
            ],
            'hospital' => [
                'name' => 'Hospital Geral',
                'address' => 'Av. Example, 456',
                'distance' => 2.3, // km
                'phone' => '192',
                'latitude' => -23.551520,
                'longitude' => -46.634308,
            ],
            'fire' => [
                'name' => 'Corpo de Bombeiros',
                'address' => 'Rua Example, 789',
                'distance' => 1.8, // km
                'phone' => '193',
                'latitude' => -23.552520,
                'longitude' => -46.635308,
            ],
        ];

        return response()->json([
            'message' => 'Nearest emergency services retrieved successfully',
            'data' => $mockData
        ], 200);
    }

    /**
     * Track SOS by tracking code (public endpoint)
     */
    public function track(string $trackingCode): JsonResponse
    {
        $sosAlert = SOSAlert::where('tracking_code', $trackingCode)->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'SOS alert not found'
            ], 404);
        }

        $latestLocation = $sosAlert->getLatestLocation();

        return response()->json([
            'message' => 'SOS alert tracking information',
            'data' => [
                'user' => [
                    'name' => $sosAlert->user->name,
                    'phone' => $sosAlert->user->phone,
                ],
                'status' => $sosAlert->status,
                'activated_at' => $sosAlert->activated_at,
                'duration' => $sosAlert->getFormattedDuration(),
                'latest_location' => $latestLocation,
                'is_active' => $sosAlert->isActive(),
            ]
        ], 200);
    }

    /**
     * Get active SOS alert for current user
     */
    public function getActive(Request $request): JsonResponse
    {
        $user = $request->user();

        $sosAlert = SOSAlert::where('user_id', $user->id)
            ->active()
            ->with(['locationUpdates' => function ($query) {
                $query->latest('recorded_at')->limit(10);
            }])
            ->first();

        if (!$sosAlert) {
            return response()->json([
                'message' => 'No active SOS alert found',
                'data' => null
            ], 200);
        }

        return response()->json([
            'message' => 'Active SOS alert retrieved successfully',
            'data' => [
                'sos_alert' => $sosAlert,
                'tracking_url' => $sosAlert->getTrackingUrl(),
                'duration' => $sosAlert->getFormattedDuration(),
                'latest_location' => $sosAlert->getLatestLocation(),
            ]
        ], 200);
    }

    /**
     * Get SOS history for current user
     */
    public function getHistory(Request $request): JsonResponse
    {
        $user = $request->user();

        $alerts = SOSAlert::where('user_id', $user->id)
            ->with(['ride', 'locationUpdates'])
            ->latest('activated_at')
            ->paginate(20);

        return response()->json([
            'message' => 'SOS history retrieved successfully',
            'data' => $alerts
        ], 200);
    }

    /**
     * Notify emergency contacts
     */
    protected function notifyEmergencyContacts(SOSAlert $sosAlert): void
    {
        $contacts = EmergencyContact::where('user_id', $sosAlert->user_id)->get();

        foreach ($contacts as $contact) {
            $notification = $sosAlert->notifications()->create([
                'emergency_contact_id' => $contact->id,
                'status' => 'pending',
            ]);

            try {
                // TODO: Send actual SMS/Email
                // Notification::send($contact, new SOSActivatedNotification($sosAlert));
                $notification->markAsSent();
            } catch (\Exception $e) {
                $notification->markAsFailed($e->getMessage());
            }
        }
    }

    /**
     * Notify monitoring center
     */
    protected function notifyMonitoringCenter(SOSAlert $sosAlert): void
    {
        // TODO: Implement notification to monitoring center staff
        // This could be:
        // 1. Push notification to monitoring dashboard
        // 2. SMS/Email to on-duty staff
        // 3. Webhook to external monitoring service
    }

    /**
     * Notify SOS deactivated
     */
    protected function notifySOSDeactivated(SOSAlert $sosAlert): void
    {
        $contacts = EmergencyContact::where('user_id', $sosAlert->user_id)->get();

        foreach ($contacts as $contact) {
            try {
                // TODO: Send actual SMS/Email
                // Notification::send($contact, new SOSDeactivatedNotification($sosAlert));
            } catch (\Exception $e) {
                // Log error
            }
        }
    }
}
