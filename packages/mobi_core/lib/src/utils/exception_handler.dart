import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => message;

  bool get isNetworkError =>
      statusCode == null &&
      (code == 'network_error' || code == 'timeout_error');

  bool get isServerError =>
      statusCode != null && statusCode! >= 500;

  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isValidationError => statusCode == 422;
}

class ExceptionHandler {
  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    return AppException(
      message: 'Erro inesperado: ${error.toString()}',
      code: 'unknown_error',
      originalException: error,
    );
  }

  static AppException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppException(
          message: 'Tempo de conexão esgotado. Verifique sua internet.',
          code: 'timeout_error',
          originalException: error,
        );

      case DioExceptionType.sendTimeout:
        return AppException(
          message: 'Tempo de envio esgotado. Tente novamente.',
          code: 'timeout_error',
          originalException: error,
        );

      case DioExceptionType.receiveTimeout:
        return AppException(
          message: 'Tempo de resposta esgotado. Tente novamente.',
          code: 'timeout_error',
          originalException: error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return AppException(
          message: 'Requisição cancelada',
          code: 'cancelled',
          originalException: error,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return AppException(
          message: 'Erro de conexão. Verifique sua internet.',
          code: 'network_error',
          originalException: error,
        );

      default:
        return AppException(
          message: 'Erro de rede: ${error.message}',
          code: 'network_error',
          originalException: error,
        );
    }
  }

  static AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message;
    String? code;

    // Try to extract message from response
    if (data is Map) {
      message = data['message'] ?? data['error'] ?? 'Erro no servidor';
      code = data['code'];
    } else {
      message = _getMessageForStatusCode(statusCode);
    }

    return AppException(
      message: message,
      code: code ?? 'http_error',
      statusCode: statusCode,
      originalException: error,
    );
  }

  static String _getMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida';
      case 401:
        return 'Não autorizado. Faça login novamente.';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 422:
        return 'Dados inválidos';
      case 429:
        return 'Muitas requisições. Aguarde um momento.';
      case 500:
        return 'Erro interno do servidor';
      case 502:
        return 'Servidor temporariamente indisponível';
      case 503:
        return 'Serviço indisponível';
      default:
        return 'Erro no servidor ($statusCode)';
    }
  }

  static String getUserFriendlyMessage(dynamic error) {
    final appException = handle(error);

    if (appException.isNetworkError) {
      return 'Verifique sua conexão com a internet e tente novamente.';
    }

    if (appException.isServerError) {
      return 'Nossos servidores estão temporariamente indisponíveis. Por favor, tente novamente em alguns instantes.';
    }

    if (appException.isUnauthorized) {
      return 'Sua sessão expirou. Por favor, faça login novamente.';
    }

    return appException.message;
  }

  static bool shouldRetry(dynamic error) {
    final appException = handle(error);

    // Retry on network errors and server errors (5xx)
    return appException.isNetworkError || appException.isServerError;
  }
}
