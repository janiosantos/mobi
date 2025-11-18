<?php

namespace App\Listeners;

use App\Events\RideCompleted;
use App\Services\PaymentService;
use App\Models\Earning;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class ProcessRidePayment implements ShouldQueue
{
    use InteractsWithQueue;

    public function __construct(
        protected PaymentService $paymentService
    ) {}

    /**
     * Handle the event.
     */
    public function handle(RideCompleted $event): void
    {
        $ride = $event->ride;

        Log::info('Processing payment for completed ride', [
            'ride_id' => $ride->id,
            'amount' => $ride->final_price,
        ]);

        try {
            DB::transaction(function () use ($ride) {
                // Get passenger's default payment method
                $paymentMethod = $ride->passenger->paymentMethods()
                    ->where('is_default', true)
                    ->first();

                if (!$paymentMethod) {
                    Log::warning('No default payment method found', [
                        'ride_id' => $ride->id,
                        'passenger_id' => $ride->passenger_id,
                    ]);
                    return;
                }

                // Create payment based on method type
                if ($paymentMethod->type === 'pix') {
                    $payment = $this->paymentService->createPixPayment($ride);
                } else {
                    $payment = $this->paymentService->createCardPayment(
                        $ride,
                        $paymentMethod->card_token
                    );
                }

                // Create earning record for driver
                Earning::create([
                    'driver_id' => $ride->driver->driverProfile->id,
                    'ride_id' => $ride->id,
                    'amount' => $ride->final_price,
                    'platform_fee' => $ride->platform_fee,
                    'driver_earnings' => $ride->driver_earnings,
                    'payment_status' => 'pending',
                ]);

                // Update driver's earnings
                $ride->driver->driverProfile->increment('total_earnings', $ride->driver_earnings);
                $ride->driver->driverProfile->increment('available_balance', $ride->driver_earnings);

                Log::info('Payment processed successfully', [
                    'ride_id' => $ride->id,
                    'payment_id' => $payment->id,
                ]);
            });
        } catch (\Exception $e) {
            Log::error('Failed to process ride payment', [
                'ride_id' => $ride->id,
                'error' => $e->getMessage(),
            ]);

            // Retry the job up to 3 times
            $this->release(30);
        }
    }
}
