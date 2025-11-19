class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  // Endpoints - Auth
  static const String login = '/auth/login';
  static const String registerPassenger = '/auth/register/passenger';
  static const String registerDriver = '/auth/register/driver';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';

  // Endpoints - Rides (Passenger)
  static const String rides = '/rides';
  static const String estimateRide = '/rides/estimate';
  static const String rideDetail = '/rides/{id}';
  static const String cancelRide = '/rides/{id}/cancel';
  static const String rateRide = '/rides/{id}/rate';

  // Endpoints - Rides (Driver)
  static const String availableRides = '/driver/rides/available';
  static const String activeRide = '/driver/rides/active';
  static const String acceptRide = '/driver/rides/{id}/accept';
  static const String arriveRide = '/driver/rides/{id}/arrive';
  static const String startRide = '/driver/rides/{id}/start';
  static const String completeRide = '/driver/rides/{id}/complete';
  static const String driverCancelRide = '/driver/rides/{id}/cancel';

  // Endpoints - Driver
  static const String driverProfile = '/driver/profile';
  static const String updateDriverProfile = '/driver/profile';
  static const String toggleOnline = '/driver/toggle-online';
  static const String updateLocation = '/driver/location';
  static const String driverEarnings = '/driver/earnings';
  static const String driverStatistics = '/driver/statistics';

  // Endpoints - Vehicles
  static const String vehicles = '/driver/vehicles';
  static const String vehicleDetail = '/driver/vehicles/{id}';
  static const String activateVehicle = '/driver/vehicles/{id}/activate';
  static const String vehicleCategories = '/vehicle-categories';

  // Endpoints - Payments
  static const String payments = '/payments';
  static const String paymentMethods = '/payment-methods';
  static const String paymentMethodDetail = '/payment-methods/{id}';
  static const String setDefaultPaymentMethod = '/payment-methods/{id}/default';
  static const String createRidePayment = '/rides/{id}/payment';

  // Endpoints - Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String markAllRead = '/notifications/read-all';
  static const String unreadCount = '/notifications/unread-count';
  static const String updateDeviceToken = '/notifications/device-token';

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String accept = 'Accept';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Helper method to replace path parameters
  static String replacePath(String path, Map<String, dynamic> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}
