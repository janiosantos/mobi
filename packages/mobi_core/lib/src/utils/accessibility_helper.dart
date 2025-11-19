import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Helper class for accessibility features
class AccessibilityHelper {
  /// Announce a message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Check if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get semantic label for ride status
  static String getRideStatusSemanticLabel(String status) {
    switch (status.toLowerCase()) {
      case 'searching':
        return 'Procurando motorista. Aguarde.';
      case 'accepted':
        return 'Motorista aceitou. A caminho do local de embarque.';
      case 'arrived':
        return 'Motorista chegou ao local de embarque.';
      case 'in_progress':
        return 'Corrida em andamento.';
      case 'completed':
        return 'Corrida concluída com sucesso.';
      case 'cancelled':
        return 'Corrida cancelada.';
      default:
        return status;
    }
  }

  /// Format currency for screen readers
  static String formatCurrencyForScreenReader(double amount) {
    final reais = amount.floor();
    final centavos = ((amount - reais) * 100).round();

    if (centavos == 0) {
      return '$reais ${reais == 1 ? "real" : "reais"}';
    }

    return '$reais ${reais == 1 ? "real" : "reais"} e $centavos ${centavos == 1 ? "centavo" : "centavos"}';
  }

  /// Format distance for screen readers
  static String formatDistanceForScreenReader(int meters) {
    if (meters < 1000) {
      return '$meters ${meters == 1 ? "metro" : "metros"}';
    }

    final km = (meters / 1000).toStringAsFixed(1);
    return '$km quilômetros';
  }

  /// Format duration for screen readers
  static String formatDurationForScreenReader(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '$remainingSeconds ${remainingSeconds == 1 ? "segundo" : "segundos"}';
    }

    if (remainingSeconds == 0) {
      return '$minutes ${minutes == 1 ? "minuto" : "minutos"}';
    }

    return '$minutes ${minutes == 1 ? "minuto" : "minutos"} e $remainingSeconds ${remainingSeconds == 1 ? "segundo" : "segundos"}';
  }

  /// Create semantics widget for images
  static Widget semanticImage({
    required String imageUrl,
    required String semanticLabel,
    required Widget child,
  }) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(child: child),
    );
  }

  /// Create accessible card with proper contrast
  static Widget accessibleCard({
    required Widget child,
    String? semanticLabel,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    final card = Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: ExcludeSemantics(child: card),
      );
    }

    return card;
  }

  /// Create live region for dynamic content updates
  static Widget liveRegion({
    required String message,
    required Widget child,
    bool assertive = false,
  }) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: child,
    );
  }
}
