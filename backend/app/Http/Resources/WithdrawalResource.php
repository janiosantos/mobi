<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WithdrawalResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'withdrawal_number' => $this->withdrawal_number,
            'driver_id' => $this->driver_id,
            'amount' => number_format($this->amount, 2, '.', ''),
            'withdrawal_method' => $this->withdrawal_method,
            'status' => $this->status,
            'bank_account' => $this->when(
                $this->withdrawal_method === 'bank_transfer',
                [
                    'bank_name' => $this->bank_name,
                    'account_type' => $this->bank_account_type,
                    'agency' => $this->bank_agency,
                    'account' => $this->bank_account,
                ]
            ),
            'pix' => $this->when(
                $this->withdrawal_method === 'pix',
                [
                    'key' => $this->pix_key,
                    'key_type' => $this->pix_key_type,
                ]
            ),
            'requested_at' => $this->created_at->toISOString(),
            'processed_at' => $this->processed_at?->toISOString(),
            'completed_at' => $this->completed_at?->toISOString(),
            'cancelled_at' => $this->cancelled_at?->toISOString(),
            'cancellation_reason' => $this->cancellation_reason,
            'transaction_id' => $this->transaction_id,
            'notes' => $this->notes,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'driver' => new DriverProfileResource($this->whenLoaded('driver')),
        ];
    }
}
