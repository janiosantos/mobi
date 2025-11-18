<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterDriverRequest extends FormRequest
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
            // User data
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'regex:/^\+?[1-9]\d{10,14}$/', 'unique:users,phone'],
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
            'cpf' => ['required', 'string', 'regex:/^\d{3}\.\d{3}\.\d{3}-\d{2}$|^\d{11}$/', 'unique:users,cpf'],
            'birth_date' => ['required', 'date', 'before:' . now()->subYears(21)->format('Y-m-d')],
            'gender' => ['nullable', 'in:male,female,other'],
            'profile_photo' => ['nullable', 'image', 'max:2048'],

            // Driver-specific data
            'license_number' => ['required', 'string', 'max:50', 'unique:driver_profiles,license_number'],
            'license_category' => ['required', 'string', 'in:A,B,C,D,E,AB,AC,AD,AE'],
            'license_expiry_date' => ['required', 'date', 'after:' . now()->addMonths(3)->format('Y-m-d')],

            // Bank account (optional, can be added later)
            'bank_name' => ['nullable', 'string', 'max:100'],
            'bank_account_type' => ['nullable', 'in:checking,savings'],
            'bank_agency' => ['nullable', 'string', 'max:10'],
            'bank_account' => ['nullable', 'string', 'max:20'],

            // PIX (optional)
            'pix_key' => ['nullable', 'string', 'max:255'],
            'pix_key_type' => ['nullable', 'in:cpf,cnpj,email,phone,random'],

            // Device info
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
            'birth_date.before' => 'Você deve ter pelo menos 21 anos para ser motorista.',
            'license_number.required' => 'O número da CNH é obrigatório.',
            'license_number.unique' => 'Esta CNH já está cadastrada.',
            'license_category.required' => 'A categoria da CNH é obrigatória.',
            'license_category.in' => 'Categoria de CNH inválida.',
            'license_expiry_date.required' => 'A data de validade da CNH é obrigatória.',
            'license_expiry_date.after' => 'A CNH deve ter pelo menos 3 meses de validade.',
            'bank_account_type.in' => 'Tipo de conta bancária inválido.',
            'pix_key_type.in' => 'Tipo de chave PIX inválido.',
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
            'license_number' => 'número da CNH',
            'license_category' => 'categoria da CNH',
            'license_expiry_date' => 'validade da CNH',
            'bank_name' => 'banco',
            'bank_account_type' => 'tipo de conta',
            'bank_agency' => 'agência',
            'bank_account' => 'conta',
            'pix_key' => 'chave PIX',
            'pix_key_type' => 'tipo de chave PIX',
        ];
    }
}
