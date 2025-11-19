import 'payment_gateway.dart';
import 'gateways/efi_gateway.dart';
import 'gateways/stone_gateway.dart';
import 'gateways/pagseguro_gateway.dart';
import 'gateways/cielo_gateway.dart';

/// Factory for creating payment gateway instances
class PaymentGatewayFactory {
  static final Map<String, PaymentGateway> _gateways = {};

  /// Get gateway instance by ID
  static PaymentGateway getGateway(String gatewayId) {
    if (_gateways.containsKey(gatewayId)) {
      return _gateways[gatewayId]!;
    }

    final gateway = _createGateway(gatewayId);
    _gateways[gatewayId] = gateway;
    return gateway;
  }

  static PaymentGateway _createGateway(String gatewayId) {
    switch (gatewayId.toLowerCase()) {
      case 'efi':
      case 'gerencianet':
        return EfiGateway();
      case 'stone':
        return StoneGateway();
      case 'pagseguro':
        return PagSeguroGateway();
      case 'cielo':
        return CieloGateway();
      default:
        throw Exception('Unknown payment gateway: $gatewayId');
    }
  }

  /// Get all available gateways
  static List<String> getAvailableGateways() {
    return ['efi', 'stone', 'pagseguro', 'cielo'];
  }

  /// Initialize a gateway with credentials
  static Future<PaymentGateway> initializeGateway({
    required String gatewayId,
    required String apiKey,
    required String apiSecret,
    bool sandbox = false,
  }) async {
    final gateway = getGateway(gatewayId);
    await gateway.initialize(
      apiKey: apiKey,
      apiSecret: apiSecret,
      sandbox: sandbox,
    );
    return gateway;
  }

  /// Clear cached gateways
  static void clearCache() {
    _gateways.clear();
  }
}
