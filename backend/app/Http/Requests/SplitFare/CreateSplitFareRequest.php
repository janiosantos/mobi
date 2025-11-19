<?php

namespace App\Http\Requests\SplitFare;

use Illuminate\Foundation\Http\FormRequest;
use App\Http\Controllers\SplitFareController;

class CreateSplitFareRequest extends FormRequest
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
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'method' => 'required|in:equal,custom,percentage',
            'participants' => 'required|array|min:1|max:' . (SplitFareController::MAX_SPLIT_PARTICIPANTS - 1),
            'participants.*.user_id' => 'nullable|exists:users,id',
            'participants.*.email' => 'nullable|email',
            'participants.*.phone' => 'nullable|string',
            'participants.*.amount' => 'required_if:method,custom|numeric|min:0',
            'participants.*.percentage' => 'required_if:method,percentage|numeric|min:0|max:100',
        ];
    }

    /**
     * Get custom error messages for validation rules.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'method.required' => 'O método de divisão é obrigatório',
            'method.in' => 'O método de divisão deve ser: equal, custom ou percentage',
            'participants.required' => 'É necessário incluir pelo menos um participante',
            'participants.array' => 'Os participantes devem ser uma lista',
            'participants.min' => 'É necessário incluir pelo menos um participante',
            'participants.max' => 'Máximo de ' . (SplitFareController::MAX_SPLIT_PARTICIPANTS - 1) . ' participantes',
            'participants.*.user_id.exists' => 'Um dos usuários informados não existe',
            'participants.*.email.email' => 'Um dos emails informados é inválido',
            'participants.*.amount.required_if' => 'O valor é obrigatório quando o método é "custom"',
            'participants.*.amount.numeric' => 'O valor deve ser um número',
            'participants.*.amount.min' => 'O valor deve ser maior ou igual a 0',
            'participants.*.percentage.required_if' => 'A porcentagem é obrigatória quando o método é "percentage"',
            'participants.*.percentage.numeric' => 'A porcentagem deve ser um número',
            'participants.*.percentage.min' => 'A porcentagem deve ser maior ou igual a 0',
            'participants.*.percentage.max' => 'A porcentagem deve ser menor ou igual a 100',
        ];
    }
}
