<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentMethodResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'type' => $this->type,
            'is_default' => $this->is_default,
            'card' => $this->when(
                in_array($this->type, ['credit_card', 'debit_card']),
                [
                    'last_four' => $this->card_last_four,
                    'brand' => $this->card_brand,
                    'holder_name' => $this->card_holder_name,
                    'expiry_month' => $this->card_expiry_month,
                    'expiry_year' => $this->card_expiry_year,
                ]
            ),
            'pix' => $this->when(
                $this->type === 'pix' && $this->pix_key,
                [
                    'key' => $this->pix_key,
                    'key_type' => $this->pix_key_type,
                ]
            ),
            'is_verified' => $this->is_verified,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
