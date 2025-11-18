<?php

namespace App\Http\Requests\Vehicle;

use Illuminate\Foundation\Http\FormRequest;

class AddVehicleRequest extends FormRequest
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
            'vehicle_category_id' => ['required', 'integer', 'exists:vehicle_categories,id'],
            'make' => ['required', 'string', 'max:100'],
            'model' => ['required', 'string', 'max:100'],
            'year' => ['required', 'integer', 'between:2000,' . (date('Y') + 1)],
            'color' => ['required', 'string', 'max:50'],
            'license_plate' => ['required', 'string', 'max:20', 'unique:vehicles,license_plate'],
            'photo' => ['nullable', 'image', 'max:2048'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'vehicle_category_id.required' => 'A categoria do veículo é obrigatória.',
            'vehicle_category_id.exists' => 'Categoria de veículo não encontrada.',
            'make.required' => 'A marca do veículo é obrigatória.',
            'model.required' => 'O modelo do veículo é obrigatório.',
            'year.required' => 'O ano do veículo é obrigatório.',
            'year.between' => 'Ano inválido.',
            'color.required' => 'A cor do veículo é obrigatória.',
            'license_plate.required' => 'A placa do veículo é obrigatória.',
            'license_plate.unique' => 'Esta placa já está cadastrada.',
            'photo.image' => 'O arquivo deve ser uma imagem.',
            'photo.max' => 'A foto não pode ser maior que 2MB.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'vehicle_category_id' => 'categoria do veículo',
            'make' => 'marca',
            'model' => 'modelo',
            'year' => 'ano',
            'color' => 'cor',
            'license_plate' => 'placa',
            'photo' => 'foto',
        ];
    }
}
