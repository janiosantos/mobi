<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DriverDocumentResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'driver_id' => $this->driver_id,
            'document_type' => $this->document_type,
            'document_number' => $this->document_number,
            'document_url' => $this->document_url,
            'status' => $this->status,
            'verified_at' => $this->verified_at?->toISOString(),
            'verified_by' => $this->verified_by,
            'rejection_reason' => $this->rejection_reason,
            'expiry_date' => $this->expiry_date?->format('Y-m-d'),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'driver' => new DriverProfileResource($this->whenLoaded('driver')),
        ];
    }
}
