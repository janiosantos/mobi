<?php

namespace App\Http\Controllers;

use App\Models\Ride;
use App\Models\RideSplitPayment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class SplitFareController extends Controller
{
    const MAX_SPLIT_PARTICIPANTS = 5;

    /**
     * Create a split payment request for a ride.
     */
    public function create(Request $request, Ride $ride): JsonResponse
    {
        // Verify ownership (only passenger can create split)
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Can only split payment for completed rides
        if (!$ride->isCompleted()) {
            return response()->json([
                'message' => 'Can only split payment for completed rides'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'method' => 'required|in:equal,custom,percentage',
            'participants' => 'required|array|min:1|max:' . (self::MAX_SPLIT_PARTICIPANTS - 1),
            'participants.*.user_id' => 'nullable|exists:users,id',
            'participants.*.email' => 'nullable|email',
            'participants.*.phone' => 'nullable|string',
            'participants.*.amount' => 'required_if:method,custom|numeric|min:0',
            'participants.*.percentage' => 'required_if:method,percentage|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $method = $request->input('method');
        $participants = $request->input('participants');
        $totalPrice = $ride->final_price ?? $ride->estimated_price;

        // Check if already has split payments
        if ($ride->is_split_payment) {
            return response()->json([
                'message' => 'This ride already has split payments'
            ], 400);
        }

        // Validate amounts for custom method
        if ($method === 'custom') {
            $totalSplitAmount = collect($participants)->sum('amount');
            if (abs($totalSplitAmount - $totalPrice) > 0.01) {
                return response()->json([
                    'message' => 'Split amounts must equal the total ride price'
                ], 400);
            }
        }

        // Validate percentages
        if ($method === 'percentage') {
            $totalPercentage = collect($participants)->sum('percentage');
            if (abs($totalPercentage - 100) > 0.01) {
                return response()->json([
                    'message' => 'Split percentages must equal 100%'
                ], 400);
            }
        }

        // Create split payments
        $splitPayments = [];
        foreach ($participants as $participant) {
            // Find or get user by email/phone
            $userId = $participant['user_id'] ?? null;

            $amount = $this->calculateAmount($method, $participant, $totalPrice);

            $splitPayment = RideSplitPayment::create([
                'ride_id' => $ride->id,
                'user_id' => $userId,
                'invited_by' => $request->user()->id,
                'invite_code' => strtoupper(Str::random(8)),
                'amount' => $amount,
                'percentage' => $method === 'percentage' ? $participant['percentage'] : null,
                'status' => 'pending',
                'expires_at' => now()->addDays(7),
            ]);

            $splitPayments[] = $splitPayment;

            // TODO: Send notification/email/SMS to participant
        }

        // Update ride
        $ride->update([
            'is_split_payment' => true,
            'split_count' => count($participants),
            'split_method' => $method,
        ]);

        return response()->json([
            'data' => [
                'ride' => $ride->fresh(),
                'split_payments' => $splitPayments,
            ],
            'message' => 'Split payment created successfully'
        ], 201);
    }

    /**
     * Get split payments for a ride.
     */
    public function index(Request $request, Ride $ride): JsonResponse
    {
        // Verify user is passenger, driver, or one of the split participants
        $userId = $request->user()->id;
        $isParticipant = $ride->splitPayments()->where('user_id', $userId)->exists();

        if ($ride->passenger_id !== $userId && $ride->driver_id !== $userId && !$isParticipant) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $splitPayments = $ride->splitPayments()->with(['user', 'inviter'])->get();

        return response()->json([
            'data' => $splitPayments
        ]);
    }

    /**
     * Get a specific split payment by invite code.
     */
    public function show(string $inviteCode): JsonResponse
    {
        $splitPayment = RideSplitPayment::with(['ride', 'inviter'])
            ->where('invite_code', $inviteCode)
            ->first();

        if (!$splitPayment) {
            return response()->json([
                'message' => 'Split payment not found'
            ], 404);
        }

        return response()->json([
            'data' => $splitPayment
        ]);
    }

    /**
     * Accept a split payment invitation.
     */
    public function accept(Request $request, string $inviteCode): JsonResponse
    {
        $splitPayment = RideSplitPayment::where('invite_code', $inviteCode)->first();

        if (!$splitPayment) {
            return response()->json([
                'message' => 'Split payment not found'
            ], 404);
        }

        if ($splitPayment->isExpired()) {
            $splitPayment->update(['status' => 'expired']);
            return response()->json([
                'message' => 'This invitation has expired'
            ], 400);
        }

        if (!$splitPayment->isPending()) {
            return response()->json([
                'message' => 'This invitation has already been ' . $splitPayment->status
            ], 400);
        }

        // Set user_id if not already set
        if (!$splitPayment->user_id) {
            $splitPayment->update(['user_id' => $request->user()->id]);
        }

        // Verify user owns this split
        if ($splitPayment->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'This invitation is for another user'
            ], 403);
        }

        $splitPayment->accept();

        return response()->json([
            'data' => $splitPayment->fresh(),
            'message' => 'Split payment accepted successfully'
        ]);
    }

    /**
     * Decline a split payment invitation.
     */
    public function decline(Request $request, string $inviteCode): JsonResponse
    {
        $splitPayment = RideSplitPayment::where('invite_code', $inviteCode)->first();

        if (!$splitPayment) {
            return response()->json([
                'message' => 'Split payment not found'
            ], 404);
        }

        if (!$splitPayment->isPending()) {
            return response()->json([
                'message' => 'This invitation has already been ' . $splitPayment->status
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

        $splitPayment->decline($request->input('reason'));

        return response()->json([
            'data' => $splitPayment->fresh(),
            'message' => 'Split payment declined'
        ]);
    }

    /**
     * Pay a split payment.
     */
    public function pay(Request $request, string $inviteCode): JsonResponse
    {
        $splitPayment = RideSplitPayment::where('invite_code', $inviteCode)->first();

        if (!$splitPayment) {
            return response()->json([
                'message' => 'Split payment not found'
            ], 404);
        }

        // Verify user owns this split
        if ($splitPayment->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        if (!$splitPayment->isAccepted() && !$splitPayment->isPending()) {
            return response()->json([
                'message' => 'Split payment must be accepted before payment'
            ], 400);
        }

        // TODO: Process actual payment with payment gateway

        $splitPayment->markAsPaid();

        return response()->json([
            'data' => $splitPayment->fresh(),
            'message' => 'Payment processed successfully'
        ]);
    }

    /**
     * Get my split payment invitations.
     */
    public function myInvitations(Request $request): JsonResponse
    {
        $splitPayments = RideSplitPayment::where('user_id', $request->user()->id)
            ->orWhere('invited_by', $request->user()->id)
            ->with(['ride', 'user', 'inviter'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($splitPayments);
    }

    /**
     * Calculate split amount based on method.
     */
    private function calculateAmount(string $method, array $participant, float $totalPrice): float
    {
        switch ($method) {
            case 'equal':
                // Will be calculated when all participants are known
                return 0;
            case 'custom':
                return $participant['amount'];
            case 'percentage':
                return round(($participant['percentage'] / 100) * $totalPrice, 2);
            default:
                return 0;
        }
    }
}
