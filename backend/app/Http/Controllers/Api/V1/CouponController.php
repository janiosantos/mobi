<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Coupon\ValidateCouponRequest;
use App\Models\Coupon;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CouponController extends Controller
{
    /**
     * List available coupons for user
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // Get active coupons that user hasn't reached max uses
        $coupons = Coupon::where('is_active', true)
            ->where('valid_from', '<=', now())
            ->where('valid_until', '>=', now())
            ->where(function ($query) {
                $query->whereNull('max_uses')
                    ->orWhereRaw('uses_count < max_uses');
            })
            ->get();

        // Filter coupons user hasn't used or can use again
        $availableCoupons = $coupons->filter(function ($coupon) use ($user) {
            $userUsageCount = $coupon->usages()
                ->where('user_id', $user->id)
                ->count();

            // Check if user hasn't reached personal limit (usually 1)
            return $userUsageCount === 0;
        })->values();

        return response()->json([
            'success' => true,
            'message' => 'Available coupons retrieved successfully',
            'data' => $availableCoupons,
        ]);
    }

    /**
     * Validate coupon code
     *
     * @param ValidateCouponRequest $request
     * @return JsonResponse
     */
    public function validate(ValidateCouponRequest $request): JsonResponse
    {
        $user = $request->user();
        $code = $request->input('code');
        $rideValue = $request->input('ride_value', 0);

        $coupon = Coupon::where('code', $code)
            ->where('is_active', true)
            ->first();

        // Check if coupon exists
        if (!$coupon) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid coupon code',
            ], 404);
        }

        // Check if coupon is within valid period
        if ($coupon->valid_from && Carbon::parse($coupon->valid_from)->isFuture()) {
            return response()->json([
                'success' => false,
                'message' => 'Coupon is not yet valid',
            ], 422);
        }

        if ($coupon->valid_until && Carbon::parse($coupon->valid_until)->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Coupon has expired',
            ], 422);
        }

        // Check if coupon has reached max uses
        if ($coupon->max_uses && $coupon->uses_count >= $coupon->max_uses) {
            return response()->json([
                'success' => false,
                'message' => 'Coupon has reached maximum uses',
            ], 422);
        }

        // Check if user has already used this coupon
        $userHasUsed = $coupon->usages()
            ->where('user_id', $user->id)
            ->exists();

        if ($userHasUsed) {
            return response()->json([
                'success' => false,
                'message' => 'You have already used this coupon',
            ], 422);
        }

        // Check minimum ride value
        if ($coupon->min_ride_value && $rideValue < $coupon->min_ride_value) {
            return response()->json([
                'success' => false,
                'message' => "Minimum ride value is R$ {$coupon->min_ride_value}",
            ], 422);
        }

        // Calculate discount
        $discount = 0;
        if ($coupon->type === 'percentage') {
            $discount = ($rideValue * $coupon->value) / 100;

            // Apply max discount cap if exists
            if ($coupon->max_discount && $discount > $coupon->max_discount) {
                $discount = $coupon->max_discount;
            }
        } else if ($coupon->type === 'fixed') {
            $discount = $coupon->value;

            // Discount can't be more than ride value
            if ($discount > $rideValue) {
                $discount = $rideValue;
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Coupon is valid',
            'data' => [
                'coupon_id' => $coupon->id,
                'code' => $coupon->code,
                'type' => $coupon->type,
                'value' => $coupon->value,
                'discount_amount' => round($discount, 2),
                'final_value' => round($rideValue - $discount, 2),
            ],
        ]);
    }
}
