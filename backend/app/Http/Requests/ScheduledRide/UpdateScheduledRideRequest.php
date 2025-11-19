<?php

namespace App\Http\Requests\ScheduledRide;

use Illuminate\Foundation\Http\FormRequest;

class UpdateScheduledRideRequest extends FormRequest
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
            'scheduled_at' => 'date|after:30 minutes|before:30 days',
            'pickup_latitude' => 'numeric|between:-90,90',
            'pickup_longitude' => 'numeric|between:-180,180',
            'pickup_address' => 'string',
            'dropoff_latitude' => 'numeric|between:-90,90',
            'dropoff_longitude' => 'numeric|between:-180,180',
            'dropoff_address' => 'string',
            'passenger_notes' => 'nullable|string|max:500',
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
            'scheduled_at.date' => 'A data e hora devem ser válidas',
            'scheduled_at.after' => 'O agendamento deve ser com pelo menos 30 minutos de antecedência',
            'scheduled_at.before' => 'O agendamento deve ser dentro de 30 dias',
            'pickup_latitude.between' => 'A latitude de origem deve estar entre -90 e 90',
            'pickup_longitude.between' => 'A longitude de origem deve estar entre -180 e 180',
            'dropoff_latitude.between' => 'A latitude de destino deve estar entre -90 e 90',
            'dropoff_longitude.between' => 'A longitude de destino deve estar entre -180 e 180',
            'passenger_notes.max' => 'As observações não podem ter mais de 500 caracteres',
        ];
    }
}
