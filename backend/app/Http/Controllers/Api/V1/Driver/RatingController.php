<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Requests\Ride\RateRideRequest;
use App\Http\Resources\RatingResource;
use App\Models\Rating;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RatingController extends Controller
{
    /**
     * Rate passenger after ride
     *
     * @param RateRideRequest $request
     * @param int $rideId
     * @return JsonResponse
     */
    public function ratePassenger(RateRideRequest $request, int $rideId): JsonResponse
    {
        $user = $request->user();

        $ride = Ride::where('driver_id', $user->id)
            ->where('id', $rideId)
            ->where('status', 'completed')
            ->first();

        if (!$ride) {
            return response()->json([
                'success' => false,
                'message' => 'Ride not found or not completed',
            ], 404);
        }

        // Check if already rated
        $existingRating = Rating::where('ride_id', $ride->id)
            ->where('rater_id', $user->id)
            ->first();

        if ($existingRating) {
            return response()->json([
                'success' => false,
                'message' => 'You have already rated this ride',
            ], 422);
        }

        // Create rating
        $rating = Rating::create([
            'ride_id' => $ride->id,
            'rater_id' => $user->id,
            'rated_id' => $ride->passenger_id,
            'stars' => $request->input('stars'),
            'comment' => $request->input('comment'),
            'tags' => $request->input('tags', []),
        ]);

        // Update passenger average rating
        $passenger = $ride->passenger;
        $avgRating = Rating::where('rated_id', $passenger->id)->avg('stars');
        $totalRatings = Rating::where('rated_id', $passenger->id)->count();

        $passenger->update([
            'average_rating' => round($avgRating, 2),
            'total_ratings' => $totalRatings,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Rating submitted successfully',
            'data' => new RatingResource($rating),
        ], 201);
    }

    /**
     * Get ratings given by driver
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $ratings = Rating::where('rater_id', $user->id)
            ->with(['ride', 'rated'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'message' => 'Ratings retrieved successfully',
            'data' => RatingResource::collection($ratings->items()),
            'meta' => [
                'current_page' => $ratings->currentPage(),
                'last_page' => $ratings->lastPage(),
                'per_page' => $ratings->perPage(),
                'total' => $ratings->total(),
            ],
        ]);
    }
}
