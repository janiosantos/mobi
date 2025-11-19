<?php

namespace App\Events;

use App\Models\User;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class UserLeveledUp implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $user;
    public $newLevel;

    /**
     * Create a new event instance.
     */
    public function __construct(User $user, int $newLevel)
    {
        $this->user = $user;
        $this->newLevel = $newLevel;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): Channel
    {
        return new PrivateChannel('user.' . $this->user->id);
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'user_id' => $this->user->id,
            'new_level' => $this->newLevel,
            'stats' => [
                'total_xp' => $this->user->stats->total_xp,
                'current_xp' => $this->user->stats->current_xp,
                'xp_to_next_level' => $this->user->stats->xp_to_next_level,
            ],
            'timestamp' => now()->toIso8601String(),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'user.leveled-up';
    }
}
