<?php

declare(strict_types=1);

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;

class UploadPhotoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'photo' => ['required', 'image', 'mimes:jpeg,jpg,png', 'max:5120'], // 5MB max
        ];
    }

    public function messages(): array
    {
        return [
            'photo.required' => 'Photo is required',
            'photo.image' => 'File must be an image',
            'photo.mimes' => 'Photo must be jpeg, jpg, or png',
            'photo.max' => 'Photo must not exceed 5MB',
        ];
    }
}
