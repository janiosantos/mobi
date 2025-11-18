<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DriverDocument extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'driver_profile_id',
        'document_type',
        'file_path',
        'file_name',
        'mime_type',
        'file_size',
        'status',
        'rejection_reason',
        'verified_at',
        'verified_by',
        'expiry_date',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'verified_at' => 'datetime',
            'expiry_date' => 'date',
            'metadata' => 'array',
        ];
    }

    public function driverProfile()
    {
        return $this->belongsTo(DriverProfile::class);
    }

    public function verifier()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    public function isExpired(): bool
    {
        return $this->expiry_date && $this->expiry_date->isPast();
    }
}
