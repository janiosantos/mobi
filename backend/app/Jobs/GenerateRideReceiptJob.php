<?php

namespace App\Jobs;

use App\Models\Ride;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Barryvdh\DomPDF\Facade\Pdf;

class GenerateRideReceiptJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     */
    public $tries = 2;

    /**
     * The number of seconds the job can run before timing out.
     */
    public $timeout = 120;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public Ride $ride
    ) {}

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            // Load relationships
            $this->ride->load(['passenger', 'driver', 'vehicle', 'category', 'payment']);

            // Generate PDF
            $pdf = Pdf::loadView('receipts.ride', [
                'ride' => $this->ride,
            ]);

            // Save PDF
            $filename = "receipts/ride-{$this->ride->ride_number}.pdf";
            Storage::disk('private')->put($filename, $pdf->output());

            // Update ride with receipt path
            $this->ride->update([
                'receipt_url' => $filename,
            ]);

            Log::info('Ride receipt generated successfully', [
                'ride_id' => $this->ride->id,
                'receipt_url' => $filename,
            ]);

            // Send receipt via email
            if ($this->ride->passenger->email) {
                SendEmailJob::dispatch(
                    $this->ride->passenger->email,
                    'Recibo da sua corrida - MOBI',
                    'emails.ride-receipt',
                    [
                        'ride' => $this->ride,
                        'receipt_url' => Storage::disk('private')->url($filename),
                    ]
                );
            }
        } catch (\Exception $e) {
            Log::error('Error generating ride receipt', [
                'ride_id' => $this->ride->id,
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
        Log::error('Generate ride receipt job failed after all retries', [
            'ride_id' => $this->ride->id,
            'error' => $exception->getMessage(),
        ]);
    }
}
