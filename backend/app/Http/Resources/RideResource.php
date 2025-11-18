<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RideResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'ride_number' => $this->ride_number,
            'status' => $this->status,
            'pickup' => [
                'address' => $this->pickup_address,
                'latitude' => (float) $this->pickup_latitude,
                'longitude' => (float) $this->pickup_longitude,
                'city' => $this->pickup_city,
                'state' => $this->pickup_state,
                'postal_code' => $this->pickup_postal_code,
            ],
            'dropoff' => [
                'address' => $this->dropoff_address,
                'latitude' => (float) $this->dropoff_latitude,
                'longitude' => (float) $this->dropoff_longitude,
                'city' => $this->dropoff_city,
                'state' => $this->dropoff_state,
                'postal_code' => $this->dropoff_postal_code,
            ],
            'distance' => [
                'estimated_meters' => $this->estimated_distance_meters,
                'estimated_km' => $this->estimated_distance_meters ? round($this->estimated_distance_meters / 1000, 2) : null,
                'actual_meters' => $this->actual_distance_meters,
                'actual_km' => $this->actual_distance_meters ? round($this->actual_distance_meters / 1000, 2) : null,
            ],
            'duration' => [
                'estimated_seconds' => $this->estimated_duration_seconds,
                'estimated_minutes' => $this->estimated_duration_seconds ? round($this->estimated_duration_seconds / 60, 1) : null,
                'actual_seconds' => $this->actual_duration_seconds,
                'actual_minutes' => $this->actual_duration_seconds ? round($this->actual_duration_seconds / 60, 1) : null,
            ],
            'pricing' => [
                'estimated_price' => number_format($this->estimated_price, 2, '.', ''),
                'base_fare' => number_format($this->base_fare ?? 0, 2, '.', ''),
                'distance_fare' => number_format($this->distance_fare ?? 0, 2, '.', ''),
                'time_fare' => number_format($this->time_fare ?? 0, 2, '.', ''),
                'surge_multiplier' => $this->surge_multiplier ? (float) $this->surge_multiplier : 1.0,
                'discount_amount' => number_format($this->discount_amount ?? 0, 2, '.', ''),
                'platform_fee' => number_format($this->platform_fee ?? 0, 2, '.', ''),
                'driver_earnings' => number_format($this->driver_earnings ?? 0, 2, '.', ''),
                'final_price' => number_format($this->final_price ?? $this->estimated_price, 2, '.', ''),
            ],
            'timeline' => [
                'requested_at' => $this->created_at->toISOString(),
                'accepted_at' => $this->accepted_at?->toISOString(),
                'driver_arrived_at' => $this->driver_arrived_at?->toISOString(),
                'started_at' => $this->started_at?->toISOString(),
                'completed_at' => $this->completed_at?->toISOString(),
                'cancelled_at' => $this->cancelled_at?->toISOString(),
            ],
            'cancellation' => $this->when(
                $this->cancelled_at,
                [
                    'cancelled_by' => $this->cancelled_by,
                    'cancellation_reason' => $this->cancellation_reason,
                    'cancellation_fee' => number_format($this->cancellation_fee ?? 0, 2, '.', ''),
                ]
            ),
            'notes' => $this->notes,
            'polyline' => $this->polyline,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'passenger' => new UserResource($this->whenLoaded('passenger')),
            'driver' => new UserResource($this->whenLoaded('driver')),
            'category' => new VehicleCategoryResource($this->whenLoaded('category')),
            'vehicle' => new VehicleResource($this->whenLoaded('vehicle')),
            'payment' => new PaymentResource($this->whenLoaded('payment')),
            'ratings' => RatingResource::collection($this->whenLoaded('ratings')),
            'messages' => MessageResource::collection($this->whenLoaded('messages')),
        ];
    }
}
