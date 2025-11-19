import 'package:flutter/material.dart';

/// Accessibility constants following WCAG 2.1 Level AA guidelines
class AccessibilityConstants {
  // Private constructor to prevent instantiation
  AccessibilityConstants._();

  /// Minimum tap target size (WCAG 2.5.5)
  static const double minTapTargetSize = 48.0;

  /// Minimum text size for readability
  static const double minTextSize = 14.0;

  /// Body text size
  static const double bodyTextSize = 16.0;

  /// Heading text size
  static const double headingTextSize = 20.0;

  /// Large heading text size
  static const double largeHeadingTextSize = 24.0;

  /// Minimum contrast ratio for normal text (WCAG Level AA)
  static const double minContrastRatioNormal = 4.5;

  /// Minimum contrast ratio for large text (WCAG Level AA)
  static const double minContrastRatioLarge = 3.0;

  /// Standard spacing for accessibility
  static const double standardSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;

  /// Animation durations (keep short for accessibility)
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// High contrast colors for dark mode
  static const Color highContrastTextLight = Colors.white;
  static const Color highContrastTextDark = Colors.black;
  static const Color highContrastBackgroundLight = Colors.black;
  static const Color highContrastBackgroundDark = Colors.white;

  /// Focus indicator color
  static const Color focusColor = Colors.blue;
  static const double focusIndicatorWidth = 3.0;

  /// Screen reader delays
  static const Duration screenReaderDelay = Duration(milliseconds: 500);
  static const Duration screenReaderLongDelay = Duration(seconds: 1);

  /// Text scaling limits
  static const double minTextScaleFactor = 1.0;
  static const double maxTextScaleFactor = 2.0;

  /// Semantic labels for common actions
  static const String semanticBack = 'Voltar';
  static const String semanticClose = 'Fechar';
  static const String semanticMenu = 'Menu';
  static const String semanticSearch = 'Buscar';
  static const String semanticSettings = 'Configurações';
  static const String semanticNotifications = 'Notificações';
  static const String semanticProfile = 'Perfil';
  static const String semanticHelp = 'Ajuda';
  static const String semanticRefresh = 'Atualizar';
  static const String semanticFilter = 'Filtrar';
  static const String semanticSort = 'Ordenar';
  static const String semanticExpand = 'Expandir';
  static const String semanticCollapse = 'Recolher';
  static const String semanticPlay = 'Reproduzir';
  static const String semanticPause = 'Pausar';
  static const String semanticNext = 'Próximo';
  static const String semanticPrevious = 'Anterior';

  /// Error announcement delay
  static const Duration errorAnnouncementDelay = Duration(milliseconds: 300);

  /// Success announcement delay
  static const Duration successAnnouncementDelay = Duration(milliseconds: 500);

  /// Loading announcement delay
  static const Duration loadingAnnouncementDelay = Duration(milliseconds: 1000);
}
