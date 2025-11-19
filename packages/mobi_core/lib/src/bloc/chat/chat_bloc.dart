import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/chat_repository.dart';
import '../../models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  Timer? _typingTimer;

  ChatBloc({required this.chatRepository}) : super(const ChatInitial()) {
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<SendLocationMessage>(_onSendLocationMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<TypingStatusChanged>(_onTypingStatusChanged);
    on<OtherUserTypingReceived>(_onOtherUserTypingReceived);
    on<ClearChat>(_onClearChat);
    on<DeleteMessage>(_onDeleteMessage);
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (event.page == 1) {
      emit(const ChatLoading());
    }

    try {
      final result = await chatRepository.getChatMessages(
        event.rideId,
        page: event.page,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final messagesData = data['data'] as List<dynamic>;
        final messages =
            messagesData.map((json) => ChatMessage.fromJson(json)).toList();

        // Sort messages by timestamp (newest first for chat UI)
        messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final currentState = state;
        final existingMessages = currentState is ChatMessagesLoaded
            ? currentState.messages
            : <ChatMessage>[];

        // Merge existing and new messages if loading more pages
        final allMessages = event.page > 1
            ? [...existingMessages, ...messages]
            : messages;

        emit(ChatMessagesLoaded(
          messages: allMessages,
          rideId: event.rideId,
          currentPage: data['current_page'] ?? event.page,
          hasMore: data['current_page'] < (data['last_page'] ?? 0),
        ));
      } else {
        emit(ChatError(result['message'] ?? 'Erro ao carregar mensagens'));
      }
    } catch (e) {
      emit(ChatError('Erro ao carregar mensagens: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();

    emit(ChatSendingMessage(
      tempId: tempId,
      message: event.message,
      timestamp: timestamp,
    ));

    try {
      final data = {
        'message': event.message,
        'type': 'text',
      };

      final result = await chatRepository.sendMessage(event.rideId, data);

      if (result['success'] == true) {
        final message = ChatMessage.fromJson(result['data']);
        emit(ChatMessageSent(message));

        // Reload messages to show the new one
        add(LoadChatMessages(rideId: event.rideId));
      } else {
        emit(ChatMessageSendFailed(
          tempId: tempId,
          error: result['message'] ?? 'Erro ao enviar mensagem',
        ));
      }
    } catch (e) {
      emit(ChatMessageSendFailed(
        tempId: tempId,
        error: 'Erro ao enviar mensagem: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();

    emit(ChatSendingMessage(
      tempId: tempId,
      message: event.caption ?? 'Imagem',
      timestamp: timestamp,
    ));

    try {
      // TODO: Implement image upload logic
      // This would typically involve:
      // 1. Upload image to storage (S3, etc.)
      // 2. Get image URL
      // 3. Send message with image URL

      final data = {
        'message': event.caption ?? '',
        'type': 'image',
        'image_path': event.imagePath,
      };

      final result = await chatRepository.sendMessage(event.rideId, data);

      if (result['success'] == true) {
        final message = ChatMessage.fromJson(result['data']);
        emit(ChatMessageSent(message));

        // Reload messages
        add(LoadChatMessages(rideId: event.rideId));
      } else {
        emit(ChatMessageSendFailed(
          tempId: tempId,
          error: result['message'] ?? 'Erro ao enviar imagem',
        ));
      }
    } catch (e) {
      emit(ChatMessageSendFailed(
        tempId: tempId,
        error: 'Erro ao enviar imagem: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSendLocationMessage(
    SendLocationMessage event,
    Emitter<ChatState> emit,
  ) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();

    emit(ChatSendingMessage(
      tempId: tempId,
      message: 'Localização compartilhada',
      timestamp: timestamp,
    ));

    try {
      final data = {
        'message': event.address ?? 'Localização compartilhada',
        'type': 'location',
        'latitude': event.latitude,
        'longitude': event.longitude,
      };

      final result = await chatRepository.sendMessage(event.rideId, data);

      if (result['success'] == true) {
        final message = ChatMessage.fromJson(result['data']);
        emit(ChatMessageSent(message));

        // Reload messages
        add(LoadChatMessages(rideId: event.rideId));
      } else {
        emit(ChatMessageSendFailed(
          tempId: tempId,
          error: result['message'] ?? 'Erro ao compartilhar localização',
        ));
      }
    } catch (e) {
      emit(ChatMessageSendFailed(
        tempId: tempId,
        error: 'Erro ao compartilhar localização: ${e.toString()}',
      ));
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final result = await chatRepository.markAsRead(event.rideId);

      if (result['success'] == true) {
        emit(ChatMessagesMarkedAsRead(event.rideId));

        // Reload messages to update read status
        add(LoadChatMessages(rideId: event.rideId));
      }
    } catch (e) {
      // Silent fail - not critical
    }
  }

  Future<void> _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = ChatMessage.fromJson(event.message);
      emit(ChatNewMessageReceived(message));

      // Update messages list if we're viewing this ride's chat
      final currentState = state;
      if (currentState is ChatMessagesLoaded &&
          currentState.rideId == message.rideId) {
        final updatedMessages = [message, ...currentState.messages];
        emit(currentState.copyWith(messages: updatedMessages));
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _onTypingStatusChanged(
    TypingStatusChanged event,
    Emitter<ChatState> emit,
  ) async {
    // Cancel previous timer
    _typingTimer?.cancel();

    // Send typing status to backend
    // This would typically be a WebSocket event
    // For now, we'll just emit the state

    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      emit(ChatTypingIndicator(
        rideId: event.rideId,
        isTyping: event.isTyping,
        isOtherUserTyping: currentState.isOtherUserTyping,
      ));

      // Return to messages loaded state
      emit(currentState);
    }

    // Auto-stop typing after 3 seconds
    if (event.isTyping) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        add(TypingStatusChanged(rideId: event.rideId, isTyping: false));
      });
    }
  }

  Future<void> _onOtherUserTypingReceived(
    OtherUserTypingReceived event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      emit(currentState.copyWith(isOtherUserTyping: event.isTyping));
    }
  }

  Future<void> _onClearChat(
    ClearChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatInitial());
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final result = await chatRepository.deleteMessage(event.messageId);

      if (result['success'] == true) {
        emit(ChatMessageDeleted(event.messageId));

        // Update messages list
        final currentState = state;
        if (currentState is ChatMessagesLoaded) {
          final updatedMessages = currentState.messages
              .where((msg) => msg.id != event.messageId)
              .toList();
          emit(currentState.copyWith(messages: updatedMessages));
        }
      } else {
        emit(ChatError(result['message'] ?? 'Erro ao deletar mensagem'));
      }
    } catch (e) {
      emit(ChatError('Erro ao deletar mensagem: ${e.toString()}'));
    }
  }
}
