<?php

namespace App\Services;

use App\Models\Ride;
use App\Models\Payment;
use App\Models\PaymentMethod;
use App\DTOs\PaymentDTO;
use MercadoPago\SDK;
use MercadoPago\Payment as MPPayment;
use MercadoPago\Payer;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class PaymentService
{
    public function __construct()
    {
        SDK::setAccessToken(config('services.mercadopago.access_token'));
    }

    /**
     * Create PIX payment
     */
    public function createPixPayment(Ride $ride): Payment
    {
        return DB::transaction(function () use ($ride) {
            try {
                // Create MercadoPago payment
                $payment = new MPPayment();
                $payment->transaction_amount = $ride->final_price ?? $ride->estimated_price;
                $payment->description = "Corrida {$ride->ride_number}";
                $payment->payment_method_id = "pix";
                $payment->notification_url = route('webhooks.mercadopago');

                // Payer info
                $payer = new Payer();
                $payer->email = $ride->passenger->email;
                $payer->first_name = explode(' ', $ride->passenger->name)[0];
                $payer->last_name = implode(' ', array_slice(explode(' ', $ride->passenger->name), 1)) ?: '-';

                if ($ride->passenger->cpf) {
                    $payer->identification = [
                        "type" => "CPF",
                        "number" => $ride->passenger->cpf
                    ];
                }

                $payment->payer = $payer;

                // Save payment
                $payment->save();

                // Create local payment record
                $localPayment = Payment::create([
                    'payment_number' => $this->generatePaymentNumber(),
                    'ride_id' => $ride->id,
                    'user_id' => $ride->passenger_id,
                    'payment_type' => 'pix',
                    'amount' => $ride->final_price ?? $ride->estimated_price,
                    'platform_fee' => $ride->platform_fee,
                    'driver_amount' => $ride->driver_earnings,
                    'status' => 'pending',
                    'gateway' => 'mercadopago',
                    'gateway_payment_id' => $payment->id,
                    'gateway_transaction_id' => $payment->id,
                    'pix_qr_code' => $payment->point_of_interaction->transaction_data->qr_code ?? null,
                    'pix_qr_code_base64' => $payment->point_of_interaction->transaction_data->qr_code_base64 ?? null,
                    'pix_transaction_id' => $payment->point_of_interaction->transaction_data->transaction_id ?? null,
                    'pix_expires_at' => now()->addHours(24),
                ]);

                Log::info('PIX payment created', [
                    'payment_id' => $localPayment->id,
                    'ride_id' => $ride->id,
                    'mp_payment_id' => $payment->id,
                ]);

                return $localPayment;
            } catch (\Exception $e) {
                Log::error('PIX payment creation failed', [
                    'ride_id' => $ride->id,
                    'error' => $e->getMessage(),
                ]);

                throw new \Exception('Failed to create PIX payment: ' . $e->getMessage());
            }
        });
    }

    /**
     * Create card payment
     */
    public function createCardPayment(Ride $ride, PaymentMethod $paymentMethod, int $installments = 1): Payment
    {
        return DB::transaction(function () use ($ride, $paymentMethod, $installments) {
            try {
                $payment = new MPPayment();
                $payment->transaction_amount = $ride->final_price ?? $ride->estimated_price;
                $payment->token = $paymentMethod->card_token;
                $payment->description = "Corrida {$ride->ride_number}";
                $payment->installments = $installments;
                $payment->payment_method_id = strtolower($paymentMethod->card_brand);
                $payment->notification_url = route('webhooks.mercadopago');

                // Payer info
                $payer = new Payer();
                $payer->email = $ride->passenger->email;
                $payer->first_name = explode(' ', $ride->passenger->name)[0];
                $payer->last_name = implode(' ', array_slice(explode(' ', $ride->passenger->name), 1)) ?: '-';

                if ($ride->passenger->cpf) {
                    $payer->identification = [
                        "type" => "CPF",
                        "number" => $ride->passenger->cpf
                    ];
                }

                $payment->payer = $payer;

                // Save payment
                $payment->save();

                // Create local payment record
                $localPayment = Payment::create([
                    'payment_number' => $this->generatePaymentNumber(),
                    'ride_id' => $ride->id,
                    'user_id' => $ride->passenger_id,
                    'payment_method_id' => $paymentMethod->id,
                    'payment_type' => $paymentMethod->type,
                    'amount' => $ride->final_price ?? $ride->estimated_price,
                    'platform_fee' => $ride->platform_fee,
                    'driver_amount' => $ride->driver_earnings,
                    'status' => $payment->status === 'approved' ? 'completed' : 'processing',
                    'gateway' => 'mercadopago',
                    'gateway_payment_id' => $payment->id,
                    'gateway_transaction_id' => $payment->id,
                    'card_brand' => $paymentMethod->card_brand,
                    'card_last_four' => $paymentMethod->card_last_four,
                    'installments' => $installments,
                    'processed_at' => $payment->status === 'approved' ? now() : null,
                ]);

                Log::info('Card payment created', [
                    'payment_id' => $localPayment->id,
                    'ride_id' => $ride->id,
                    'mp_payment_id' => $payment->id,
                    'status' => $payment->status,
                ]);

                return $localPayment;
            } catch (\Exception $e) {
                Log::error('Card payment creation failed', [
                    'ride_id' => $ride->id,
                    'error' => $e->getMessage(),
                ]);

                throw new \Exception('Failed to process card payment: ' . $e->getMessage());
            }
        });
    }

    /**
     * Check payment status
     */
    public function checkPaymentStatus(Payment $payment): string
    {
        try {
            $mpPayment = MPPayment::find_by_id($payment->gateway_payment_id);

            if (!$mpPayment) {
                return 'unknown';
            }

            // Update local payment
            $payment->update([
                'status' => $this->mapMercadoPagoStatus($mpPayment->status),
                'gateway_response' => json_encode($mpPayment),
            ]);

            Log::info('Payment status checked', [
                'payment_id' => $payment->id,
                'mp_status' => $mpPayment->status,
                'local_status' => $payment->status,
            ]);

            return $payment->status;
        } catch (\Exception $e) {
            Log::error('Payment status check failed', [
                'payment_id' => $payment->id,
                'error' => $e->getMessage(),
            ]);

            return 'error';
        }
    }

    /**
     * Process webhook notification from MercadoPago
     */
    public function processWebhook(array $data): void
    {
        try {
            if ($data['type'] !== 'payment') {
                return;
            }

            $mpPaymentId = $data['data']['id'];
            $mpPayment = MPPayment::find_by_id($mpPaymentId);

            if (!$mpPayment) {
                Log::warning('MercadoPago payment not found in webhook', ['mp_payment_id' => $mpPaymentId]);
                return;
            }

            $payment = Payment::where('gateway_payment_id', $mpPaymentId)->first();

            if (!$payment) {
                Log::warning('Local payment not found for MP webhook', ['mp_payment_id' => $mpPaymentId]);
                return;
            }

            $newStatus = $this->mapMercadoPagoStatus($mpPayment->status);

            $payment->update([
                'status' => $newStatus,
                'gateway_response' => json_encode($mpPayment),
                'processed_at' => $mpPayment->status === 'approved' ? now() : $payment->processed_at,
                'failed_at' => $mpPayment->status === 'rejected' ? now() : null,
                'failure_reason' => $mpPayment->status === 'rejected' ? $mpPayment->status_detail : null,
            ]);

            // Update ride payment status
            $payment->ride->update([
                'payment_status' => $newStatus,
                'payment_id' => $payment->id,
            ]);

            Log::info('Webhook processed', [
                'payment_id' => $payment->id,
                'mp_payment_id' => $mpPaymentId,
                'status' => $newStatus,
            ]);
        } catch (\Exception $e) {
            Log::error('Webhook processing failed', [
                'error' => $e->getMessage(),
                'data' => $data,
            ]);
        }
    }

    /**
     * Map MercadoPago status to local status
     */
    protected function mapMercadoPagoStatus(string $mpStatus): string
    {
        return match ($mpStatus) {
            'approved' => 'completed',
            'pending', 'in_process' => 'processing',
            'rejected', 'cancelled' => 'failed',
            'refunded' => 'refunded',
            default => 'pending',
        };
    }

    /**
     * Generate unique payment number
     */
    protected function generatePaymentNumber(): string
    {
        do {
            $number = 'PAY-' . strtoupper(Str::random(10));
        } while (Payment::where('payment_number', $number)->exists());

        return $number;
    }

    /**
     * Refund a payment
     */
    public function refund(Payment $payment, float $amount, string $reason): bool
    {
        try {
            // MercadoPago refund logic would go here
            // For now, just mark as refunded locally

            $payment->update([
                'status' => 'refunded',
                'refund_amount' => $amount,
                'refund_reason' => $reason,
                'refunded_at' => now(),
            ]);

            Log::info('Payment refunded', [
                'payment_id' => $payment->id,
                'amount' => $amount,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::error('Payment refund failed', [
                'payment_id' => $payment->id,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }
}
