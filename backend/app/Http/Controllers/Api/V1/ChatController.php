<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Chat\SendMessageRequest;
use App\Http\Resources\MessageResource;
use App\Models\Message;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ChatController extends Controller
{
    /**
     * Get messages for a ride
     */
    public function index(Request $request, Ride $ride): JsonResponse
    {
        try {
            $user = $request->user();

            // Verify user is part of this ride
            if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para ver estas mensagens.',
                ], 403);
            }

            $messages = Message::where('ride_id', $ride->id)
                ->with(['sender', 'receiver'])
                ->orderBy('created_at', 'asc')
                ->get();

            // Mark messages as read
            Message::where('ride_id', $ride->id)
                ->where('receiver_id', $user->id)
                ->where('is_read', false)
                ->update([
                    'is_read' => true,
                    'read_at' => now(),
                ]);

            return response()->json([
                'data' => MessageResource::collection($messages),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar mensagens.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Send a message
     */
    public function send(SendMessageRequest $request, Ride $ride): JsonResponse
    {
        try {
            $user = $request->user();

            // Verify user is part of this ride
            if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para enviar mensagens nesta corrida.',
                ], 403);
            }

            $validated = $request->validated();

            // Determine receiver
            $receiverId = $ride->passenger_id === $user->id
                ? $ride->driver_id
                : $ride->passenger_id;

            $messageData = [
                'ride_id' => $ride->id,
                'sender_id' => $user->id,
                'receiver_id' => $receiverId,
                'message' => $validated['message'],
                'type' => $validated['type'] ?? 'text',
            ];

            // Handle attachment if present
            if ($request->hasFile('attachment')) {
                $attachmentPath = $request->file('attachment')
                    ->store('chat-attachments/' . $ride->id, 'private');
                $messageData['attachment_url'] = $attachmentPath;
                $messageData['type'] = 'image';
            }

            $message = Message::create($messageData);

            // TODO: Broadcast message via WebSocket
            // broadcast(new MessageSent($message))->toOthers();

            return response()->json([
                'message' => 'Mensagem enviada com sucesso!',
                'data' => new MessageResource($message->load(['sender', 'receiver'])),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao enviar mensagem.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get unread message count
     */
    public function unreadCount(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            $unreadCount = Message::where('receiver_id', $user->id)
                ->where('is_read', false)
                ->count();

            return response()->json([
                'data' => [
                    'unread_count' => $unreadCount,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar mensagens não lidas.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mark message as read
     */
    public function markAsRead(Request $request, Message $message): JsonResponse
    {
        try {
            $user = $request->user();

            if ($message->receiver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            $message->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

            return response()->json([
                'message' => 'Mensagem marcada como lida.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao marcar mensagem como lida.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
