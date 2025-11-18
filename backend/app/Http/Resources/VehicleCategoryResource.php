<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VehicleCategoryResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'slug' => $this->slug,
            'icon_url' => $this->icon_url,
            'base_fare' => number_format($this->base_fare, 2, '.', ''),
            'price_per_km' => number_format($this->price_per_km, 2, '.', ''),
            'price_per_minute' => number_format($this->price_per_minute, 2, '.', ''),
            'minimum_fare' => number_format($this->minimum_fare, 2, '.', ''),
            'seats' => $this->seats,
            'is_active' => $this->is_active,
            'sort_order' => $this->sort_order,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
