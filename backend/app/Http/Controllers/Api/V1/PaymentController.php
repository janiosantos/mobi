<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Payment\AddPaymentMethodRequest;
use App\Http\Resources\PaymentMethodResource;
use App\Http\Resources\PaymentResource;
use App\Models\PaymentMethod;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    /**
     * Get user's payment methods
     */
    public function methods(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            $paymentMethods = PaymentMethod::where('user_id', $user->id)
                ->orderBy('is_default', 'desc')
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'data' => PaymentMethodResource::collection($paymentMethods),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar métodos de pagamento.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Add new payment method
     */
    public function addMethod(AddPaymentMethodRequest $request): JsonResponse
    {
        try {
            $user = $request->user();
            $validated = $request->validated();

            // If this is the first payment method or is_default is true, set as default
            $isFirstMethod = PaymentMethod::where('user_id', $user->id)->count() === 0;
            $isDefault = $validated['is_default'] ?? $isFirstMethod;

            // If setting as default, unset other default methods
            if ($isDefault) {
                PaymentMethod::where('user_id', $user->id)
                    ->update(['is_default' => false]);
            }

            $paymentMethod = PaymentMethod::create([
                'user_id' => $user->id,
                'type' => $validated['type'],
                'is_default' => $isDefault,
                'card_token' => $validated['card_token'] ?? null,
                'card_last_four' => $validated['card_last_four'] ?? null,
                'card_brand' => $validated['card_brand'] ?? null,
                'card_holder_name' => $validated['card_holder_name'] ?? null,
                'card_expiry_month' => $validated['card_expiry_month'] ?? null,
                'card_expiry_year' => $validated['card_expiry_year'] ?? null,
                'pix_key' => $validated['pix_key'] ?? null,
                'pix_key_type' => $validated['pix_key_type'] ?? null,
                'is_verified' => true,
            ]);

            return response()->json([
                'message' => 'Método de pagamento adicionado com sucesso!',
                'data' => new PaymentMethodResource($paymentMethod),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao adicionar método de pagamento.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Set default payment method
     */
    public function setDefault(Request $request, PaymentMethod $paymentMethod): JsonResponse
    {
        try {
            $user = $request->user();

            if ($paymentMethod->user_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            // Unset other default methods
            PaymentMethod::where('user_id', $user->id)
                ->update(['is_default' => false]);

            // Set this as default
            $paymentMethod->update(['is_default' => true]);

            return response()->json([
                'message' => 'Método de pagamento padrão atualizado!',
                'data' => new PaymentMethodResource($paymentMethod),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao definir método padrão.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete payment method
     */
    public function deleteMethod(Request $request, PaymentMethod $paymentMethod): JsonResponse
    {
        try {
            $user = $request->user();

            if ($paymentMethod->user_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            $wasDefault = $paymentMethod->is_default;
            $paymentMethod->delete();

            // If deleted method was default, set another as default
            if ($wasDefault) {
                $newDefault = PaymentMethod::where('user_id', $user->id)->first();
                if ($newDefault) {
                    $newDefault->update(['is_default' => true]);
                }
            }

            return response()->json([
                'message' => 'Método de pagamento removido com sucesso!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao remover método de pagamento.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get payment history
     */
    public function history(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $perPage = $request->input('per_page', 15);

            $payments = Payment::whereHas('ride', function ($query) use ($user) {
                $query->where('passenger_id', $user->id)
                    ->orWhere('driver_id', $user->id);
            })
                ->with(['ride', 'paymentMethod'])
                ->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'data' => PaymentResource::collection($payments),
                'pagination' => [
                    'total' => $payments->total(),
                    'per_page' => $payments->perPage(),
                    'current_page' => $payments->currentPage(),
                    'last_page' => $payments->lastPage(),
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar histórico de pagamentos.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get specific payment details
     */
    public function show(Request $request, Payment $payment): JsonResponse
    {
        try {
            $user = $request->user();

            // Verify user has access to this payment
            $ride = $payment->ride;
            if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para ver este pagamento.',
                ], 403);
            }

            $payment->load(['ride', 'paymentMethod']);

            return response()->json([
                'data' => new PaymentResource($payment),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar pagamento.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
