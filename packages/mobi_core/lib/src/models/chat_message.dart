import 'package:equatable/equatable.dart';

/// Chat message model for real-time messaging
class ChatMessage extends Equatable {
  final String id;
  final int rideId;
  final int senderId;
  final String senderName;
  final String senderType; // 'passenger' or 'driver'
  final String message;
  final ChatMessageType type;
  final DateTime createdAt;
  final bool isRead;
  final String? attachmentUrl;

  const ChatMessage({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.attachmentUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      rideId: json['ride_id'] as int,
      senderId: json['sender_id'] as int,
      senderName: json['sender_name'] as String,
      senderType: json['sender_type'] as String,
      message: json['message'] as String,
      type: _messageTypeFromString(json['type'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      attachmentUrl: json['attachment_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_type': senderType,
      'message': message,
      'type': type.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'attachment_url': attachmentUrl,
    };
  }

  ChatMessage copyWith({
    String? id,
    int? rideId,
    int? senderId,
    String? senderName,
    String? senderType,
    String? message,
    ChatMessageType? type,
    DateTime? createdAt,
    bool? isRead,
    String? attachmentUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  static ChatMessageType _messageTypeFromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'text':
        return ChatMessageType.text;
      case 'image':
        return ChatMessageType.image;
      case 'location':
        return ChatMessageType.location;
      case 'system':
        return ChatMessageType.system;
      default:
        return ChatMessageType.text;
    }
  }

  @override
  List<Object?> get props => [
        id,
        rideId,
        senderId,
        senderName,
        senderType,
        message,
        type,
        createdAt,
        isRead,
        attachmentUrl,
      ];
}

/// Chat message types
enum ChatMessageType {
  text,
  image,
  location,
  system,
}
