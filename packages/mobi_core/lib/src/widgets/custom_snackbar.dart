import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      switch (type) {
        case SnackBarType.success:
          HapticFeedback.lightImpact();
          break;
        case SnackBarType.error:
          HapticFeedback.heavyImpact();
          break;
        case SnackBarType.warning:
          HapticFeedback.mediumImpact();
          break;
        case SnackBarType.info:
          HapticFeedback.selectionClick();
          break;
      }
    }

    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          color: AppConstants.successColor,
          icon: Icons.check_circle,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          color: AppConstants.errorColor,
          icon: Icons.error,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          color: AppConstants.warningColor,
          icon: Icons.warning,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          color: AppConstants.infoColor,
          icon: Icons.info,
        );
    }
  }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  _SnackBarConfig({
    required this.color,
    required this.icon,
  });
}
