<?php

namespace App\DTOs;

class RideDTO
{
    public function __construct(
        public int $vehicleCategoryId,
        public float $pickupLatitude,
        public float $pickupLongitude,
        public string $pickupAddress,
        public ?string $pickupCity = null,
        public ?string $pickupState = null,
        public ?string $pickupPostalCode = null,
        public float $dropoffLatitude,
        public float $dropoffLongitude,
        public string $dropoffAddress,
        public ?string $dropoffCity = null,
        public ?string $dropoffState = null,
        public ?string $dropoffPostalCode = null,
        public ?string $passengerNotes = null,
        public ?int $couponId = null,
        public ?string $paymentMethod = null,
        public ?int $paymentMethodId = null,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            vehicleCategoryId: $data['vehicle_category_id'],
            pickupLatitude: (float) $data['pickup_latitude'],
            pickupLongitude: (float) $data['pickup_longitude'],
            pickupAddress: $data['pickup_address'],
            pickupCity: $data['pickup_city'] ?? null,
            pickupState: $data['pickup_state'] ?? null,
            pickupPostalCode: $data['pickup_postal_code'] ?? null,
            dropoffLatitude: (float) $data['dropoff_latitude'],
            dropoffLongitude: (float) $data['dropoff_longitude'],
            dropoffAddress: $data['dropoff_address'],
            dropoffCity: $data['dropoff_city'] ?? null,
            dropoffState: $data['dropoff_state'] ?? null,
            dropoffPostalCode: $data['dropoff_postal_code'] ?? null,
            passengerNotes: $data['passenger_notes'] ?? null,
            couponId: $data['coupon_id'] ?? null,
            paymentMethod: $data['payment_method'] ?? null,
            paymentMethodId: $data['payment_method_id'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'vehicle_category_id' => $this->vehicleCategoryId,
            'pickup_latitude' => $this->pickupLatitude,
            'pickup_longitude' => $this->pickupLongitude,
            'pickup_address' => $this->pickupAddress,
            'pickup_city' => $this->pickupCity,
            'pickup_state' => $this->pickupState,
            'pickup_postal_code' => $this->pickupPostalCode,
            'dropoff_latitude' => $this->dropoffLatitude,
            'dropoff_longitude' => $this->dropoffLongitude,
            'dropoff_address' => $this->dropoffAddress,
            'dropoff_city' => $this->dropoffCity,
            'dropoff_state' => $this->dropoffState,
            'dropoff_postal_code' => $this->dropoffPostalCode,
            'passenger_notes' => $this->passengerNotes,
            'coupon_id' => $this->couponId,
            'payment_method' => $this->paymentMethod,
            'payment_method_id' => $this->paymentMethodId,
        ];
    }
}
