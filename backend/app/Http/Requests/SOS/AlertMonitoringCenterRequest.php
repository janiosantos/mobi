<?php

namespace App\Http\Requests\SOS;

use Illuminate\Foundation\Http\FormRequest;

class AlertMonitoringCenterRequest extends FormRequest
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
            'reason' => 'required|string|max:200',
            'details' => 'nullable|string|max:1000',
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
            'reason.required' => 'O motivo do alerta é obrigatório',
            'reason.max' => 'O motivo não pode ter mais de 200 caracteres',
            'details.max' => 'Os detalhes não podem ter mais de 1000 caracteres',
        ];
    }
}
