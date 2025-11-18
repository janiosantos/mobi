<?php

namespace App\Services;

use App\Models\VehicleCategory;
use App\Models\PricingRule;
use App\Models\SurgePricingLog;
use App\Models\Coupon;
use Illuminate\Support\Facades\Log;

class PricingService
{
    /**
     * Calculate ride estimate
     */
    public function calculateEstimate(
        VehicleCategory $category,
        float $distanceMeters,
        int $durationSeconds,
        float $pickupLatitude,
        float $pickupLongitude,
        ?int $couponId = null
    ): array {
        // Convert to km and minutes
        $distanceKm = $distanceMeters / 1000;
        $durationMinutes = $durationSeconds / 60;

        // Get active pricing rule
        $pricingRule = $this->getActivePricingRule($category->id);

        // Calculate base components
        $baseFare = $pricingRule->base_fare;
        $distanceFare = $distanceKm * $pricingRule->price_per_km;
        $timeFare = $durationMinutes * $pricingRule->price_per_minute;

        // Calculate subtotal
        $subtotal = $baseFare + $distanceFare + $timeFare;

        // Apply category multiplier
        $subtotal *= $category->base_multiplier;

        // Apply pricing rule multiplier (time-based surge, etc)
        $subtotal *= $pricingRule->multiplier;

        // Get surge multiplier
        $surgeMultiplier = $this->getSurgeMultiplier($pickupLatitude, $pickupLongitude, $category->id);
        $subtotal *= $surgeMultiplier;

        // Ensure minimum fare
        $total = max($subtotal, $pricingRule->minimum_fare);

        // Apply coupon if provided
        $discount = 0;
        if ($couponId) {
            $discount = $this->calculateCouponDiscount($couponId, $total);
            $total -= $discount;
        }

        // Calculate platform fee and driver earnings
        $platformFee = $total * (config('mobi.commission.platform_percentage') / 100);
        $driverEarnings = $total - $platformFee;

        return [
            'base_fare' => round($baseFare, 2),
            'distance_fare' => round($distanceFare, 2),
            'time_fare' => round($timeFare, 2),
            'category_multiplier' => $category->base_multiplier,
            'pricing_multiplier' => $pricingRule->multiplier,
            'surge_multiplier' => $surgeMultiplier,
            'is_surge_active' => $surgeMultiplier > 1.0,
            'subtotal' => round($subtotal, 2),
            'minimum_fare' => round($pricingRule->minimum_fare, 2),
            'discount' => round($discount, 2),
            'total' => round($total, 2),
            'platform_fee' => round($platformFee, 2),
            'driver_earnings' => round($driverEarnings, 2),
            'distance_km' => round($distanceKm, 2),
            'duration_minutes' => round($durationMinutes, 1),
        ];
    }

    /**
     * Get active pricing rule for a category
     */
    protected function getActivePricingRule(?int $categoryId = null): PricingRule
    {
        $query = PricingRule::active();

        if ($categoryId) {
            $query->where(function ($q) use ($categoryId) {
                $q->where('vehicle_category_id', $categoryId)
                    ->orWhereNull('vehicle_category_id');
            });
        }

        // Get rule with highest priority
        $rule = $query->orderByDesc('priority')->first();

        // If no rule found, use default from config
        if (!$rule) {
            return new PricingRule([
                'base_fare' => config('mobi.pricing.base_fare'),
                'price_per_km' => config('mobi.pricing.price_per_km'),
                'price_per_minute' => config('mobi.pricing.price_per_minute'),
                'minimum_fare' => config('mobi.pricing.minimum_fare'),
                'multiplier' => 1.0,
            ]);
        }

        return $rule;
    }

    /**
     * Get surge multiplier for a location
     */
    public function getSurgeMultiplier(float $latitude, float $longitude, ?int $categoryId = null): float
    {
        if (!config('mobi.pricing.surge_pricing_enabled')) {
            return 1.0;
        }

        $surgeLog = SurgePricingLog::active()
            ->where('is_active', true)
            ->when($categoryId, fn($q) => $q->where('vehicle_category_id', $categoryId))
            ->get()
            ->filter(function ($surge) use ($latitude, $longitude) {
                $distance = $this->calculateDistance(
                    $latitude,
                    $longitude,
                    $surge->latitude,
                    $surge->longitude
                );
                return $distance <= $surge->radius;
            })
            ->sortByDesc('multiplier')
            ->first();

        if (!$surgeLog) {
            return 1.0;
        }

        $maxMultiplier = config('mobi.pricing.surge_max_multiplier');
        return min($surgeLog->multiplier, $maxMultiplier);
    }

    /**
     * Calculate coupon discount
     */
    protected function calculateCouponDiscount(int $couponId, float $rideTotal): float
    {
        $coupon = Coupon::find($couponId);

        if (!$coupon || !$coupon->isValid()) {
            return 0;
        }

        // Check minimum ride amount
        if ($coupon->min_ride_amount && $rideTotal < $coupon->min_ride_amount) {
            return 0;
        }

        $discount = 0;

        switch ($coupon->type) {
            case 'percentage':
                $discount = $rideTotal * ($coupon->discount_value / 100);
                if ($coupon->max_discount_amount) {
                    $discount = min($discount, $coupon->max_discount_amount);
                }
                break;

            case 'fixed_amount':
                $discount = min($coupon->discount_value, $rideTotal);
                break;

            case 'first_ride_free':
                $discount = $rideTotal;
                break;
        }

        return $discount;
    }

    /**
     * Calculate distance using Haversine formula
     */
    protected function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371000; // meters

        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }

    /**
     * Update surge pricing based on demand/supply
     */
    public function updateSurgePricing(float $latitude, float $longitude, int $categoryId): void
    {
        // This would be called by a scheduled job
        // Calculate demand (pending rides) vs supply (available drivers)

        // For now, just a placeholder
        Log::info('Surge pricing update requested', [
            'lat' => $latitude,
            'lng' => $longitude,
            'category' => $categoryId,
        ]);
    }
}
