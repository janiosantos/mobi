import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Helper class for network connectivity management
class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;
  NetworkHelper._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  ConnectivityResult? _lastResult;

  final _connectivityController = StreamController<ConnectivityResult>.broadcast();
  final _statusController = StreamController<bool>.broadcast();

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController.stream;

  /// Stream of connection status (true = connected, false = disconnected)
  Stream<bool> get connectionStatusStream => _statusController.stream;

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Get initial status
    _lastResult = await _connectivity.checkConnectivity();
    _connectivityController.add(_lastResult!);
    _statusController.add(_isConnected(_lastResult!));

    // Listen for changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (result != _lastResult) {
          _lastResult = result;
          _connectivityController.add(result);
          _statusController.add(_isConnected(result));
        }
      },
    );
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
    _statusController.close();
  }

  /// Check if currently connected
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  /// Get current connection type
  Future<ConnectionType> getConnectionType() async {
    final result = await _connectivity.checkConnectivity();
    return _mapToConnectionType(result);
  }

  /// Check if connected to WiFi
  Future<bool> isWiFi() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected to mobile data
  Future<bool> isMobileData() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  /// Check if connected to ethernet
  Future<bool> isEthernet() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.ethernet;
  }

  /// Check if connected to VPN
  Future<bool> isVPN() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.vpn;
  }

  /// Check if no connection
  Future<bool> isOffline() async {
    return !await isConnected();
  }

  /// Check if connection is suitable for large downloads
  Future<bool> isSuitableForDownloads() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  /// Check if should use data saver mode (mobile data)
  Future<bool> shouldUseDataSaver() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  /// Get connection quality estimate
  Future<ConnectionQuality> getConnectionQuality() async {
    final result = await _connectivity.checkConnectivity();

    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return ConnectionQuality.good;
      case ConnectivityResult.mobile:
        return ConnectionQuality.medium;
      case ConnectivityResult.vpn:
        return ConnectionQuality.medium;
      default:
        return ConnectionQuality.poor;
    }
  }

  /// Wait for connection to be available
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (await isConnected()) return true;

    final completer = Completer<bool>();
    StreamSubscription? subscription;

    subscription = connectionStatusStream.listen((isConnected) {
      if (isConnected) {
        completer.complete(true);
        subscription?.cancel();
      }
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        subscription?.cancel();
        return false;
      },
    );
  }

  /// Execute action when connected
  Future<T?> executeWhenConnected<T>(
    Future<T> Function() action, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final hasConnection = await waitForConnection(timeout: timeout);

    if (hasConnection) {
      return await action();
    }

    return null;
  }

  /// Retry action with exponential backoff
  Future<T?> retryWithBackoff<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;

    while (retryCount < maxRetries) {
      try {
        if (await isConnected()) {
          return await action();
        } else {
          throw Exception('No internet connection');
        }
      } catch (e) {
        retryCount++;

        if (retryCount >= maxRetries) {
          rethrow;
        }

        await Future.delayed(delay);
        delay *= backoffMultiplier;
      }
    }

    return null;
  }

  /// Get connection status message for UI
  Future<String> getConnectionStatusMessage() async {
    if (!await isConnected()) {
      return 'Sem conexão com a internet';
    }

    final type = await getConnectionType();

    switch (type) {
      case ConnectionType.wifi:
        return 'Conectado via WiFi';
      case ConnectionType.mobile:
        return 'Conectado via dados móveis';
      case ConnectionType.ethernet:
        return 'Conectado via ethernet';
      case ConnectionType.vpn:
        return 'Conectado via VPN';
      case ConnectionType.none:
        return 'Sem conexão';
      default:
        return 'Conexão desconhecida';
    }
  }

  /// Get icon name for current connection
  Future<String> getConnectionIcon() async {
    final type = await getConnectionType();

    switch (type) {
      case ConnectionType.wifi:
        return 'wifi';
      case ConnectionType.mobile:
        return 'signal_cellular_alt';
      case ConnectionType.ethernet:
        return 'settings_ethernet';
      case ConnectionType.vpn:
        return 'vpn_lock';
      case ConnectionType.none:
        return 'signal_wifi_off';
      default:
        return 'help_outline';
    }
  }

  /// Internal helper to check if connected
  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// Internal helper to map to connection type enum
  ConnectionType _mapToConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      default:
        return ConnectionType.none;
    }
  }
}

/// Connection type enum
enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  vpn,
  none,
}

/// Connection quality enum
enum ConnectionQuality {
  good,
  medium,
  poor,
}

extension ConnectionTypeExtension on ConnectionType {
  String get displayName {
    switch (this) {
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.mobile:
        return 'Dados Móveis';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.none:
        return 'Sem Conexão';
    }
  }

  bool get isFast {
    return this == ConnectionType.wifi || this == ConnectionType.ethernet;
  }

  bool get shouldSaveData {
    return this == ConnectionType.mobile;
  }
}

extension ConnectionQualityExtension on ConnectionQuality {
  String get displayName {
    switch (this) {
      case ConnectionQuality.good:
        return 'Boa';
      case ConnectionQuality.medium:
        return 'Média';
      case ConnectionQuality.poor:
        return 'Ruim';
    }
  }

  String get icon {
    switch (this) {
      case ConnectionQuality.good:
        return 'signal_wifi_4_bar';
      case ConnectionQuality.medium:
        return 'signal_wifi_2_bar';
      case ConnectionQuality.poor:
        return 'signal_wifi_0_bar';
    }
  }
}
