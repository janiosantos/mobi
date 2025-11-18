<?php

namespace App\DTOs;

class DriverDTO
{
    public function __construct(
        public string $licenseNumber,
        public string $licenseCategory,
        public string $licenseExpiryDate,
        public ?string $bankName = null,
        public ?string $bankAccountType = null,
        public ?string $bankAgency = null,
        public ?string $bankAccount = null,
        public ?string $pixKey = null,
        public ?string $pixKeyType = null,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            licenseNumber: $data['license_number'],
            licenseCategory: $data['license_category'],
            licenseExpiryDate: $data['license_expiry_date'],
            bankName: $data['bank_name'] ?? null,
            bankAccountType: $data['bank_account_type'] ?? null,
            bankAgency: $data['bank_agency'] ?? null,
            bankAccount: $data['bank_account'] ?? null,
            pixKey: $data['pix_key'] ?? null,
            pixKeyType: $data['pix_key_type'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'license_number' => $this->licenseNumber,
            'license_category' => $this->licenseCategory,
            'license_expiry_date' => $this->licenseExpiryDate,
            'bank_name' => $this->bankName,
            'bank_account_type' => $this->bankAccountType,
            'bank_agency' => $this->bankAgency,
            'bank_account' => $this->bankAccount,
            'pix_key' => $this->pixKey,
            'pix_key_type' => $this->pixKeyType,
        ];
    }
}
