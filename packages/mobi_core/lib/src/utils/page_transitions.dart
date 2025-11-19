import 'package:flutter/material.dart';

enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideFromBottom,
  slideFromTop,
  slideFromLeft,
  slideFromRight,
}

class PageTransitions {
  static Route<T> createRoute<T>({
    required Widget page,
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(type, animation, secondaryAnimation, child);
      },
    );
  }

  static Widget _buildTransition(
    TransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case TransitionType.slide:
      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }

  // Helper method for navigation with custom transition
  static Future<T?> push<T>(
    BuildContext context, {
    required Widget page,
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      createRoute<T>(
        page: page,
        type: type,
        duration: duration,
      ),
    );
  }

  // Helper method for replacement with custom transition
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context, {
    required Widget page,
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
    TO? result,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      createRoute<T>(
        page: page,
        type: type,
        duration: duration,
      ),
      result: result,
    );
  }

  // Helper method for push and remove until
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context, {
    required Widget page,
    required RoutePredicate predicate,
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      createRoute<T>(
        page: page,
        type: type,
        duration: duration,
      ),
      predicate,
    );
  }
}

// Extension for easier usage
extension NavigatorExtension on BuildContext {
  Future<T?> pushWithTransition<T>(
    Widget page, {
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageTransitions.push<T>(
      this,
      page: page,
      type: type,
      duration: duration,
    );
  }

  Future<T?> pushReplacementWithTransition<T, TO>(
    Widget page, {
    TransitionType type = TransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
    TO? result,
  }) {
    return PageTransitions.pushReplacement<T, TO>(
      this,
      page: page,
      type: type,
      duration: duration,
      result: result,
    );
  }
}
