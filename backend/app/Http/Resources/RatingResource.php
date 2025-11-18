<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RatingResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'ride_id' => $this->ride_id,
            'rater_id' => $this->rater_id,
            'rated_id' => $this->rated_id,
            'rating' => $this->rating,
            'comment' => $this->comment,
            'tags' => $this->tags,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'rater' => new UserResource($this->whenLoaded('rater')),
            'rated' => new UserResource($this->whenLoaded('rated')),
            'ride' => new RideResource($this->whenLoaded('ride')),
        ];
    }
}
