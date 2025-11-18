<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class SendEmailJob implements ShouldQueue
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
        public string $subject,
        public string $view,
        public array $data = []
    ) {}

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            Mail::send($this->view, $this->data, function ($message) {
                $message->to($this->to)
                    ->subject($this->subject)
                    ->from(config('mail.from.address'), config('mail.from.name'));
            });

            Log::info('Email sent successfully', [
                'to' => $this->to,
                'subject' => $this->subject,
            ]);
        } catch (\Exception $e) {
            Log::error('Error sending email', [
                'to' => $this->to,
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
        Log::error('Email job failed after all retries', [
            'to' => $this->to,
            'subject' => $this->subject,
            'error' => $exception->getMessage(),
        ]);
    }
}
