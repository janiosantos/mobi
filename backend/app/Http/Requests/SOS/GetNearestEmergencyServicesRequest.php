<?php

namespace App\Http\Requests\SOS;

use Illuminate\Foundation\Http\FormRequest;

class GetNearestEmergencyServicesRequest extends FormRequest
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
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
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
            'latitude.required' => 'A latitude é obrigatória',
            'latitude.between' => 'A latitude deve estar entre -90 e 90',
            'longitude.required' => 'A longitude é obrigatória',
            'longitude.between' => 'A longitude deve estar entre -180 e 180',
        ];
    }
}
