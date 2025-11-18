<?php

namespace App\Http\Requests\Driver;

use Illuminate\Foundation\Http\FormRequest;

class UploadDocumentRequest extends FormRequest
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
            'document_type' => [
                'required',
                'in:license_front,license_back,profile_photo,vehicle_registration,vehicle_insurance,criminal_record,proof_of_address'
            ],
            'document_file' => ['required', 'file', 'mimes:jpg,jpeg,png,pdf', 'max:5120'], // 5MB
            'document_number' => ['nullable', 'string', 'max:100'],
            'expiry_date' => ['nullable', 'date', 'after:today'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'document_type.required' => 'O tipo de documento é obrigatório.',
            'document_type.in' => 'Tipo de documento inválido.',
            'document_file.required' => 'O arquivo do documento é obrigatório.',
            'document_file.mimes' => 'O documento deve ser JPG, PNG ou PDF.',
            'document_file.max' => 'O documento não pode ser maior que 5MB.',
            'expiry_date.after' => 'A data de validade deve ser futura.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'document_type' => 'tipo de documento',
            'document_file' => 'arquivo do documento',
            'document_number' => 'número do documento',
            'expiry_date' => 'data de validade',
        ];
    }
}
