<?php

declare(strict_types=1);

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()->id;

        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'email' => ['sometimes', 'required', 'email', Rule::unique('users')->ignore($userId)],
            'phone' => ['sometimes', 'required', 'string', 'max:20', Rule::unique('users')->ignore($userId)],
            'birth_date' => ['sometimes', 'nullable', 'date', 'before:today'],
            'gender' => ['sometimes', 'nullable', 'in:male,female,other'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Name is required',
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format',
            'email.unique' => 'Email already in use',
            'phone.required' => 'Phone is required',
            'phone.unique' => 'Phone already in use',
            'birth_date.date' => 'Invalid birth date',
            'birth_date.before' => 'Birth date must be before today',
            'gender.in' => 'Invalid gender value',
        ];
    }
}
