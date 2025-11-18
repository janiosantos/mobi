<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DriverProfileResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'license_number' => $this->license_number,
            'license_category' => $this->license_category,
            'license_expiry_date' => $this->license_expiry_date?->format('Y-m-d'),
            'bio' => $this->bio,
            'status' => $this->status,
            'approval_date' => $this->approval_date?->format('Y-m-d H:i:s'),
            'rejection_reason' => $this->rejection_reason,
            'is_online' => $this->is_online,
            'is_available' => $this->is_available,
            'current_location' => $this->when(
                $this->current_latitude && $this->current_longitude,
                [
                    'latitude' => $this->current_latitude ? (float) $this->current_latitude : null,
                    'longitude' => $this->current_longitude ? (float) $this->current_longitude : null,
                    'heading' => $this->heading ? (float) $this->heading : null,
                    'speed' => $this->speed ? (float) $this->speed : null,
                    'updated_at' => $this->location_updated_at?->toISOString(),
                ]
            ),
            'stats' => [
                'total_rides' => $this->total_rides,
                'completed_rides' => $this->completed_rides,
                'cancelled_rides' => $this->cancelled_rides,
                'acceptance_rate' => $this->acceptance_rate ? round($this->acceptance_rate, 2) : 0,
                'cancellation_rate' => $this->cancellation_rate ? round($this->cancellation_rate, 2) : 0,
                'average_rating' => $this->average_rating ? round($this->average_rating, 2) : 0,
                'total_ratings' => $this->total_ratings,
            ],
            'earnings' => [
                'total_earnings' => number_format($this->total_earnings ?? 0, 2, '.', ''),
                'available_balance' => number_format($this->available_balance ?? 0, 2, '.', ''),
                'withdrawn_amount' => number_format($this->withdrawn_amount ?? 0, 2, '.', ''),
            ],
            'bank_account' => $this->when(
                $this->bank_name,
                [
                    'bank_name' => $this->bank_name,
                    'account_type' => $this->bank_account_type,
                    'agency' => $this->bank_agency,
                    'account' => $this->bank_account,
                ]
            ),
            'pix' => $this->when(
                $this->pix_key,
                [
                    'key' => $this->pix_key,
                    'key_type' => $this->pix_key_type,
                ]
            ),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'user' => new UserResource($this->whenLoaded('user')),
            'vehicles' => VehicleResource::collection($this->whenLoaded('vehicles')),
            'documents' => DriverDocumentResource::collection($this->whenLoaded('documents')),
        ];
    }
}
