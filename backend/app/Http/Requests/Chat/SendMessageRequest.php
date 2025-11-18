<?php

namespace App\Http\Requests\Chat;

use Illuminate\Foundation\Http\FormRequest;

class SendMessageRequest extends FormRequest
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
            'message' => ['required', 'string', 'max:1000'],
            'type' => ['nullable', 'in:text,image,location'],
            'attachment' => ['nullable', 'file', 'mimes:jpg,jpeg,png', 'max:5120'], // 5MB
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'message.required' => 'A mensagem é obrigatória.',
            'message.max' => 'A mensagem não pode ter mais de 1000 caracteres.',
            'type.in' => 'Tipo de mensagem inválido.',
            'attachment.mimes' => 'O arquivo deve ser JPG ou PNG.',
            'attachment.max' => 'O arquivo não pode ser maior que 5MB.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'message' => 'mensagem',
            'type' => 'tipo',
            'attachment' => 'anexo',
        ];
    }
}
