import 'dart:async';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import 'api_service.dart';

/// Service for managing chat messages
class ChatService {
  final ApiService _apiService;
  final StreamController<ChatMessage> _messageStreamController =
      StreamController<ChatMessage>.broadcast();

  ChatService(this._apiService);

  /// Stream of incoming messages
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  /// Send a text message
  Future<ChatMessage> sendMessage({
    required int rideId,
    required String message,
    ChatMessageType type = ChatMessageType.text,
  }) async {
    try {
      final response = await _apiService.post(
        '/rides/$rideId/messages',
        data: {
          'message': message,
          'type': type.toString().split('.').last,
        },
      );

      return ChatMessage.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send location message
  Future<ChatMessage> sendLocation({
    required int rideId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiService.post(
        '/rides/$rideId/messages',
        data: {
          'message': 'Localização compartilhada',
          'type': 'location',
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return ChatMessage.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to send location: $e');
    }
  }

  /// Upload and send image message
  Future<ChatMessage> sendImage({
    required int rideId,
    required String imagePath,
    String? message,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        'message': message ?? 'Imagem',
        'type': 'image',
      });

      final response = await _apiService.post(
        '/rides/$rideId/messages',
        data: formData,
      );

      return ChatMessage.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to send image: $e');
    }
  }

  /// Get chat history for a ride
  Future<List<ChatMessage>> getChatHistory(int rideId) async {
    try {
      final response = await _apiService.get('/rides/$rideId/messages');

      final List<dynamic> messagesJson = response.data['data'];
      return messagesJson
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  /// Mark message as read
  Future<void> markAsRead(int rideId, String messageId) async {
    try {
      await _apiService.put(
        '/rides/$rideId/messages/$messageId/read',
      );
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  /// Mark all messages as read
  Future<void> markAllAsRead(int rideId) async {
    try {
      await _apiService.put(
        '/rides/$rideId/messages/read-all',
      );
    } catch (e) {
      throw Exception('Failed to mark all messages as read: $e');
    }
  }

  /// Get unread message count
  Future<int> getUnreadCount(int rideId) async {
    try {
      final response = await _apiService.get(
        '/rides/$rideId/messages/unread-count',
      );

      return response.data['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  /// Handle incoming message from WebSocket
  void handleIncomingMessage(ChatMessage message) {
    _messageStreamController.add(message);
  }

  /// Dispose resources
  void dispose() {
    _messageStreamController.close();
  }
}
