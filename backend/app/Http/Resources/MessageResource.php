<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MessageResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'ride_id' => $this->ride_id,
            'sender_id' => $this->sender_id,
            'receiver_id' => $this->receiver_id,
            'message' => $this->message,
            'type' => $this->type,
            'attachment_url' => $this->attachment_url,
            'is_read' => $this->is_read,
            'read_at' => $this->read_at?->toISOString(),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'sender' => new UserResource($this->whenLoaded('sender')),
            'receiver' => new UserResource($this->whenLoaded('receiver')),
            'ride' => new RideResource($this->whenLoaded('ride')),
        ];
    }
}
