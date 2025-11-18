<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class SendSMSJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     */
    public $tries = 3;

    /**
     * The number of seconds the job can run before timing out.
     */
    public $timeout = 30;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public string $to,
        public string $message
    ) {}

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            $accountSid = config('services.twilio.account_sid');
            $authToken = config('services.twilio.auth_token');
            $fromNumber = config('services.twilio.from_number');

            $url = "https://api.twilio.com/2010-04-01/Accounts/{$accountSid}/Messages.json";

            $response = Http::asForm()
                ->withBasicAuth($accountSid, $authToken)
                ->post($url, [
                    'From' => $fromNumber,
                    'To' => $this->to,
                    'Body' => $this->message,
                ]);

            if ($response->successful()) {
                Log::info('SMS sent successfully', [
                    'to' => $this->to,
                    'sid' => $response->json('sid'),
                ]);
            } else {
                Log::error('Failed to send SMS', [
                    'to' => $this->to,
                    'response' => $response->json(),
                ]);

                // Retry the job
                $this->release(30);
            }
        } catch (\Exception $e) {
            Log::error('Error sending SMS', [
                'to' => $this->to,
                'error' => $e->getMessage(),
            ]);

            // Retry the job
            $this->release(30);
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('SMS job failed after all retries', [
            'to' => $this->to,
            'error' => $exception->getMessage(),
        ]);
    }
}
