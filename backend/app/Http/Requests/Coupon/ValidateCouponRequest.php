<?php

declare(strict_types=1);

namespace App\Http\Requests\Coupon;

use Illuminate\Foundation\Http\FormRequest;

class ValidateCouponRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'code' => ['required', 'string', 'max:50'],
            'ride_value' => ['sometimes', 'numeric', 'min:0'],
        ];
    }

    public function messages(): array
    {
        return [
            'code.required' => 'Coupon code is required',
            'code.string' => 'Invalid coupon code format',
            'ride_value.numeric' => 'Ride value must be a number',
            'ride_value.min' => 'Ride value cannot be negative',
        ];
    }
}
