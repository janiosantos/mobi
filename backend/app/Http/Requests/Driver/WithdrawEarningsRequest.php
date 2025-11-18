<?php

namespace App\Http\Requests\Driver;

use Illuminate\Foundation\Http\FormRequest;

class WithdrawEarningsRequest extends FormRequest
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
            'amount' => ['required', 'numeric', 'min:10', 'max:10000'],
            'withdrawal_method' => ['required', 'in:bank_transfer,pix'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'amount.required' => 'O valor é obrigatório.',
            'amount.min' => 'O valor mínimo para saque é R$ 10,00.',
            'amount.max' => 'O valor máximo para saque é R$ 10.000,00.',
            'withdrawal_method.required' => 'O método de saque é obrigatório.',
            'withdrawal_method.in' => 'Método de saque inválido.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'amount' => 'valor',
            'withdrawal_method' => 'método de saque',
        ];
    }
}
