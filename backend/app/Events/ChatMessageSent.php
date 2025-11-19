<?php

namespace App\Events;

use App\Models\ChatMessage;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatMessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public ChatMessage $message;

    /**
     * Create a new event instance.
     */
    public function __construct(ChatMessage $message)
    {
        $this->message = $message;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('ride.' . $this->message->ride_id),
            new PrivateChannel('user.' . $this->message->ride->passenger_id),
            new PrivateChannel('user.' . $this->message->ride->driver_id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'chat.message.sent';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'id' => $this->message->id,
            'ride_id' => $this->message->ride_id,
            'sender_id' => $this->message->sender_id,
            'sender_name' => $this->message->sender_name,
            'sender_type' => $this->message->sender_type,
            'message' => $this->message->message,
            'type' => $this->message->type,
            'attachment_url' => $this->message->attachment_url,
            'is_read' => $this->message->is_read,
            'created_at' => $this->message->created_at->toIso8601String(),
        ];
    }
}
