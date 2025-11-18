<?php

namespace App\Http\Requests\Ride;

use Illuminate\Foundation\Http\FormRequest;

class CreateRideRequest extends FormRequest
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
            'pickup_latitude' => ['required', 'numeric', 'between:-90,90'],
            'pickup_longitude' => ['required', 'numeric', 'between:-180,180'],
            'pickup_address' => ['required', 'string', 'max:500'],
            'pickup_city' => ['nullable', 'string', 'max:100'],
            'pickup_state' => ['nullable', 'string', 'max:2'],
            'pickup_postal_code' => ['nullable', 'string', 'max:10'],

            'dropoff_latitude' => ['required', 'numeric', 'between:-90,90'],
            'dropoff_longitude' => ['required', 'numeric', 'between:-180,180'],
            'dropoff_address' => ['required', 'string', 'max:500'],
            'dropoff_city' => ['nullable', 'string', 'max:100'],
            'dropoff_state' => ['nullable', 'string', 'max:2'],
            'dropoff_postal_code' => ['nullable', 'string', 'max:10'],

            'vehicle_category_id' => ['required', 'integer', 'exists:vehicle_categories,id'],
            'payment_method_id' => ['required', 'integer', 'exists:payment_methods,id'],
            'coupon_code' => ['nullable', 'string', 'max:50', 'exists:coupons,code'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'pickup_latitude.required' => 'A latitude de origem é obrigatória.',
            'pickup_latitude.between' => 'Latitude de origem inválida.',
            'pickup_longitude.required' => 'A longitude de origem é obrigatória.',
            'pickup_longitude.between' => 'Longitude de origem inválida.',
            'pickup_address.required' => 'O endereço de origem é obrigatório.',
            'dropoff_latitude.required' => 'A latitude de destino é obrigatória.',
            'dropoff_latitude.between' => 'Latitude de destino inválida.',
            'dropoff_longitude.required' => 'A longitude de destino é obrigatória.',
            'dropoff_longitude.between' => 'Longitude de destino inválida.',
            'dropoff_address.required' => 'O endereço de destino é obrigatório.',
            'vehicle_category_id.required' => 'A categoria do veículo é obrigatória.',
            'vehicle_category_id.exists' => 'Categoria de veículo não encontrada.',
            'payment_method_id.required' => 'O método de pagamento é obrigatório.',
            'payment_method_id.exists' => 'Método de pagamento não encontrado.',
            'coupon_code.exists' => 'Cupom não encontrado.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'pickup_latitude' => 'latitude de origem',
            'pickup_longitude' => 'longitude de origem',
            'pickup_address' => 'endereço de origem',
            'dropoff_latitude' => 'latitude de destino',
            'dropoff_longitude' => 'longitude de destino',
            'dropoff_address' => 'endereço de destino',
            'vehicle_category_id' => 'categoria do veículo',
            'payment_method_id' => 'método de pagamento',
            'coupon_code' => 'código do cupom',
            'notes' => 'observações',
        ];
    }
}
