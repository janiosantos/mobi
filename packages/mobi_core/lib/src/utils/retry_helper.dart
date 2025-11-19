import 'dart:async';

class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool Function(Exception)? retryIf;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.retryIf,
  });
}

class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() function, {
    RetryConfig config = const RetryConfig(),
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    var attempt = 0;
    var delay = config.initialDelay;

    while (true) {
      attempt++;

      try {
        return await function();
      } on Exception catch (e) {
        // Check if we should retry
        final shouldRetry = config.retryIf?.call(e) ?? true;

        if (attempt >= config.maxAttempts || !shouldRetry) {
          rethrow;
        }

        // Notify about retry
        onRetry?.call(attempt, e);

        // Wait before retrying with exponential backoff
        await Future.delayed(delay);

        // Calculate next delay with exponential backoff
        delay = Duration(
          milliseconds: (delay.inMilliseconds * config.backoffMultiplier).toInt(),
        );

        // Cap at max delay
        if (delay > config.maxDelay) {
          delay = config.maxDelay;
        }
      }
    }
  }

  // Retry specific to network errors
  static Future<T> retryNetwork<T>(
    Future<T> Function() function, {
    int maxAttempts = 3,
    void Function(int attempt, Exception error)? onRetry,
  }) {
    return retry(
      function,
      config: RetryConfig(
        maxAttempts: maxAttempts,
        retryIf: (e) {
          // Retry on network-related exceptions
          final message = e.toString().toLowerCase();
          return message.contains('socket') ||
              message.contains('network') ||
              message.contains('connection') ||
              message.contains('timeout');
        },
      ),
      onRetry: onRetry,
    );
  }

  // Retry with custom delays
  static Future<T> retryWithDelays<T>(
    Future<T> Function() function,
    List<Duration> delays, {
    bool Function(Exception)? retryIf,
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    var attempt = 0;

    while (true) {
      attempt++;

      try {
        return await function();
      } on Exception catch (e) {
        final shouldRetry = retryIf?.call(e) ?? true;

        if (attempt > delays.length || !shouldRetry) {
          rethrow;
        }

        onRetry?.call(attempt, e);

        await Future.delayed(delays[attempt - 1]);
      }
    }
  }
}

// Result wrapper for operations that can fail
class Result<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  const Result.success(this.data)
      : error = null,
        isSuccess = true;

  const Result.failure(this.error)
      : data = null,
        isSuccess = false;

  bool get isFailure => !isSuccess;

  R when<R>({
    required R Function(T data) success,
    required R Function(Exception error) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return failure(error!);
    }
  }

  T getOrElse(T Function() defaultValue) {
    return data ?? defaultValue();
  }

  T? getOrNull() => data;

  static Future<Result<T>> from<T>(Future<T> Function() function) async {
    try {
      final result = await function();
      return Result.success(result);
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }
}
