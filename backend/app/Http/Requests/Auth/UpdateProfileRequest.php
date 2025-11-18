<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
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
        $userId = $this->user()->id;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'string', 'email', 'max:255', Rule::unique('users')->ignore($userId)],
            'phone' => ['sometimes', 'string', 'regex:/^\+?[1-9]\d{10,14}$/', Rule::unique('users')->ignore($userId)],
            'profile_photo' => ['nullable', 'image', 'max:2048'],
            'gender' => ['nullable', 'in:male,female,other'],
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
            'name.string' => 'O nome deve ser uma string.',
            'email.email' => 'Por favor, insira um e-mail válido.',
            'email.unique' => 'Este e-mail já está em uso.',
            'phone.regex' => 'Por favor, insira um número de telefone válido.',
            'phone.unique' => 'Este telefone já está em uso.',
            'profile_photo.image' => 'O arquivo deve ser uma imagem.',
            'profile_photo.max' => 'A foto não pode ser maior que 2MB.',
            'gender.in' => 'Gênero inválido.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'name' => 'nome',
            'email' => 'e-mail',
            'phone' => 'telefone',
            'profile_photo' => 'foto de perfil',
            'gender' => 'gênero',
        ];
    }
}
