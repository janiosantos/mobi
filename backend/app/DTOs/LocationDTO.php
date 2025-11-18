<?php

namespace App\DTOs;

class LocationDTO
{
    public function __construct(
        public float $latitude,
        public float $longitude,
        public ?float $heading = null,
        public ?float $speed = null,
        public ?float $accuracy = null,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            latitude: (float) $data['latitude'],
            longitude: (float) $data['longitude'],
            heading: isset($data['heading']) ? (float) $data['heading'] : null,
            speed: isset($data['speed']) ? (float) $data['speed'] : null,
            accuracy: isset($data['accuracy']) ? (float) $data['accuracy'] : null,
        );
    }

    public function toArray(): array
    {
        return [
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'heading' => $this->heading,
            'speed' => $this->speed,
            'accuracy' => $this->accuracy,
        ];
    }
}
