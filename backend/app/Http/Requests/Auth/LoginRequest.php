<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
            'device_token' => ['nullable', 'string'],
            'device_type' => ['nullable', 'in:ios,android,web'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'email.required' => 'O e-mail é obrigatório.',
            'email.email' => 'Por favor, insira um e-mail válido.',
            'password.required' => 'A senha é obrigatória.',
            'device_type.in' => 'Tipo de dispositivo inválido.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'email' => 'e-mail',
            'password' => 'senha',
            'device_token' => 'token do dispositivo',
            'device_type' => 'tipo de dispositivo',
        ];
    }
}
