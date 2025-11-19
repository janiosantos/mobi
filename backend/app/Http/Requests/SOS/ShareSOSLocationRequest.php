<?php

namespace App\Http\Requests\SOS;

use Illuminate\Foundation\Http\FormRequest;

class ShareSOSLocationRequest extends FormRequest
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
            'contact_id' => 'required|exists:emergency_contacts,id',
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
            'contact_id.required' => 'O contato de emergência é obrigatório',
            'contact_id.exists' => 'O contato de emergência não existe',
        ];
    }
}
