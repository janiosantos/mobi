import 'package:flutter/material.dart';

/// Chat input widget for sending messages
class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onSendImage;
  final VoidCallback? onSendLocation;
  final bool enabled;
  final String? hintText;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.onSendImage,
    this.onSendLocation,
    this.enabled = true,
    this.hintText,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.onSendImage != null)
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: widget.enabled ? widget.onSendImage : null,
                color: Theme.of(context).primaryColor,
                tooltip: 'Enviar imagem',
              ),
            if (widget.onSendLocation != null)
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: widget.enabled ? widget.onSendLocation : null,
                color: Theme.of(context).primaryColor,
                tooltip: 'Enviar localização',
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Digite uma mensagem...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: widget.enabled ? (_) => _sendMessage() : null,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _hasText && widget.enabled
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              child: IconButton(
                icon: const Icon(Icons.send, size: 20),
                onPressed: _hasText && widget.enabled ? _sendMessage : null,
                color: Colors.white,
                tooltip: 'Enviar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
