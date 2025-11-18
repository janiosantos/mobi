<?php

namespace App\Http\Requests\Driver;

use Illuminate\Foundation\Http\FormRequest;

class UpdateLocationRequest extends FormRequest
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
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'heading' => ['nullable', 'numeric', 'between:0,360'],
            'speed' => ['nullable', 'numeric', 'min:0'],
            'accuracy' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'latitude.required' => 'A latitude é obrigatória.',
            'latitude.between' => 'Latitude inválida.',
            'longitude.required' => 'A longitude é obrigatória.',
            'longitude.between' => 'Longitude inválida.',
            'heading.between' => 'Direção deve estar entre 0 e 360 graus.',
            'speed.min' => 'Velocidade não pode ser negativa.',
            'accuracy.min' => 'Precisão não pode ser negativa.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'latitude' => 'latitude',
            'longitude' => 'longitude',
            'heading' => 'direção',
            'speed' => 'velocidade',
            'accuracy' => 'precisão',
        ];
    }
}
