<?php

namespace App\Http\Requests\Payment;

use Illuminate\Foundation\Http\FormRequest;

class AddPaymentMethodRequest extends FormRequest
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
            'type' => ['required', 'in:credit_card,debit_card,pix'],
            'is_default' => ['nullable', 'boolean'],

            // Card data (required if type is credit_card or debit_card)
            'card_token' => ['required_if:type,credit_card,debit_card', 'string'],
            'card_last_four' => ['required_if:type,credit_card,debit_card', 'string', 'size:4'],
            'card_brand' => ['required_if:type,credit_card,debit_card', 'string', 'max:50'],
            'card_holder_name' => ['required_if:type,credit_card,debit_card', 'string', 'max:255'],
            'card_expiry_month' => ['required_if:type,credit_card,debit_card', 'integer', 'between:1,12'],
            'card_expiry_year' => ['required_if:type,credit_card,debit_card', 'integer', 'min:' . date('Y')],

            // PIX data (optional for pix type)
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
            'type.required' => 'O tipo de pagamento é obrigatório.',
            'type.in' => 'Tipo de pagamento inválido.',
            'card_token.required_if' => 'O token do cartão é obrigatório.',
            'card_last_four.required_if' => 'Os últimos 4 dígitos são obrigatórios.',
            'card_last_four.size' => 'Devem ser exatamente 4 dígitos.',
            'card_brand.required_if' => 'A bandeira do cartão é obrigatória.',
            'card_holder_name.required_if' => 'O nome do titular é obrigatório.',
            'card_expiry_month.required_if' => 'O mês de validade é obrigatório.',
            'card_expiry_month.between' => 'Mês inválido.',
            'card_expiry_year.required_if' => 'O ano de validade é obrigatório.',
            'card_expiry_year.min' => 'Cartão expirado.',
            'pix_key_type.in' => 'Tipo de chave PIX inválido.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'type' => 'tipo de pagamento',
            'card_token' => 'token do cartão',
            'card_last_four' => 'últimos 4 dígitos',
            'card_brand' => 'bandeira',
            'card_holder_name' => 'nome do titular',
            'card_expiry_month' => 'mês de validade',
            'card_expiry_year' => 'ano de validade',
            'pix_key' => 'chave PIX',
            'pix_key_type' => 'tipo de chave PIX',
        ];
    }
}
