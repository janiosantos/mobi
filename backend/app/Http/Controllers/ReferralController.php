<?php

namespace App\Http\Controllers;

use App\Models\Referral;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Http\Requests\Referral\InviteReferralRequest;
use App\Http\Requests\Referral\ApplyReferralRequest;

class ReferralController extends Controller
{
    /**
     * Get my referral info and statistics.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        // Generate referral code if user doesn't have one
        if (!$user->referral_code) {
            $user->update([
                'referral_code' => $this->generateUniqueUserCode()
            ]);
        }

        $referrals = $user->referralsMade()
            ->with(['referred'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => [
                'referral_code' => $user->referral_code,
                'referral_credits' => $user->referral_credits,
                'referrals_count' => $user->referrals_count,
                'successful_referrals_count' => $user->successful_referrals_count,
                'referrals' => $referrals,
                'referrer_reward' => Referral::REFERRER_CREDIT,
                'referred_reward' => Referral::REFERRED_CREDIT,
            ]
        ]);
    }

    /**
     * Send a referral invitation.
     */
    public function invite(InviteReferralRequest $request): JsonResponse
    {
        $user = $request->user();

        // Check if already referred this email/phone
        $existing = Referral::where('referrer_id', $user->id)
            ->where(function($q) use ($request) {
                if ($request->has('email')) {
                    $q->orWhere('referred_email', $request->input('email'));
                }
                if ($request->has('phone')) {
                    $q->orWhere('referred_phone', $request->input('phone'));
                }
            })
            ->first();

        if ($existing) {
            return response()->json([
                'message' => 'You have already sent a referral to this contact',
                'data' => $existing
            ], 400);
        }

        $referral = Referral::create([
            'referrer_id' => $user->id,
            'referral_code' => Referral::generateUniqueCode(),
            'referred_email' => $request->input('email'),
            'referred_phone' => $request->input('phone'),
            'status' => 'pending',
            'referrer_credit' => Referral::REFERRER_CREDIT,
            'referred_credit' => Referral::REFERRED_CREDIT,
            'expires_at' => now()->addDays(Referral::EXPIRATION_DAYS),
        ]);

        // TODO: Send invitation via email/SMS

        return response()->json([
            'data' => $referral,
            'message' => 'Referral invitation sent successfully'
        ], 201);
    }

    /**
     * Apply a referral code during registration.
     */
    public function apply(ApplyReferralRequest $request): JsonResponse
    {
        $code = strtoupper($request->input('referral_code'));

        // Find referral by code
        $referral = Referral::where('referral_code', $code)
            ->pending()
            ->first();

        if (!$referral) {
            return response()->json([
                'message' => 'Invalid or expired referral code'
            ], 404);
        }

        $user = $request->user();

        // Check if user already has a referrer
        if ($user->referred_by) {
            return response()->json([
                'message' => 'You have already been referred by another user'
            ], 400);
        }

        // Mark referral as registered
        $referral->markAsRegistered($user);

        // Update user
        $user->update([
            'referred_by' => $referral->referrer_id
        ]);

        return response()->json([
            'data' => $referral->fresh(),
            'message' => 'Referral code applied successfully. Complete your first ride to receive R$ ' . number_format($referral->referred_credit, 2) . ' in credits!'
        ]);
    }

    /**
     * Get a specific referral by code (public).
     */
    public function show(string $code): JsonResponse
    {
        $referral = Referral::where('referral_code', strtoupper($code))
            ->with(['referrer:id,name'])
            ->first();

        if (!$referral) {
            return response()->json([
                'message' => 'Referral not found'
            ], 404);
        }

        return response()->json([
            'data' => [
                'referrer_name' => $referral->referrer->name,
                'referred_credit' => $referral->referred_credit,
                'is_valid' => !$referral->isExpired() && $referral->isPending(),
                'expires_at' => $referral->expires_at,
            ]
        ]);
    }

    /**
     * Get my referrals (sent and received).
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // Referrals made by me
        $madeReferrals = $user->referralsMade()
            ->with(['referred'])
            ->orderBy('created_at', 'desc')
            ->get();

        // Referral received by me
        $receivedReferral = $user->referralReceived;

        return response()->json([
            'data' => [
                'made' => $madeReferrals,
                'received' => $receivedReferral,
            ]
        ]);
    }

    /**
     * Get referral statistics and leaderboard.
     */
    public function leaderboard(): JsonResponse
    {
        $topReferrers = User::where('successful_referrals_count', '>', 0)
            ->orderBy('successful_referrals_count', 'desc')
            ->orderBy('referral_credits', 'desc')
            ->take(20)
            ->get(['id', 'name', 'successful_referrals_count', 'referral_credits']);

        return response()->json([
            'data' => $topReferrers
        ]);
    }

    /**
     * Generate unique referral code for user.
     */
    private function generateUniqueUserCode(): string
    {
        do {
            $code = strtoupper(Str::random(8));
        } while (User::where('referral_code', $code)->exists());

        return $code;
    }
}
