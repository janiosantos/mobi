import 'package:flutter/material.dart';

/// Accessible icon button with proper semantics and minimum tap target size
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final iconButton = IconButton(
      icon: Icon(icon, size: size),
      onPressed: onPressed,
      color: color,
      iconSize: size,
      constraints: const BoxConstraints(
        minWidth: 48, // WCAG minimum tap target
        minHeight: 48,
      ),
      tooltip: tooltip ?? semanticLabel,
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      hint: tooltip,
      child: ExcludeSemantics(
        child: iconButton,
      ),
    );
  }
}
