<?php

declare(strict_types=1);

namespace App\Http\Requests\PaymentMethod;

use Illuminate\Foundation\Http\FormRequest;

class CreatePaymentMethodRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['required', 'in:pix,credit_card,debit_card,cash,wallet'],
            'last_four' => ['nullable', 'string', 'size:4'],
            'brand' => ['nullable', 'string', 'max:50'],
            'token' => ['nullable', 'string', 'max:255'],
            'is_default' => ['sometimes', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'type.required' => 'Payment type is required',
            'type.in' => 'Invalid payment type',
            'last_four.size' => 'Last four digits must be exactly 4 characters',
        ];
    }
}
