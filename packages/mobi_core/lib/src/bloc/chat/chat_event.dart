import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Load chat messages for a ride
class LoadChatMessages extends ChatEvent {
  final int rideId;
  final int page;

  const LoadChatMessages({
    required this.rideId,
    this.page = 1,
  });

  @override
  List<Object> get props => [rideId, page];
}

/// Send a text message
class SendMessage extends ChatEvent {
  final int rideId;
  final String message;

  const SendMessage({
    required this.rideId,
    required this.message,
  });

  @override
  List<Object> get props => [rideId, message];
}

/// Send an image message
class SendImageMessage extends ChatEvent {
  final int rideId;
  final String imagePath;
  final String? caption;

  const SendImageMessage({
    required this.rideId,
    required this.imagePath,
    this.caption,
  });

  @override
  List<Object?> get props => [rideId, imagePath, caption];
}

/// Send location message
class SendLocationMessage extends ChatEvent {
  final int rideId;
  final double latitude;
  final double longitude;
  final String? address;

  const SendLocationMessage({
    required this.rideId,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  List<Object?> get props => [rideId, latitude, longitude, address];
}

/// Mark messages as read
class MarkMessagesAsRead extends ChatEvent {
  final int rideId;

  const MarkMessagesAsRead(this.rideId);

  @override
  List<Object> get props => [rideId];
}

/// New message received (from real-time update)
class NewMessageReceived extends ChatEvent {
  final Map<String, dynamic> message;

  const NewMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

/// Typing status changed
class TypingStatusChanged extends ChatEvent {
  final int rideId;
  final bool isTyping;

  const TypingStatusChanged({
    required this.rideId,
    required this.isTyping,
  });

  @override
  List<Object> get props => [rideId, isTyping];
}

/// Other user typing status received
class OtherUserTypingReceived extends ChatEvent {
  final bool isTyping;

  const OtherUserTypingReceived(this.isTyping);

  @override
  List<Object> get props => [isTyping];
}

/// Clear chat
class ClearChat extends ChatEvent {
  const ClearChat();
}

/// Delete message
class DeleteMessage extends ChatEvent {
  final int messageId;

  const DeleteMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}
