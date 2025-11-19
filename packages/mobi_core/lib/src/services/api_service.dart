import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../constants/api_constants.dart';
import '../models/user.dart';
import '../models/ride.dart';
import '../models/payment.dart';
import '../models/vehicle.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Auth
  @POST(ApiConstants.login)
  Future<HttpResponse<Map<String, dynamic>>> login(
    @Body() Map<String, dynamic> credentials,
  );

  @POST(ApiConstants.registerPassenger)
  Future<HttpResponse<Map<String, dynamic>>> registerPassenger(
    @Body() Map<String, dynamic> data,
  );

  @POST(ApiConstants.registerDriver)
  Future<HttpResponse<Map<String, dynamic>>> registerDriver(
    @Body() Map<String, dynamic> data,
  );

  @POST(ApiConstants.logout)
  Future<HttpResponse<void>> logout();

  @GET(ApiConstants.profile)
  Future<HttpResponse<Map<String, dynamic>>> getProfile();

  @PUT(ApiConstants.updateProfile)
  Future<HttpResponse<Map<String, dynamic>>> updateProfile(
    @Body() Map<String, dynamic> data,
  );

  // Rides - Passenger
  @GET(ApiConstants.rides)
  Future<HttpResponse<Map<String, dynamic>>> getRides(
    @Queries() Map<String, dynamic> queries,
  );

  @POST(ApiConstants.estimateRide)
  Future<HttpResponse<Map<String, dynamic>>> estimateRide(
    @Body() Map<String, dynamic> data,
  );

  @POST(ApiConstants.rides)
  Future<HttpResponse<Map<String, dynamic>>> requestRide(
    @Body() Map<String, dynamic> data,
  );

  @GET('/rides/{id}')
  Future<HttpResponse<Map<String, dynamic>>> getRideDetail(
    @Path('id') int id,
  );

  @POST('/rides/{id}/cancel')
  Future<HttpResponse<Map<String, dynamic>>> cancelRide(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @POST('/rides/{id}/rate')
  Future<HttpResponse<Map<String, dynamic>>> rateRide(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  // Rides - Driver
  @GET(ApiConstants.availableRides)
  Future<HttpResponse<Map<String, dynamic>>> getAvailableRides(
    @Queries() Map<String, dynamic> queries,
  );

  @GET(ApiConstants.activeRide)
  Future<HttpResponse<Map<String, dynamic>>> getActiveRide();

  @POST('/driver/rides/{id}/accept')
  Future<HttpResponse<Map<String, dynamic>>> acceptRide(
    @Path('id') int id,
  );

  @POST('/driver/rides/{id}/arrive')
  Future<HttpResponse<Map<String, dynamic>>> markArrival(
    @Path('id') int id,
  );

  @POST('/driver/rides/{id}/start')
  Future<HttpResponse<Map<String, dynamic>>> startRide(
    @Path('id') int id,
  );

  @POST('/driver/rides/{id}/complete')
  Future<HttpResponse<Map<String, dynamic>>> completeRide(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @POST('/driver/rides/{id}/cancel')
  Future<HttpResponse<Map<String, dynamic>>> driverCancelRide(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  // Driver Profile
  @GET(ApiConstants.driverProfile)
  Future<HttpResponse<Map<String, dynamic>>> getDriverProfile();

  @PUT(ApiConstants.updateDriverProfile)
  Future<HttpResponse<Map<String, dynamic>>> updateDriverProfile(
    @Body() Map<String, dynamic> data,
  );

  @POST(ApiConstants.toggleOnline)
  Future<HttpResponse<Map<String, dynamic>>> toggleOnlineStatus();

  @POST(ApiConstants.updateLocation)
  Future<HttpResponse<void>> updateLocation(
    @Body() Map<String, dynamic> data,
  );

  @GET(ApiConstants.driverEarnings)
  Future<HttpResponse<Map<String, dynamic>>> getDriverEarnings();

  @GET(ApiConstants.driverStatistics)
  Future<HttpResponse<Map<String, dynamic>>> getDriverStatistics();

  // Vehicles
  @GET(ApiConstants.vehicles)
  Future<HttpResponse<Map<String, dynamic>>> getVehicles();

  @POST(ApiConstants.vehicles)
  Future<HttpResponse<Map<String, dynamic>>> createVehicle(
    @Body() Map<String, dynamic> data,
  );

  @GET('/driver/vehicles/{id}')
  Future<HttpResponse<Map<String, dynamic>>> getVehicleDetail(
    @Path('id') int id,
  );

  @PUT('/driver/vehicles/{id}')
  Future<HttpResponse<Map<String, dynamic>>> updateVehicle(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/driver/vehicles/{id}')
  Future<HttpResponse<void>> deleteVehicle(
    @Path('id') int id,
  );

  @POST('/driver/vehicles/{id}/activate')
  Future<HttpResponse<Map<String, dynamic>>> activateVehicle(
    @Path('id') int id,
  );

  @GET(ApiConstants.vehicleCategories)
  Future<HttpResponse<Map<String, dynamic>>> getVehicleCategories();

  // Payments
  @GET(ApiConstants.payments)
  Future<HttpResponse<Map<String, dynamic>>> getPayments(
    @Queries() Map<String, dynamic> queries,
  );

  @GET(ApiConstants.paymentMethods)
  Future<HttpResponse<Map<String, dynamic>>> getPaymentMethods();

  @POST(ApiConstants.paymentMethods)
  Future<HttpResponse<Map<String, dynamic>>> addPaymentMethod(
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/payment-methods/{id}')
  Future<HttpResponse<void>> deletePaymentMethod(
    @Path('id') int id,
  );

  @PATCH('/payment-methods/{id}/default')
  Future<HttpResponse<Map<String, dynamic>>> setDefaultPaymentMethod(
    @Path('id') int id,
  );

  @POST('/rides/{id}/payment')
  Future<HttpResponse<Map<String, dynamic>>> createRidePayment(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  // Notifications
  @GET(ApiConstants.notifications)
  Future<HttpResponse<Map<String, dynamic>>> getNotifications(
    @Queries() Map<String, dynamic> queries,
  );

  @PATCH('/notifications/{id}/read')
  Future<HttpResponse<Map<String, dynamic>>> markNotificationAsRead(
    @Path('id') int id,
  );

  @POST(ApiConstants.markAllRead)
  Future<HttpResponse<void>> markAllNotificationsAsRead();

  @GET(ApiConstants.unreadCount)
  Future<HttpResponse<Map<String, dynamic>>> getUnreadCount();

  @POST(ApiConstants.updateDeviceToken)
  Future<HttpResponse<void>> updateDeviceToken(
    @Body() Map<String, dynamic> data,
  );
}
