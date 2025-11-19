import 'package:mocktail/mocktail.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:dio/dio.dart';

// Repository Mocks
class MockRideRepository extends Mock implements RideRepository {}
class MockPaymentRepository extends Mock implements PaymentRepository {}
class MockChatRepository extends Mock implements ChatRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

// Service Mocks
class MockLocationService extends Mock implements LocationService {}
class MockApiService extends Mock implements ApiService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockChatService extends Mock implements ChatService {}

// Cache Mocks
class MockCacheManager extends Mock implements CacheManager {}

// Dio Mocks
class MockDio extends Mock implements Dio {}
class MockRequestOptions extends Mock implements RequestOptions {}
class MockResponse extends Mock implements Response {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockResponseInterceptorHandler extends Mock implements ResponseInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

// Model Fallback Values for Mocktail
class FakeRide extends Fake implements Ride {}
class FakePayment extends Fake implements Payment {}
class FakePaymentMethod extends Fake implements PaymentMethod {}
class FakeChatMessage extends Fake implements ChatMessage {}
class FakeUser extends Fake implements User {}
class FakeRequestOptions extends Fake implements RequestOptions {}
class FakeResponse extends Fake implements Response {}
class FakeDioException extends Fake implements DioException {}
