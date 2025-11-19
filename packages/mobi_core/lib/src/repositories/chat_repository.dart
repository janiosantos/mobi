import '../services/api_service.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  /// Get chat messages for a ride
  Future<Map<String, dynamic>> getChatMessages(
    int rideId, {
    int page = 1,
  }) async {
    try {
      final response = await _apiService.getChatMessages(rideId, page);
      final data = response.data;

      return {
        'success': true,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao carregar mensagens: ${e.toString()}',
      };
    }
  }

  /// Send a message
  Future<Map<String, dynamic>> sendMessage(
    int rideId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.sendChatMessage(rideId, data);
      final responseData = response.data;

      return {
        'success': true,
        'data': responseData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao enviar mensagem: ${e.toString()}',
      };
    }
  }

  /// Mark messages as read
  Future<Map<String, dynamic>> markAsRead(int rideId) async {
    try {
      final response = await _apiService.markChatMessagesAsRead(rideId);
      final data = response.data;

      return {
        'success': true,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao marcar como lido: ${e.toString()}',
      };
    }
  }

  /// Delete a message
  Future<Map<String, dynamic>> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.deleteChatMessage(messageId);
      final data = response.data;

      return {
        'success': true,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao deletar mensagem: ${e.toString()}',
      };
    }
  }
}
