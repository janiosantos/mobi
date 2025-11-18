<?php

namespace App\Http\Requests\Driver;

use Illuminate\Foundation\Http\FormRequest;

class ToggleOnlineStatusRequest extends FormRequest
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
            'is_online' => ['required', 'boolean'],
            'latitude' => ['required_if:is_online,true', 'numeric', 'between:-90,90'],
            'longitude' => ['required_if:is_online,true', 'numeric', 'between:-180,180'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'is_online.required' => 'O status online é obrigatório.',
            'latitude.required_if' => 'A latitude é obrigatória para ficar online.',
            'latitude.between' => 'Latitude inválida.',
            'longitude.required_if' => 'A longitude é obrigatória para ficar online.',
            'longitude.between' => 'Longitude inválida.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'is_online' => 'status online',
            'latitude' => 'latitude',
            'longitude' => 'longitude',
        ];
    }
}
