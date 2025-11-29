<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Requests\Profile\UploadPhotoRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Facades\Image;

class ProfileController extends Controller
{
    /**
     * Get authenticated user profile
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load(['driverProfile', 'stats']);

        return response()->json([
            'success' => true,
            'message' => 'Profile retrieved successfully',
            'data' => new UserResource($user),
        ]);
    }

    /**
     * Update user profile
     *
     * @param UpdateProfileRequest $request
     * @return JsonResponse
     */
    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();

        $user->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => new UserResource($user->fresh()),
        ]);
    }

    /**
     * Upload profile photo
     *
     * @param UploadPhotoRequest $request
     * @return JsonResponse
     */
    public function uploadPhoto(UploadPhotoRequest $request): JsonResponse
    {
        $user = $request->user();

        // Delete old photo if exists
        if ($user->profile_photo_url) {
            Storage::disk('public')->delete($user->profile_photo_url);
        }

        $photo = $request->file('photo');

        // Resize and optimize image
        $image = Image::make($photo)
            ->fit(500, 500)
            ->encode('jpg', 85);

        // Generate unique filename
        $filename = 'profiles/' . $user->id . '_' . time() . '.jpg';

        // Store image
        Storage::disk('public')->put($filename, $image->stream());

        // Update user
        $user->update([
            'profile_photo_url' => $filename,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profile photo uploaded successfully',
            'data' => [
                'profile_photo_url' => Storage::url($filename),
            ],
        ]);
    }

    /**
     * Delete profile photo
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function deletePhoto(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->profile_photo_url) {
            return response()->json([
                'success' => false,
                'message' => 'No profile photo to delete',
            ], 404);
        }

        // Delete from storage
        Storage::disk('public')->delete($user->profile_photo_url);

        // Update user
        $user->update([
            'profile_photo_url' => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profile photo deleted successfully',
        ]);
    }
}
