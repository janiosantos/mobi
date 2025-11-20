import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/active_ride_screen.dart';
import '../screens/ride_history_screen.dart';
import '../screens/earnings_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/documents_screen.dart';
import '../screens/vehicles_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String activeRide = '/active-ride';
  static const String rideHistory = '/ride-history';
  static const String earnings = '/earnings';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String helpCenter = '/help-center';
  static const String documents = '/documents';
  static const String vehicles = '/vehicles';

  // Routes map
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        rideHistory: (context) => const RideHistoryScreen(),
        earnings: (context) => const EarningsScreen(),
        settings: (context) => const SettingsScreen(),
        profile: (context) => const ProfileScreen(),
        helpCenter: (context) => const HelpCenterScreen(),
        documents: (context) => const DocumentsScreen(),
        vehicles: (context) => const VehiclesScreen(),
      };

  // Route with arguments
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case activeRide:
        final rideId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => ActiveRideScreen(rideId: rideId),
        );

      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ChatScreen(
            rideId: args['rideId'] as int,
            otherUserName: args['otherUserName'] as String,
            otherUserPhotoUrl: args['otherUserPhotoUrl'] as String?,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }

  // Navigation helpers
  static Future<T?> push<T>(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacement<T, TO>(BuildContext context,
      String routeName,
      {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, TO>(context, routeName,
        arguments: arguments);
  }

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Shortcuts for common navigations
  static Future<void> goToHome(BuildContext context) {
    return pushAndRemoveUntil(context, home);
  }

  static Future<void> goToLogin(BuildContext context) {
    return pushAndRemoveUntil(context, login);
  }

  static Future<void> goToActiveRide(BuildContext context, int rideId) {
    return push(context, activeRide, arguments: rideId);
  }

  static Future<void> goToSettings(BuildContext context) {
    return push(context, settings);
  }

  static Future<void> goToProfile(BuildContext context) {
    return push(context, profile);
  }

  static Future<void> goToEarnings(BuildContext context) {
    return push(context, earnings);
  }

  static Future<void> goToRideHistory(BuildContext context) {
    return push(context, rideHistory);
  }

  static Future<void> goToDocuments(BuildContext context) {
    return push(context, documents);
  }

  static Future<void> goToVehicles(BuildContext context) {
    return push(context, vehicles);
  }
}
