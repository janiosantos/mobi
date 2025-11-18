<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EarningResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'driver_id' => $this->driver_id,
            'ride_id' => $this->ride_id,
            'amount' => number_format($this->amount, 2, '.', ''),
            'platform_fee' => number_format($this->platform_fee, 2, '.', ''),
            'driver_earnings' => number_format($this->driver_earnings, 2, '.', ''),
            'payment_status' => $this->payment_status,
            'paid_at' => $this->paid_at?->toISOString(),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'driver' => new DriverProfileResource($this->whenLoaded('driver')),
            'ride' => new RideResource($this->whenLoaded('ride')),
        ];
    }
}
