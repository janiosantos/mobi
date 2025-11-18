<?php

namespace App\DTOs;

class PaymentDTO
{
    public function __construct(
        public int $rideId,
        public int $userId,
        public string $paymentType,
        public float $amount,
        public ?int $paymentMethodId = null,
        public ?array $cardData = null,
        public ?string $pixKey = null,
        public ?int $installments = 1,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            rideId: $data['ride_id'],
            userId: $data['user_id'],
            paymentType: $data['payment_type'],
            amount: (float) $data['amount'],
            paymentMethodId: $data['payment_method_id'] ?? null,
            cardData: $data['card_data'] ?? null,
            pixKey: $data['pix_key'] ?? null,
            installments: $data['installments'] ?? 1,
        );
    }

    public function toArray(): array
    {
        return [
            'ride_id' => $this->rideId,
            'user_id' => $this->userId,
            'payment_type' => $this->paymentType,
            'amount' => $this->amount,
            'payment_method_id' => $this->paymentMethodId,
            'card_data' => $this->cardData,
            'pix_key' => $this->pixKey,
            'installments' => $this->installments,
        ];
    }
}
