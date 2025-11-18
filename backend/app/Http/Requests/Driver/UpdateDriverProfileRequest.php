<?php

namespace App\Http\Requests\Driver;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateDriverProfileRequest extends FormRequest
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
        $driverProfileId = $this->user()->driverProfile?->id;

        return [
            'license_number' => [
                'sometimes',
                'string',
                'max:50',
                Rule::unique('driver_profiles')->ignore($driverProfileId)
            ],
            'license_category' => ['sometimes', 'string', 'in:A,B,C,D,E,AB,AC,AD,AE'],
            'license_expiry_date' => ['sometimes', 'date', 'after:' . now()->addMonths(3)->format('Y-m-d')],
            'bio' => ['nullable', 'string', 'max:500'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'license_number.unique' => 'Esta CNH já está cadastrada.',
            'license_category.in' => 'Categoria de CNH inválida.',
            'license_expiry_date.after' => 'A CNH deve ter pelo menos 3 meses de validade.',
            'bio.max' => 'A bio não pode ter mais de 500 caracteres.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'license_number' => 'número da CNH',
            'license_category' => 'categoria da CNH',
            'license_expiry_date' => 'validade da CNH',
            'bio' => 'biografia',
        ];
    }
}
