<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentWebhookController extends Controller
{
    /**
     * Handle EFI (Gerencianet) webhook.
     */
    public function efi(Request $request): JsonResponse
    {
        try {
            // Validate webhook signature
            $signature = $request->header('X-Gerencianet-Signature');
            $secret = config('services.efi.webhook_secret');

            if (!$this->validateEfiSignature($signature, $request->getContent(), $secret)) {
                Log::warning('EFI webhook signature validation failed');
                return response()->json(['error' => 'Invalid signature'], 401);
            }

            $data = $request->all();

            Log::info('EFI Webhook received', $data);

            // Process payment status update
            if (isset($data['charge_id'])) {
                $this->updatePaymentStatus($data['charge_id'], $data['status'] ?? 'unknown', 'efi');
            }

            return response()->json(['status' => 'success']);
        } catch (\Exception $e) {
            Log::error('EFI Webhook error: ' . $e->getMessage());
            return response()->json(['error' => 'Webhook processing failed'], 500);
        }
    }

    /**
     * Handle Stone webhook.
     */
    public function stone(Request $request): JsonResponse
    {
        try {
            $signature = $request->header('X-Stone-Signature');
            $secret = config('services.stone.webhook_secret');

            if (!$this->validateStoneSignature($signature, $request->getContent(), $secret)) {
                Log::warning('Stone webhook signature validation failed');
                return response()->json(['error' => 'Invalid signature'], 401);
            }

            $data = $request->all();

            Log::info('Stone Webhook received', $data);

            if (isset($data['id'])) {
                $this->updatePaymentStatus($data['id'], $data['status'] ?? 'unknown', 'stone');
            }

            return response()->json(['status' => 'success']);
        } catch (\Exception $e) {
            Log::error('Stone Webhook error: ' . $e->getMessage());
            return response()->json(['error' => 'Webhook processing failed'], 500);
        }
    }

    /**
     * Handle PagSeguro webhook.
     */
    public function pagseguro(Request $request): JsonResponse
    {
        try {
            $notificationCode = $request->input('notificationCode');
            $notificationType = $request->input('notificationType');

            if (!$notificationCode || !$notificationType) {
                return response()->json(['error' => 'Missing notification data'], 400);
            }

            Log::info('PagSeguro Webhook received', [
                'code' => $notificationCode,
                'type' => $notificationType,
            ]);

            // In production, fetch transaction details from PagSeguro API
            // For now, just acknowledge receipt
            return response()->json(['status' => 'success']);
        } catch (\Exception $e) {
            Log::error('PagSeguro Webhook error: ' . $e->getMessage());
            return response()->json(['error' => 'Webhook processing failed'], 500);
        }
    }

    /**
     * Handle Cielo webhook.
     */
    public function cielo(Request $request): JsonResponse
    {
        try {
            $signature = $request->header('X-Cielo-Signature');
            $secret = config('services.cielo.webhook_secret');

            if (!$this->validateCieloSignature($signature, $request->getContent(), $secret)) {
                Log::warning('Cielo webhook signature validation failed');
                return response()->json(['error' => 'Invalid signature'], 401);
            }

            $data = $request->all();

            Log::info('Cielo Webhook received', $data);

            if (isset($data['PaymentId'])) {
                $status = $this->mapCieloStatus($data['Status'] ?? 0);
                $this->updatePaymentStatus($data['PaymentId'], $status, 'cielo');
            }

            return response()->json(['status' => 'success']);
        } catch (\Exception $e) {
            Log::error('Cielo Webhook error: ' . $e->getMessage());
            return response()->json(['error' => 'Webhook processing failed'], 500);
        }
    }

    /**
     * Validate EFI webhook signature.
     */
    private function validateEfiSignature(string $signature, string $payload, string $secret): bool
    {
        $calculatedSignature = hash_hmac('sha256', $payload, $secret);
        return hash_equals($calculatedSignature, $signature);
    }

    /**
     * Validate Stone webhook signature.
     */
    private function validateStoneSignature(string $signature, string $payload, string $secret): bool
    {
        $calculatedSignature = hash_hmac('sha256', $payload, $secret);
        return hash_equals($calculatedSignature, $signature);
    }

    /**
     * Validate Cielo webhook signature.
     */
    private function validateCieloSignature(string $signature, string $payload, string $secret): bool
    {
        $calculatedSignature = hash_hmac('sha256', $payload, $secret);
        return hash_equals($calculatedSignature, $signature);
    }

    /**
     * Update payment status in database.
     */
    private function updatePaymentStatus(string $transactionId, string $status, string $gateway): void
    {
        $payment = Payment::where('transaction_id', $transactionId)
            ->where('gateway', $gateway)
            ->first();

        if ($payment) {
            $payment->update(['status' => $status]);
            Log::info("Payment {$transactionId} updated to status: {$status}");
        } else {
            Log::warning("Payment not found for transaction: {$transactionId}");
        }
    }

    /**
     * Map Cielo status codes to standard statuses.
     */
    private function mapCieloStatus(int $statusCode): string
    {
        return match ($statusCode) {
            0 => 'pending',
            1, 2 => 'approved',
            3 => 'declined',
            10 => 'cancelled',
            11 => 'refunded',
            12 => 'pending',
            default => 'unknown',
        };
    }
}
