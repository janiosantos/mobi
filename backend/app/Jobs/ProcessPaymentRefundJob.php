<?php

namespace App\Jobs;

use App\Models\Payment;
use App\Services\PaymentService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class ProcessPaymentRefundJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     */
    public $tries = 3;

    /**
     * The number of seconds the job can run before timing out.
     */
    public $timeout = 60;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public Payment $payment,
        public float $refundAmount,
        public string $reason
    ) {}

    /**
     * Execute the job.
     */
    public function handle(PaymentService $paymentService): void
    {
        try {
            DB::transaction(function () use ($paymentService) {
                // Process refund via payment provider
                $refundResult = $paymentService->processRefund(
                    $this->payment,
                    $this->refundAmount
                );

                // Update payment record
                $this->payment->update([
                    'refunded_at' => now(),
                    'refund_amount' => $this->refundAmount,
                    'metadata' => array_merge(
                        $this->payment->metadata ?? [],
                        [
                            'refund_reason' => $this->reason,
                            'refund_id' => $refundResult['refund_id'] ?? null,
                        ]
                    ),
                ]);

                // Update ride
                if ($this->payment->ride) {
                    $this->payment->ride->update([
                        'final_price' => $this->payment->ride->final_price - $this->refundAmount,
                    ]);
                }

                // Adjust driver earnings if applicable
                if ($this->payment->ride && $this->payment->ride->driver_id) {
                    $driverProfile = $this->payment->ride->driver->driverProfile;
                    $driverProfile->decrement('total_earnings', $this->refundAmount);
                    $driverProfile->decrement('available_balance', $this->refundAmount);
                }

                Log::info('Payment refund processed successfully', [
                    'payment_id' => $this->payment->id,
                    'refund_amount' => $this->refundAmount,
                ]);
            });
        } catch (\Exception $e) {
            Log::error('Error processing payment refund', [
                'payment_id' => $this->payment->id,
                'error' => $e->getMessage(),
            ]);

            // Retry the job
            $this->release(60);
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('Payment refund job failed after all retries', [
            'payment_id' => $this->payment->id,
            'error' => $exception->getMessage(),
        ]);
    }
}
