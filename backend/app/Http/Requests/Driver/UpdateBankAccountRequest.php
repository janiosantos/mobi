<?php

namespace App\Http\Requests\Driver;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBankAccountRequest extends FormRequest
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
            'bank_name' => ['required', 'string', 'max:100'],
            'bank_account_type' => ['required', 'in:checking,savings'],
            'bank_agency' => ['required', 'string', 'max:10'],
            'bank_account' => ['required', 'string', 'max:20'],
            'pix_key' => ['nullable', 'string', 'max:255'],
            'pix_key_type' => ['nullable', 'in:cpf,cnpj,email,phone,random'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'bank_name.required' => 'O nome do banco é obrigatório.',
            'bank_account_type.required' => 'O tipo de conta é obrigatório.',
            'bank_account_type.in' => 'Tipo de conta inválido.',
            'bank_agency.required' => 'A agência é obrigatória.',
            'bank_account.required' => 'O número da conta é obrigatório.',
            'pix_key_type.in' => 'Tipo de chave PIX inválido.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'bank_name' => 'nome do banco',
            'bank_account_type' => 'tipo de conta',
            'bank_agency' => 'agência',
            'bank_account' => 'conta',
            'pix_key' => 'chave PIX',
            'pix_key_type' => 'tipo de chave PIX',
        ];
    }
}
