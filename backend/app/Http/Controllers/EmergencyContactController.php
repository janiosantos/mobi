<?php

namespace App\Http\Controllers;

use App\Models\EmergencyContact;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EmergencyContactController extends Controller
{
    /**
     * Get all emergency contacts.
     */
    public function index(Request $request): JsonResponse
    {
        $contacts = EmergencyContact::where('user_id', $request->user()->id)
            ->orderBy('is_primary', 'desc')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Emergency contacts retrieved successfully',
            'data' => $contacts
        ]);
    }

    /**
     * Create emergency contact.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'relationship' => 'nullable|string|max:50',
            'is_primary' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $contact = EmergencyContact::create([
            'user_id' => $request->user()->id,
            'name' => $request->input('name'),
            'phone' => $request->input('phone'),
            'relationship' => $request->input('relationship'),
            'is_primary' => $request->input('is_primary', false),
        ]);

        if ($request->input('is_primary', false)) {
            $contact->setAsPrimary();
        }

        return response()->json([
            'success' => true,
            'message' => 'Emergency contact created successfully',
            'data' => $contact
        ], 201);
    }

    /**
     * Update emergency contact.
     */
    public function update(Request $request, EmergencyContact $contact): JsonResponse
    {
        if ($contact->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:100',
            'phone' => 'string|max:20',
            'relationship' => 'nullable|string|max:50',
            'is_primary' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $contact->update($request->only(['name', 'phone', 'relationship', 'is_primary']));

        if ($request->has('is_primary') && $request->input('is_primary')) {
            $contact->setAsPrimary();
        }

        return response()->json([
            'success' => true,
            'message' => 'Emergency contact updated successfully',
            'data' => $contact->fresh()
        ]);
    }

    /**
     * Delete emergency contact.
     */
    public function destroy(Request $request, EmergencyContact $contact): JsonResponse
    {
        if ($contact->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $contact->delete();

        return response()->json([
            'success' => true,
            'message' => 'Emergency contact deleted successfully'
        ]);
    }
}
