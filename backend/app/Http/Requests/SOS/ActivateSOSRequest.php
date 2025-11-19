<?php

namespace App\Http\Requests\SOS;

use Illuminate\Foundation\Http\FormRequest;

class ActivateSOSRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // Authorization handled by middleware
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'accuracy' => 'nullable|numeric|min:0',
            'note' => 'nullable|string|max:500',
            'ride_id' => 'nullable|exists:rides,id',
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
            'latitude.required' => 'A latitude é obrigatória para ativar o SOS',
            'latitude.between' => 'A latitude deve estar entre -90 e 90',
            'longitude.required' => 'A longitude é obrigatória para ativar o SOS',
            'longitude.between' => 'A longitude deve estar entre -180 e 180',
            'accuracy.numeric' => 'A precisão deve ser um número',
            'accuracy.min' => 'A precisão deve ser maior ou igual a 0',
            'note.max' => 'A nota não pode ter mais de 500 caracteres',
            'ride_id.exists' => 'A corrida informada não existe',
        ];
    }
}
