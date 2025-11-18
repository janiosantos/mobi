<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Message extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'ride_id', 'sender_id', 'recipient_id', 'sender_type',
        'message', 'type', 'attachment_url', 'location_latitude',
        'location_longitude', 'is_read', 'read_at',
    ];

    protected function casts(): array
    {
        return [
            'location_latitude' => 'decimal:7',
            'location_longitude' => 'decimal:7',
            'is_read' => 'boolean',
            'read_at' => 'datetime',
        ];
    }

    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function recipient()
    {
        return $this->belongsTo(User::class, 'recipient_id');
    }

    public function scopeUnread($query)
    {
        return $query->where('is_read', false);
    }
}
