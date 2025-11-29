import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_location_screen.dart';
import '../screens/ride_estimate_screen.dart';
import '../screens/request_ride_screen.dart';
import '../screens/ride_tracking_screen.dart';
import '../screens/ride_detail_screen.dart';
import '../screens/ride_history_screen.dart';
import '../screens/ride_rating_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/add_payment_method_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shared_rides_search_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/emergency_contacts_screen.dart';
import '../screens/saved_places_screen.dart';
import '../screens/gamification_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String searchLocation = '/search-location';
  static const String rideEstimate = '/ride-estimate';
  static const String requestRide = '/request-ride';
  static const String rideTracking = '/ride-tracking';
  static const String rideDetail = '/ride-detail';
  static const String rideHistory = '/ride-history';
  static const String rideRating = '/ride-rating';
  static const String paymentMethods = '/payment-methods';
  static const String addPaymentMethod = '/add-payment-method';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String sharedRidesSearch = '/shared-rides-search';
  static const String helpCenter = '/help-center';
  static const String emergencyContacts = '/emergency-contacts';
  static const String savedPlaces = '/saved-places';
  static const String gamification = '/gamification';

  // Routes map
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        searchLocation: (context) => const SearchLocationScreen(),
        rideHistory: (context) => const RideHistoryScreen(),
        paymentMethods: (context) => const PaymentMethodsScreen(),
        addPaymentMethod: (context) => const AddPaymentMethodScreen(),
        settings: (context) => const SettingsScreen(),
        profile: (context) => const ProfileScreen(),
        sharedRidesSearch: (context) => const SharedRidesSearchScreen(),
        helpCenter: (context) => const HelpCenterScreen(),
        emergencyContacts: (context) => const EmergencyContactsScreen(),
        savedPlaces: (context) => const SavedPlacesScreen(),
        gamification: (context) => const GamificationScreen(),
      };

  // Route with arguments
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case rideEstimate:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => RideEstimateScreen(
            pickupLocation: args['pickupLocation'] as LatLng,
            pickupAddress: args['pickupAddress'] as String,
            dropoffLocation: args['dropoffLocation'] as LatLng?,
            dropoffAddress: args['dropoffAddress'] as String?,
          ),
        );

      case requestRide:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => RequestRideScreen(
            pickupLocation: args['pickupLocation'] as LatLng,
            pickupAddress: args['pickupAddress'] as String,
            dropoffLocation: args['dropoffLocation'] as LatLng,
            dropoffAddress: args['dropoffAddress'] as String,
            categoryId: args['categoryId'] as int,
            estimatedPrice: args['estimatedPrice'] as double,
          ),
        );

      case rideTracking:
        final rideId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => RideTrackingScreen(rideId: rideId),
        );

      case rideDetail:
        final rideId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => RideDetailScreen(rideId: rideId),
        );

      case rideRating:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => RideRatingScreen(
            rideId: args['rideId'] as int,
            driverName: args['driverName'] as String,
            driverPhotoUrl: args['driverPhotoUrl'] as String?,
          ),
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
  static Future<T?> push<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacement<T, TO>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, TO>(context, routeName, arguments: arguments);
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

  static Future<void> goToRideTracking(BuildContext context, int rideId) {
    return push(context, rideTracking, arguments: rideId);
  }

  static Future<void> goToRideDetail(BuildContext context, int rideId) {
    return push(context, rideDetail, arguments: rideId);
  }

  static Future<void> goToSettings(BuildContext context) {
    return push(context, settings);
  }

  static Future<void> goToProfile(BuildContext context) {
    return push(context, profile);
  }

  static Future<void> goToPaymentMethods(BuildContext context) {
    return push(context, paymentMethods);
  }

  static Future<void> goToRideHistory(BuildContext context) {
    return push(context, rideHistory);
  }
}
