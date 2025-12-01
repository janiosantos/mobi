<?php

namespace App\Http\Controllers;

use App\Models\SavedPlace;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SavedPlaceController extends Controller
{
    /**
     * Get all saved places for authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $places = SavedPlace::where('user_id', $request->user()->id)
            ->orderBy('is_default', 'desc')
            ->orderBy('type')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Saved places retrieved successfully',
            'data' => $places
        ]);
    }

    /**
     * Store a new saved place.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:home,work,favorite',
            'label' => 'required|string|max:100',
            'address' => 'required|string|max:255',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'is_default' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $place = SavedPlace::create([
            'user_id' => $request->user()->id,
            'type' => $request->input('type'),
            'label' => $request->input('label'),
            'address' => $request->input('address'),
            'latitude' => $request->input('latitude'),
            'longitude' => $request->input('longitude'),
            'is_default' => $request->input('is_default', false),
        ]);

        if ($request->input('is_default', false)) {
            $place->setAsDefault();
        }

        return response()->json([
            'success' => true,
            'message' => 'Saved place created successfully',
            'data' => $place
        ], 201);
    }

    /**
     * Get a specific saved place.
     */
    public function show(Request $request, SavedPlace $savedPlace): JsonResponse
    {
        // Verify ownership
        if ($savedPlace->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Saved place retrieved successfully',
            'data' => $savedPlace
        ]);
    }

    /**
     * Update a saved place.
     */
    public function update(Request $request, SavedPlace $savedPlace): JsonResponse
    {
        // Verify ownership
        if ($savedPlace->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'type' => 'in:home,work,favorite',
            'label' => 'string|max:100',
            'address' => 'string|max:255',
            'latitude' => 'numeric|between:-90,90',
            'longitude' => 'numeric|between:-180,180',
            'is_default' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $savedPlace->update($request->only([
            'type',
            'label',
            'address',
            'latitude',
            'longitude',
            'is_default',
        ]));

        if ($request->has('is_default') && $request->input('is_default')) {
            $savedPlace->setAsDefault();
        }

        return response()->json([
            'success' => true,
            'message' => 'Saved place updated successfully',
            'data' => $savedPlace->fresh()
        ]);
    }

    /**
     * Delete a saved place.
     */
    public function destroy(Request $request, SavedPlace $savedPlace): JsonResponse
    {
        // Verify ownership
        if ($savedPlace->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $savedPlace->delete();

        return response()->json([
            'success' => true,
            'message' => 'Saved place deleted successfully'
        ]);
    }

    /**
     * Set a saved place as default.
     */
    public function setAsDefault(Request $request, SavedPlace $savedPlace): JsonResponse
    {
        // Verify ownership
        if ($savedPlace->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $savedPlace->setAsDefault();

        return response()->json([
            'success' => true,
            'message' => 'Default place updated successfully',
            'data' => $savedPlace->fresh()
        ]);
    }

    /**
     * Get saved places by type.
     */
    public function byType(Request $request, string $type): JsonResponse
    {
        if (!in_array($type, ['home', 'work', 'favorite'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid type'
            ], 400);
        }

        $places = SavedPlace::where('user_id', $request->user()->id)
            ->byType($type)
            ->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Saved places retrieved successfully',
            'data' => $places
        ]);
    }
}
