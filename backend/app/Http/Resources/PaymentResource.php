<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'payment_number' => $this->payment_number,
            'ride_id' => $this->ride_id,
            'payment_method_id' => $this->payment_method_id,
            'amount' => number_format($this->amount, 2, '.', ''),
            'currency' => $this->currency,
            'status' => $this->status,
            'payment_type' => $this->payment_type,
            'provider' => $this->provider,
            'provider_payment_id' => $this->provider_payment_id,
            'installments' => $this->installments,
            'pix' => $this->when(
                $this->payment_type === 'pix',
                [
                    'qr_code' => $this->pix_qr_code,
                    'qr_code_base64' => $this->pix_qr_code_base64,
                    'expiration_date' => $this->pix_expiration_date?->toISOString(),
                ]
            ),
            'paid_at' => $this->paid_at?->toISOString(),
            'refunded_at' => $this->refunded_at?->toISOString(),
            'refund_amount' => $this->refund_amount ? number_format($this->refund_amount, 2, '.', '') : null,
            'failure_reason' => $this->failure_reason,
            'metadata' => $this->metadata,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'ride' => new RideResource($this->whenLoaded('ride')),
            'payment_method' => new PaymentMethodResource($this->whenLoaded('paymentMethod')),
        ];
    }
}
