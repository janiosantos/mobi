import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

/// Interceptor that automatically retries failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  /// Maximum number of retry attempts
  final int maxRetries;

  /// Initial delay before first retry (in milliseconds)
  final int initialDelayMs;

  /// Multiplier for exponential backoff
  final double backoffMultiplier;

  /// Maximum delay between retries (in milliseconds)
  final int maxDelayMs;

  /// List of HTTP status codes that should trigger a retry
  final List<int> retryStatusCodes;

  /// Callback for retry events (useful for logging)
  final void Function(int attempt, Duration delay, DioException error)?
      onRetry;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelayMs = 1000,
    this.backoffMultiplier = 2.0,
    this.maxDelayMs = 30000,
    this.retryStatusCodes = const [
      408, // Request Timeout
      429, // Too Many Requests
      500, // Internal Server Error
      502, // Bad Gateway
      503, // Service Unavailable
      504, // Gateway Timeout
    ],
    this.onRetry,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if request should be retried
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Get retry count from extra data
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      // Max retries reached, pass error to handler
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final delay = _calculateDelay(retryCount);

    // Call onRetry callback if provided
    onRetry?.call(retryCount + 1, delay, err);

    // Wait before retrying
    await Future.delayed(delay);

    // Create new request options with incremented retry count
    final newRequestOptions = err.requestOptions.copyWith(
      extra: {
        ...err.requestOptions.extra,
        'retryCount': retryCount + 1,
      },
    );

    try {
      // Retry the request
      final response = await Dio().fetch(newRequestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // If retry fails, continue with error handler
      return super.onError(e, handler);
    }
  }

  /// Check if request should be retried based on error type
  bool _shouldRetry(DioException error) {
    // Don't retry if request was cancelled
    if (error.type == DioExceptionType.cancel) {
      return false;
    }

    // Retry on connection timeout
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on network errors
    if (error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific status codes
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      if (statusCode != null && retryStatusCodes.contains(statusCode)) {
        return true;
      }
    }

    // Retry on socket exceptions (connection issues)
    if (error.error is SocketException) {
      return true;
    }

    // Retry on timeout exceptions
    if (error.error is TimeoutException) {
      return true;
    }

    return false;
  }

  /// Calculate delay for next retry with exponential backoff
  Duration _calculateDelay(int retryCount) {
    // Calculate exponential delay: initialDelay * (multiplier ^ retryCount)
    final delayMs = (initialDelayMs * (backoffMultiplier * retryCount)).toInt();

    // Cap at maximum delay
    final cappedDelayMs = delayMs > maxDelayMs ? maxDelayMs : delayMs;

    // Add jitter (random variation) to prevent thundering herd
    final jitter = (cappedDelayMs * 0.2).toInt(); // ±20% jitter
    final randomJitter = jitter - (jitter * 2 * (DateTime.now().millisecond / 1000)).toInt();

    final finalDelayMs = cappedDelayMs + randomJitter;

    return Duration(milliseconds: finalDelayMs > 0 ? finalDelayMs : cappedDelayMs);
  }
}

/// Extension to add copy method to RequestOptions
extension RequestOptionsCopyWith on RequestOptions {
  RequestOptions copyWith({
    String? method,
    String? baseUrl,
    String? path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    Duration? connectTimeout,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    ResponseType? responseType,
    ValidateStatus? validateStatus,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    Object? data,
    CancelToken? cancelToken,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    ListFormat? listFormat,
  }) {
    return RequestOptions(
      method: method ?? this.method,
      baseUrl: baseUrl ?? this.baseUrl,
      path: path ?? this.path,
      queryParameters: queryParameters ?? this.queryParameters,
      extra: extra ?? this.extra,
      headers: headers ?? this.headers,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      responseType: responseType ?? this.responseType,
      validateStatus: validateStatus ?? this.validateStatus,
      onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
      onSendProgress: onSendProgress ?? this.onSendProgress,
      data: data ?? this.data,
      cancelToken: cancelToken ?? this.cancelToken,
      receiveDataWhenStatusError: receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      listFormat: listFormat ?? this.listFormat,
    );
  }
}
