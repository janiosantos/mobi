import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor that logs HTTP requests and responses for debugging
class LoggingInterceptor extends Interceptor {
  final Logger logger;
  final bool logRequestHeader;
  final bool logRequestBody;
  final bool logResponseHeader;
  final bool logResponseBody;
  final bool logError;

  LoggingInterceptor({
    Logger? logger,
    this.logRequestHeader = true,
    this.logRequestBody = true,
    this.logResponseHeader = false,
    this.logResponseBody = true,
    this.logError = true,
  }) : logger = logger ?? Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 75,
            colors: true,
            printEmojis: true,
            printTime: true,
          ),
        );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final uri = options.uri;

    logger.i('╔═══════════════════════════════════════════════════════');
    logger.i('║ ➡️  REQUEST: $method $uri');
    logger.i('╠═══════════════════════════════════════════════════════');

    if (logRequestHeader && options.headers.isNotEmpty) {
      logger.d('║ Headers:');
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        final maskedValue = _maskSensitiveData(key, value.toString());
        logger.d('║   $key: $maskedValue');
      });
    }

    if (logRequestBody && options.data != null) {
      logger.d('║ Body:');
      logger.d('║   ${_formatData(options.data)}');
    }

    if (options.queryParameters.isNotEmpty) {
      logger.d('║ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        logger.d('║   $key: $value');
      });
    }

    logger.i('╚═══════════════════════════════════════════════════════');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method.toUpperCase();
    final uri = response.requestOptions.uri;
    final statusCode = response.statusCode;
    final isSuccess = statusCode != null && statusCode >= 200 && statusCode < 300;

    logger.i('╔═══════════════════════════════════════════════════════');
    logger.i('║ ⬅️  RESPONSE: $method $uri');
    logger.i('║ Status Code: $statusCode ${isSuccess ? '✅' : '❌'}');
    logger.i('╠═══════════════════════════════════════════════════════');

    if (logResponseHeader && response.headers.map.isNotEmpty) {
      logger.d('║ Headers:');
      response.headers.map.forEach((key, value) {
        logger.d('║   $key: ${value.join(', ')}');
      });
    }

    if (logResponseBody && response.data != null) {
      logger.d('║ Body:');
      logger.d('║   ${_formatData(response.data)}');
    }

    logger.i('╚═══════════════════════════════════════════════════════');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!logError) {
      return super.onError(err, handler);
    }

    final method = err.requestOptions.method.toUpperCase();
    final uri = err.requestOptions.uri;

    logger.e('╔═══════════════════════════════════════════════════════');
    logger.e('║ ❌ ERROR: $method $uri');
    logger.e('║ Type: ${err.type}');
    logger.e('║ Message: ${err.message}');
    logger.e('╠═══════════════════════════════════════════════════════');

    if (err.response != null) {
      logger.e('║ Status Code: ${err.response?.statusCode}');

      if (err.response?.data != null) {
        logger.e('║ Response:');
        logger.e('║   ${_formatData(err.response!.data)}');
      }
    }

    if (err.stackTrace != null) {
      logger.e('║ StackTrace:');
      logger.e(err.stackTrace.toString());
    }

    logger.e('╚═══════════════════════════════════════════════════════');

    super.onError(err, handler);
  }

  /// Format data for logging (handle different types)
  String _formatData(dynamic data) {
    if (data == null) return 'null';

    if (data is Map || data is List) {
      try {
        return data.toString();
      } catch (e) {
        return data.toString();
      }
    }

    return data.toString();
  }

  /// Mask sensitive data in headers/body
  String _maskSensitiveData(String key, String value) {
    final lowerKey = key.toLowerCase();

    // List of sensitive keys that should be masked
    final sensitiveKeys = [
      'authorization',
      'token',
      'api-key',
      'apikey',
      'password',
      'secret',
      'private',
      'cvv',
      'card',
      'cpf',
    ];

    for (final sensitiveKey in sensitiveKeys) {
      if (lowerKey.contains(sensitiveKey)) {
        // Mask all but last 4 characters
        if (value.length > 4) {
          return '${'*' * (value.length - 4)}${value.substring(value.length - 4)}';
        } else {
          return '***';
        }
      }
    }

    return value;
  }
}
