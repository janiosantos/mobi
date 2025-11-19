<?php

namespace App\Http\Controllers;

use App\Events\ChatMessageSent;
use App\Models\ChatMessage;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get chat messages for a ride.
     */
    public function index(Request $request, Ride $ride): JsonResponse
    {
        // Verify user is part of this ride
        $user = $request->user();
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $messages = ChatMessage::forRide($ride->id)
            ->with('sender:id,name,photo_url')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'data' => $messages
        ]);
    }

    /**
     * Send a chat message.
     */
    public function store(Request $request, Ride $ride): JsonResponse
    {
        $user = $request->user();

        // Verify user is part of this ride
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'message' => 'required|string|max:1000',
            'type' => 'in:text,image,location,system',
            'image' => 'image|max:5120', // 5MB max
            'latitude' => 'numeric|between:-90,90',
            'longitude' => 'numeric|between:-180,180',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $senderType = $ride->passenger_id === $user->id ? 'passenger' : 'driver';
        $type = $request->input('type', 'text');
        $attachmentUrl = null;

        // Handle image upload
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('chat-images', 'public');
            $attachmentUrl = Storage::url($path);
            $type = 'image';
        }

        // Handle location message
        if ($type === 'location' && $request->has('latitude') && $request->has('longitude')) {
            $attachmentUrl = json_encode([
                'latitude' => $request->input('latitude'),
                'longitude' => $request->input('longitude'),
            ]);
        }

        $message = ChatMessage::create([
            'ride_id' => $ride->id,
            'sender_id' => $user->id,
            'sender_type' => $senderType,
            'message' => $request->input('message'),
            'type' => $type,
            'attachment_url' => $attachmentUrl,
        ]);

        $message->load('sender:id,name,photo_url');

        // Broadcast message via WebSocket
        broadcast(new ChatMessageSent($message))->toOthers();

        return response()->json([
            'data' => $message
        ], 201);
    }

    /**
     * Mark a message as read.
     */
    public function markAsRead(Request $request, Ride $ride, ChatMessage $message): JsonResponse
    {
        $user = $request->user();

        // Verify user is part of this ride
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Verify message belongs to this ride
        if ($message->ride_id !== $ride->id) {
            return response()->json([
                'message' => 'Message not found'
            ], 404);
        }

        // User cannot mark their own messages as read
        if ($message->sender_id === $user->id) {
            return response()->json([
                'message' => 'Cannot mark own message as read'
            ], 400);
        }

        $message->markAsRead();

        return response()->json([
            'message' => 'Message marked as read'
        ]);
    }

    /**
     * Mark all messages as read.
     */
    public function markAllAsRead(Request $request, Ride $ride): JsonResponse
    {
        $user = $request->user();

        // Verify user is part of this ride
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        ChatMessage::forRide($ride->id)
            ->where('sender_id', '!=', $user->id)
            ->unread()
            ->update(['is_read' => true]);

        return response()->json([
            'message' => 'All messages marked as read'
        ]);
    }

    /**
     * Get unread message count.
     */
    public function unreadCount(Request $request, Ride $ride): JsonResponse
    {
        $user = $request->user();

        // Verify user is part of this ride
        if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $count = ChatMessage::forRide($ride->id)
            ->where('sender_id', '!=', $user->id)
            ->unread()
            ->count();

        return response()->json([
            'count' => $count
        ]);
    }
}
