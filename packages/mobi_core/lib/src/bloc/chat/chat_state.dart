import 'package:equatable/equatable.dart';
import '../../models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading messages
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Messages loaded
class ChatMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final int rideId;
  final int currentPage;
  final bool hasMore;
  final bool isOtherUserTyping;

  const ChatMessagesLoaded({
    required this.messages,
    required this.rideId,
    this.currentPage = 1,
    this.hasMore = false,
    this.isOtherUserTyping = false,
  });

  @override
  List<Object> get props => [
        messages,
        rideId,
        currentPage,
        hasMore,
        isOtherUserTyping,
      ];

  /// Copy with method for updates
  ChatMessagesLoaded copyWith({
    List<ChatMessage>? messages,
    int? rideId,
    int? currentPage,
    bool? hasMore,
    bool? isOtherUserTyping,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      rideId: rideId ?? this.rideId,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
    );
  }
}

/// Sending message
class ChatSendingMessage extends ChatState {
  final String tempId;
  final String message;
  final DateTime timestamp;

  const ChatSendingMessage({
    required this.tempId,
    required this.message,
    required this.timestamp,
  });

  @override
  List<Object> get props => [tempId, message, timestamp];
}

/// Message sent successfully
class ChatMessageSent extends ChatState {
  final ChatMessage message;

  const ChatMessageSent(this.message);

  @override
  List<Object> get props => [message];
}

/// Message send failed
class ChatMessageSendFailed extends ChatState {
  final String tempId;
  final String error;

  const ChatMessageSendFailed({
    required this.tempId,
    required this.error,
  });

  @override
  List<Object> get props => [tempId, error];
}

/// New message received (push notification or real-time)
class ChatNewMessageReceived extends ChatState {
  final ChatMessage message;

  const ChatNewMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

/// Messages marked as read
class ChatMessagesMarkedAsRead extends ChatState {
  final int rideId;

  const ChatMessagesMarkedAsRead(this.rideId);

  @override
  List<Object> get props => [rideId];
}

/// Typing indicator
class ChatTypingIndicator extends ChatState {
  final int rideId;
  final bool isTyping;
  final bool isOtherUserTyping;

  const ChatTypingIndicator({
    required this.rideId,
    required this.isTyping,
    this.isOtherUserTyping = false,
  });

  @override
  List<Object> get props => [rideId, isTyping, isOtherUserTyping];
}

/// Message deleted
class ChatMessageDeleted extends ChatState {
  final int messageId;

  const ChatMessageDeleted(this.messageId);

  @override
  List<Object> get props => [messageId];
}

/// Error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
