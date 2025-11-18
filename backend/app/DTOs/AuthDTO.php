<?php

namespace App\DTOs;

class AuthDTO
{
    public function __construct(
        public string $name,
        public string $email,
        public string $phone,
        public string $password,
        public string $userType = 'passenger',
        public ?string $cpf = null,
        public ?string $birthDate = null,
        public ?string $gender = null,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            name: $data['name'],
            email: $data['email'],
            phone: $data['phone'],
            password: $data['password'],
            userType: $data['user_type'] ?? 'passenger',
            cpf: $data['cpf'] ?? null,
            birthDate: $data['birth_date'] ?? null,
            gender: $data['gender'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'password' => $this->password,
            'user_type' => $this->userType,
            'cpf' => $this->cpf,
            'birth_date' => $this->birthDate,
            'gender' => $this->gender,
        ];
    }
}
