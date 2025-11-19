import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MOBI';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyOnboardingComplete = 'onboarding_complete';
  static const String storageKeyThemeMode = 'theme_mode';

  // Ride Status
  static const String rideStatusSearching = 'searching';
  static const String rideStatusAccepted = 'accepted';
  static const String rideStatusArrived = 'arrived';
  static const String rideStatusInProgress = 'in_progress';
  static const String rideStatusCompleted = 'completed';
  static const String rideStatusCancelled = 'cancelled';

  // Payment Types
  static const String paymentTypePix = 'pix';
  static const String paymentTypeCreditCard = 'credit_card';
  static const String paymentTypeDebitCard = 'debit_card';
  static const String paymentTypeCash = 'cash';

  // Google Maps
  static const double defaultMapZoom = 15.0;
  static const double defaultMapTilt = 0.0;
  static const double defaultMapBearing = 0.0;

  // Location
  static const int locationUpdateIntervalSeconds = 5;
  static const double locationAccuracy = 10.0; // meters

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String cpfRegex = r'^\d{3}\.\d{3}\.\d{3}-\d{2}$';

  // Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue

  // Typography
  static const String fontFamily = 'Inter';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Ride
  static const int rideSearchTimeoutSeconds = 120;
  static const double minRideRating = 1.0;
  static const double maxRideRating = 5.0;

  // Driver
  static const int driverAcceptanceTimeoutSeconds = 60;
  static const int driverArrivalTimeoutSeconds = 600; // 10 minutes
}
