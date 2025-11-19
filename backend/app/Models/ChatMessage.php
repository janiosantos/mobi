<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'ride_id',
        'sender_id',
        'sender_type',
        'message',
        'type',
        'attachment_url',
        'is_read',
    ];

    protected $casts = [
        'is_read' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = ['sender_name'];

    /**
     * Get the ride that this message belongs to.
     */
    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    /**
     * Get the sender of the message.
     */
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Get the sender name attribute.
     */
    public function getSenderNameAttribute()
    {
        return $this->sender ? $this->sender->name : 'Unknown';
    }

    /**
     * Scope to filter messages by ride.
     */
    public function scopeForRide($query, $rideId)
    {
        return $query->where('ride_id', $rideId);
    }

    /**
     * Scope to filter unread messages.
     */
    public function scopeUnread($query)
    {
        return $query->where('is_read', false);
    }

    /**
     * Mark message as read.
     */
    public function markAsRead()
    {
        $this->update(['is_read' => true]);
    }
}
