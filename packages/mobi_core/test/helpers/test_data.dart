import 'package:mobi_core/mobi_core.dart';

/// Test data factory for creating mock objects
class TestData {
  // Test User
  static User testUser({
    int id = 1,
    String name = 'Test User',
    String email = 'test@example.com',
    String? phone = '11999999999',
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      photoUrl: 'https://example.com/photo.jpg',
      averageRating: 4.5,
      totalRides: 10,
      createdAt: DateTime.now(),
    );
  }

  // Test Ride
  static Ride testRide({
    int id = 1,
    String status = 'pending',
    int? driverId,
    int passengerId = 1,
    double pickupLatitude = -23.550520,
    double pickupLongitude = -46.633308,
    double? destinationLatitude = -23.561684,
    double? destinationLongitude = -46.656139,
    String pickupAddress = 'Av. Paulista, 1000',
    String? destinationAddress = 'Av. Faria Lima, 2000',
    double? estimatedPrice = 25.50,
    double? finalPrice,
  }) {
    return Ride(
      id: id,
      status: status,
      driverId: driverId,
      passengerId: passengerId,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      estimatedPrice: estimatedPrice,
      finalPrice: finalPrice,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Test Payment Method
  static PaymentMethod testPaymentMethod({
    int id = 1,
    String type = 'credit_card',
    bool isDefault = true,
    String? lastFourDigits = '1234',
    String? cardBrand = 'visa',
    String? expiryMonth = '12',
    String? expiryYear = '2025',
  }) {
    return PaymentMethod(
      id: id,
      userId: 1,
      type: type,
      isDefault: isDefault,
      lastFourDigits: lastFourDigits,
      cardBrand: cardBrand,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      createdAt: DateTime.now(),
    );
  }

  // Test Payment
  static Payment testPayment({
    int id = 1,
    int rideId = 1,
    double amount = 25.50,
    String status = 'completed',
    String method = 'credit_card',
    String? transactionId = 'TXN123456',
  }) {
    return Payment(
      id: id,
      rideId: rideId,
      amount: amount,
      status: status,
      method: method,
      transactionId: transactionId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Test Chat Message
  static ChatMessage testChatMessage({
    int id = 1,
    int rideId = 1,
    int senderId = 1,
    String senderType = 'passenger',
    String message = 'Test message',
    String type = 'text',
    bool isRead = false,
  }) {
    return ChatMessage(
      id: id,
      rideId: rideId,
      senderId: senderId,
      senderType: senderType,
      message: message,
      type: type,
      isRead: isRead,
      createdAt: DateTime.now(),
    );
  }

  // Test Vehicle Category
  static VehicleCategory testVehicleCategory({
    int id = 1,
    String name = 'Standard',
    String description = 'Standard ride',
    double basePrice = 5.0,
    double pricePerKm = 2.5,
    double pricePerMinute = 0.5,
  }) {
    return VehicleCategory(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      pricePerKm: pricePerKm,
      pricePerMinute: pricePerMinute,
      image: 'https://example.com/category.png',
    );
  }

  // Test Location
  static Location testLocation({
    double latitude = -23.550520,
    double longitude = -46.633308,
    String? address = 'Av. Paulista, 1000',
    double? accuracy,
  }) {
    return Location(
      latitude: latitude,
      longitude: longitude,
      address: address,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );
  }

  // Test Saved Place
  static SavedPlace testSavedPlace({
    int id = 1,
    String name = 'Home',
    String type = 'home',
    double latitude = -23.550520,
    double longitude = -46.633308,
    String address = 'Av. Paulista, 1000',
  }) {
    return SavedPlace(
      id: id,
      userId: 1,
      name: name,
      type: type,
      latitude: latitude,
      longitude: longitude,
      address: address,
      createdAt: DateTime.now(),
    );
  }

  // API Response Wrappers
  static Map<String, dynamic> successResponse({
    dynamic data,
    String? message,
  }) {
    return {
      'success': true,
      'data': data,
      if (message != null) 'message': message,
    };
  }

  static Map<String, dynamic> errorResponse({
    String message = 'Error occurred',
    int? code,
    dynamic errors,
  }) {
    return {
      'success': false,
      'message': message,
      if (code != null) 'code': code,
      if (errors != null) 'errors': errors,
    };
  }
}
