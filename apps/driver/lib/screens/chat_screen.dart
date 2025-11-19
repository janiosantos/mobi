import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';

class ChatScreen extends StatefulWidget {
  final int rideId;
  final String recipientName;

  const ChatScreen({
    super.key,
    required this.rideId,
    required this.recipientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = getIt<ChatService>();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenToNewMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getChatHistory(widget.rideId);
      setState(() {
        _messages.clear();
        _messages.addAll(messages);
        _isLoading = false;
      });

      // Mark all messages as read
      await _chatService.markAllAsRead(widget.rideId);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        CustomSnackbar.showError(context, 'Erro ao carregar mensagens');
      }
    }
  }

  void _listenToNewMessages() {
    _chatService.messageStream.listen((message) {
      if (message.rideId == widget.rideId) {
        setState(() {
          _messages.add(message);
        });

        // Mark as read if not from me
        final currentUserId = getIt<AuthService>().currentUser?.id;
        if (message.senderId != currentUserId) {
          _chatService.markAsRead(widget.rideId, message.id);
        }

        // Scroll to bottom
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    // Implement scroll to bottom after next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll logic here if using ScrollController
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final message = await _chatService.sendMessage(
        rideId: widget.rideId,
        message: text,
      );

      setState(() {
        _messages.add(message);
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      if (mounted) {
        CustomSnackbar.showError(context, 'Erro ao enviar mensagem');
      }
    }
  }

  Future<void> _sendLocation() async {
    try {
      final locationService = getIt<LocationService>();
      final position = await locationService.getCurrentLocation();

      if (position == null) {
        if (mounted) {
          CustomSnackbar.showError(context, 'Não foi possível obter localização');
        }
        return;
      }

      final message = await _chatService.sendLocation(
        rideId: widget.rideId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _messages.add(message);
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Erro ao enviar localização');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<AuthService>().currentUser?.id ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: EmptyState(
                          icon: Icons.chat_bubble_outline,
                          title: 'Nenhuma mensagem',
                          message: 'Envie uma mensagem para iniciar a conversa',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == currentUserId;

                          return ChatBubble(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      ),
          ),
          ChatInput(
            onSendMessage: _sendMessage,
            onSendLocation: _sendLocation,
            enabled: !_isSending,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
