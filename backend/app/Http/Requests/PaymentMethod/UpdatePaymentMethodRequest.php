<?php

declare(strict_types=1);

namespace App\Http\Requests\PaymentMethod;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePaymentMethodRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'last_four' => ['sometimes', 'string', 'size:4'],
            'brand' => ['sometimes', 'string', 'max:50'],
        ];
    }

    public function messages(): array
    {
        return [
            'last_four.size' => 'Last four digits must be exactly 4 characters',
        ];
    }
}
