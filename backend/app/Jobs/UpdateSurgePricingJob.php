<?php

namespace App\Jobs;

use App\Models\VehicleCategory;
use App\Models\Ride;
use App\Models\DriverProfile;
use App\Models\SurgePricingLog;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class UpdateSurgePricingJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     */
    public $tries = 1;

    /**
     * The number of seconds the job can run before timing out.
     */
    public $timeout = 60;

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            foreach (VehicleCategory::active()->get() as $category) {
                $surgeMultiplier = $this->calculateSurgeMultiplier($category);

                // Cache the surge multiplier for this category
                Cache::put(
                    "surge_multiplier_{$category->id}",
                    $surgeMultiplier,
                    now()->addMinutes(5)
                );

                // Log surge pricing if multiplier is > 1.0
                if ($surgeMultiplier > 1.0) {
                    SurgePricingLog::create([
                        'vehicle_category_id' => $category->id,
                        'multiplier' => $surgeMultiplier,
                        'active_rides' => $this->getActiveRidesCount($category),
                        'available_drivers' => $this->getAvailableDriversCount($category),
                    ]);
                }

                Log::info('Surge pricing updated', [
                    'category' => $category->name,
                    'multiplier' => $surgeMultiplier,
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Error updating surge pricing', [
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Calculate surge multiplier based on demand and supply
     */
    protected function calculateSurgeMultiplier(VehicleCategory $category): float
    {
        $activeRides = $this->getActiveRidesCount($category);
        $availableDrivers = $this->getAvailableDriversCount($category);

        // Avoid division by zero
        if ($availableDrivers === 0) {
            return config('mobi.pricing.max_surge_multiplier', 2.5);
        }

        // Calculate demand/supply ratio
        $demandSupplyRatio = $activeRides / $availableDrivers;

        // Apply surge multiplier based on ratio
        if ($demandSupplyRatio > 3.0) {
            return 2.5; // Very high demand
        } elseif ($demandSupplyRatio > 2.0) {
            return 2.0; // High demand
        } elseif ($demandSupplyRatio > 1.5) {
            return 1.5; // Medium demand
        } elseif ($demandSupplyRatio > 1.0) {
            return 1.3; // Slightly high demand
        }

        return 1.0; // Normal pricing
    }

    /**
     * Get count of active rides for category
     */
    protected function getActiveRidesCount(VehicleCategory $category): int
    {
        return Ride::whereIn('status', ['requested', 'searching', 'accepted', 'driver_arrived', 'in_progress'])
            ->where('vehicle_category_id', $category->id)
            ->where('created_at', '>', now()->subHour())
            ->count();
    }

    /**
     * Get count of available drivers for category
     */
    protected function getAvailableDriversCount(VehicleCategory $category): int
    {
        return DriverProfile::where('status', 'approved')
            ->where('is_online', true)
            ->where('is_available', true)
            ->whereHas('vehicles', function ($query) use ($category) {
                $query->where('vehicle_category_id', $category->id)
                    ->where('is_active', true);
            })
            ->count();
    }
}
