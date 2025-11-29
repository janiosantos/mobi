<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\PaymentMethod\CreatePaymentMethodRequest;
use App\Http\Requests\PaymentMethod\UpdatePaymentMethodRequest;
use App\Http\Resources\PaymentMethodResource;
use App\Models\PaymentMethod;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentMethodController extends Controller
{
    /**
     * List all payment methods for authenticated user
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $paymentMethods = PaymentMethod::where('user_id', $user->id)
            ->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Payment methods retrieved successfully',
            'data' => PaymentMethodResource::collection($paymentMethods),
        ]);
    }

    /**
     * Add new payment method
     *
     * @param CreatePaymentMethodRequest $request
     * @return JsonResponse
     */
    public function store(CreatePaymentMethodRequest $request): JsonResponse
    {
        $user = $request->user();

        // If this is the first payment method, set as default
        $isFirstMethod = !PaymentMethod::where('user_id', $user->id)->exists();

        $paymentMethod = PaymentMethod::create([
            'user_id' => $user->id,
            'type' => $request->input('type'),
            'last_four' => $request->input('last_four'),
            'brand' => $request->input('brand'),
            'token' => $request->input('token'),
            'is_default' => $isFirstMethod || $request->input('is_default', false),
        ]);

        // If setting as default, unset others
        if ($paymentMethod->is_default) {
            PaymentMethod::where('user_id', $user->id)
                ->where('id', '!=', $paymentMethod->id)
                ->update(['is_default' => false]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Payment method added successfully',
            'data' => new PaymentMethodResource($paymentMethod),
        ], 201);
    }

    /**
     * Get specific payment method
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $paymentMethod = PaymentMethod::where('user_id', $user->id)
            ->find($id);

        if (!$paymentMethod) {
            return response()->json([
                'success' => false,
                'message' => 'Payment method not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Payment method retrieved successfully',
            'data' => new PaymentMethodResource($paymentMethod),
        ]);
    }

    /**
     * Update payment method
     *
     * @param UpdatePaymentMethodRequest $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(UpdatePaymentMethodRequest $request, int $id): JsonResponse
    {
        $user = $request->user();

        $paymentMethod = PaymentMethod::where('user_id', $user->id)
            ->find($id);

        if (!$paymentMethod) {
            return response()->json([
                'success' => false,
                'message' => 'Payment method not found',
            ], 404);
        }

        $paymentMethod->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Payment method updated successfully',
            'data' => new PaymentMethodResource($paymentMethod),
        ]);
    }

    /**
     * Delete payment method
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $paymentMethod = PaymentMethod::where('user_id', $user->id)
            ->find($id);

        if (!$paymentMethod) {
            return response()->json([
                'success' => false,
                'message' => 'Payment method not found',
            ], 404);
        }

        // If deleting default, set another as default
        if ($paymentMethod->is_default) {
            $nextMethod = PaymentMethod::where('user_id', $user->id)
                ->where('id', '!=', $paymentMethod->id)
                ->first();

            if ($nextMethod) {
                $nextMethod->update(['is_default' => true]);
            }
        }

        $paymentMethod->delete();

        return response()->json([
            'success' => true,
            'message' => 'Payment method deleted successfully',
        ]);
    }

    /**
     * Set payment method as default
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function setDefault(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $paymentMethod = PaymentMethod::where('user_id', $user->id)
            ->find($id);

        if (!$paymentMethod) {
            return response()->json([
                'success' => false,
                'message' => 'Payment method not found',
            ], 404);
        }

        // Unset all others as default
        PaymentMethod::where('user_id', $user->id)
            ->update(['is_default' => false]);

        // Set this one as default
        $paymentMethod->update(['is_default' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Default payment method updated successfully',
            'data' => new PaymentMethodResource($paymentMethod),
        ]);
    }
}
