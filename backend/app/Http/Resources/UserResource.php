<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'cpf' => $this->cpf,
            'birth_date' => $this->birth_date?->format('Y-m-d'),
            'gender' => $this->gender,
            'user_type' => $this->user_type,
            'profile_photo_url' => $this->profile_photo_url,
            'average_rating' => $this->average_rating ? round($this->average_rating, 2) : null,
            'total_ratings' => $this->total_ratings,
            'wallet_balance' => $this->wallet_balance ? number_format($this->wallet_balance, 2, '.', '') : '0.00',
            'is_active' => $this->is_active,
            'is_verified' => $this->is_verified,
            'is_banned' => $this->is_banned,
            'email_verified_at' => $this->email_verified_at?->toISOString(),
            'phone_verified_at' => $this->phone_verified_at?->toISOString(),
            'last_active_at' => $this->last_active_at?->toISOString(),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional relationships
            'driver_profile' => new DriverProfileResource($this->whenLoaded('driverProfile')),
            'roles' => $this->whenLoaded('roles', function () {
                return $this->roles->pluck('name');
            }),
        ];
    }
}
