<?php

namespace App\Http\Controllers;

use App\Models\VehicleCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VehicleCategoryController extends Controller
{
    /**
     * Get all active vehicle categories.
     */
    public function index(Request $request): JsonResponse
    {
        $categories = VehicleCategory::active()->ordered()->get();

        return response()->json([
            'data' => $categories
        ]);
    }

    /**
     * Get a specific category by slug.
     */
    public function show(string $slug): JsonResponse
    {
        $category = VehicleCategory::bySlug($slug)->active()->first();

        if (!$category) {
            return response()->json([
                'message' => 'Category not found'
            ], 404);
        }

        return response()->json([
            'data' => $category
        ]);
    }

    /**
     * Calculate estimated price for a category.
     */
    public function estimatePrice(Request $request, string $slug): JsonResponse
    {
        $category = VehicleCategory::bySlug($slug)->active()->first();

        if (!$category) {
            return response()->json([
                'message' => 'Category not found'
            ], 404);
        }

        $distanceKm = $request->input('distance_km', 0);
        $durationMinutes = $request->input('duration_minutes', 0);

        $estimatedPrice = $category->calculatePrice($distanceKm, $durationMinutes);

        return response()->json([
            'data' => [
                'category' => $category->only(['id', 'name', 'slug', 'icon']),
                'distance_km' => $distanceKm,
                'duration_minutes' => $durationMinutes,
                'base_fare' => $category->base_fare,
                'distance_fare' => round($distanceKm * $category->per_km_rate, 2),
                'time_fare' => round($durationMinutes * $category->per_minute_rate, 2),
                'estimated_price' => round($estimatedPrice, 2),
                'minimum_fare' => $category->minimum_fare,
            ]
        ]);
    }

    /**
     * Get price comparison for all categories.
     */
    public function comparePrice(Request $request): JsonResponse
    {
        $distanceKm = $request->input('distance_km', 0);
        $durationMinutes = $request->input('duration_minutes', 0);

        $categories = VehicleCategory::active()->ordered()->get();

        $comparisons = $categories->map(function ($category) use ($distanceKm, $durationMinutes) {
            return [
                'id' => $category->id,
                'name' => $category->name,
                'slug' => $category->slug,
                'icon' => $category->icon,
                'capacity' => $category->capacity,
                'features' => $category->features,
                'estimated_price' => round($category->calculatePrice($distanceKm, $durationMinutes), 2),
                'price_breakdown' => [
                    'base_fare' => $category->base_fare,
                    'distance_fare' => round($distanceKm * $category->per_km_rate, 2),
                    'time_fare' => round($durationMinutes * $category->per_minute_rate, 2),
                ],
            ];
        });

        return response()->json([
            'data' => $comparisons
        ]);
    }
}
