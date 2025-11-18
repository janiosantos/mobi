<?php

namespace App\Jobs;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class SendPushNotificationJob implements ShouldQueue
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
        public User $user,
        public string $title,
        public string $body,
        public array $data = []
    ) {}

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        if (!$this->user->device_token) {
            Log::warning('User has no device token', ['user_id' => $this->user->id]);
            return;
        }

        try {
            $fcmUrl = 'https://fcm.googleapis.com/fcm/send';
            $serverKey = config('services.fcm.server_key');

            $notification = [
                'title' => $this->title,
                'body' => $this->body,
                'sound' => 'default',
                'badge' => '1',
            ];

            $payload = [
                'to' => $this->user->device_token,
                'notification' => $notification,
                'data' => $this->data,
                'priority' => 'high',
            ];

            $response = Http::withHeaders([
                'Authorization' => 'key=' . $serverKey,
                'Content-Type' => 'application/json',
            ])->post($fcmUrl, $payload);

            if ($response->successful()) {
                Log::info('Push notification sent successfully', [
                    'user_id' => $this->user->id,
                    'title' => $this->title,
                ]);
            } else {
                Log::error('Failed to send push notification', [
                    'user_id' => $this->user->id,
                    'response' => $response->json(),
                ]);

                // If token is invalid, clear it
                if ($response->status() === 400) {
                    $this->user->update(['device_token' => null]);
                }
            }
        } catch (\Exception $e) {
            Log::error('Error sending push notification', [
                'user_id' => $this->user->id,
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
        Log::error('Push notification job failed after all retries', [
            'user_id' => $this->user->id,
            'error' => $exception->getMessage(),
        ]);
    }
}
