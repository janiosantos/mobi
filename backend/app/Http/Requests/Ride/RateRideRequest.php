<?php

namespace App\Http\Requests\Ride;

use Illuminate\Foundation\Http\FormRequest;

class RateRideRequest extends FormRequest
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
            'rating' => ['required', 'integer', 'between:1,5'],
            'comment' => ['nullable', 'string', 'max:1000'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string', 'max:50'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'rating.required' => 'A avaliação é obrigatória.',
            'rating.between' => 'A avaliação deve ser entre 1 e 5 estrelas.',
            'comment.max' => 'O comentário não pode ter mais de 1000 caracteres.',
            'tags.array' => 'As tags devem ser um array.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'rating' => 'avaliação',
            'comment' => 'comentário',
            'tags' => 'tags',
        ];
    }
}
