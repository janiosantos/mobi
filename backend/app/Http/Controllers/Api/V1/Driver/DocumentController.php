<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Requests\Driver\UploadDocumentRequest;
use App\Http\Resources\DriverDocumentResource;
use App\Models\DriverDocument;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class DocumentController extends Controller
{
    /**
     * List all documents for driver
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $documents = DriverDocument::where('driver_profile_id', $driverProfile->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Documents retrieved successfully',
            'data' => DriverDocumentResource::collection($documents),
        ]);
    }

    /**
     * Upload new document
     *
     * @param UploadDocumentRequest $request
     * @return JsonResponse
     */
    public function store(UploadDocumentRequest $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $file = $request->file('document');
        $type = $request->input('type');

        // Store file
        $path = $file->store('documents/drivers/' . $driverProfile->id, 'public');

        // Create document record
        $document = DriverDocument::create([
            'driver_profile_id' => $driverProfile->id,
            'type' => $type,
            'file_url' => $path,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Document uploaded successfully',
            'data' => new DriverDocumentResource($document),
        ], 201);
    }

    /**
     * Get specific document
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $document = DriverDocument::where('driver_profile_id', $driverProfile->id)
            ->find($id);

        if (!$document) {
            return response()->json([
                'success' => false,
                'message' => 'Document not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Document retrieved successfully',
            'data' => new DriverDocumentResource($document),
        ]);
    }

    /**
     * Delete document
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $document = DriverDocument::where('driver_profile_id', $driverProfile->id)
            ->find($id);

        if (!$document) {
            return response()->json([
                'success' => false,
                'message' => 'Document not found',
            ], 404);
        }

        // Can't delete approved documents
        if ($document->status === 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete approved documents',
            ], 422);
        }

        // Delete file from storage
        Storage::disk('public')->delete($document->file_url);

        // Delete record
        $document->delete();

        return response()->json([
            'success' => true,
            'message' => 'Document deleted successfully',
        ]);
    }

    /**
     * Get document approval status summary
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function status(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $documents = DriverDocument::where('driver_profile_id', $driverProfile->id)->get();

        $statusSummary = [
            'total' => $documents->count(),
            'pending' => $documents->where('status', 'pending')->count(),
            'approved' => $documents->where('status', 'approved')->count(),
            'rejected' => $documents->where('status', 'rejected')->count(),
        ];

        // Required document types
        $requiredTypes = ['cnh', 'vehicle_registration', 'insurance', 'photo'];
        $missingTypes = collect($requiredTypes)->diff($documents->pluck('type'))->values();

        $allApproved = $documents->count() >= count($requiredTypes)
            && $documents->where('status', 'approved')->count() >= count($requiredTypes);

        return response()->json([
            'success' => true,
            'message' => 'Document status retrieved successfully',
            'data' => [
                'status_summary' => $statusSummary,
                'missing_types' => $missingTypes,
                'all_approved' => $allApproved,
                'driver_approval_status' => $driverProfile->approval_status,
            ],
        ]);
    }
}
