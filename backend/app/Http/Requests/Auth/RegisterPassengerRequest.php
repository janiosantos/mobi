<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterPassengerRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'regex:/^\+?[1-9]\d{10,14}$/', 'unique:users,phone'],
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
            'cpf' => ['required', 'string', 'regex:/^\d{3}\.\d{3}\.\d{3}-\d{2}$|^\d{11}$/', 'unique:users,cpf'],
            'birth_date' => ['required', 'date', 'before:' . now()->subYears(18)->format('Y-m-d')],
            'gender' => ['nullable', 'in:male,female,other'],
            'profile_photo' => ['nullable', 'image', 'max:2048'], // 2MB max
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
            'name.required' => 'O nome é obrigatório.',
            'email.required' => 'O e-mail é obrigatório.',
            'email.email' => 'Por favor, insira um e-mail válido.',
            'email.unique' => 'Este e-mail já está cadastrado.',
            'phone.required' => 'O telefone é obrigatório.',
            'phone.regex' => 'Por favor, insira um número de telefone válido.',
            'phone.unique' => 'Este telefone já está cadastrado.',
            'password.required' => 'A senha é obrigatória.',
            'password.confirmed' => 'As senhas não conferem.',
            'cpf.required' => 'O CPF é obrigatório.',
            'cpf.regex' => 'Por favor, insira um CPF válido.',
            'cpf.unique' => 'Este CPF já está cadastrado.',
            'birth_date.required' => 'A data de nascimento é obrigatória.',
            'birth_date.before' => 'Você deve ter pelo menos 18 anos.',
            'gender.in' => 'Gênero inválido.',
            'profile_photo.image' => 'O arquivo deve ser uma imagem.',
            'profile_photo.max' => 'A foto não pode ser maior que 2MB.',
            'device_type.in' => 'Tipo de dispositivo inválido.',
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
            'password' => 'senha',
            'cpf' => 'CPF',
            'birth_date' => 'data de nascimento',
            'gender' => 'gênero',
            'profile_photo' => 'foto de perfil',
            'device_token' => 'token do dispositivo',
            'device_type' => 'tipo de dispositivo',
        ];
    }
}
