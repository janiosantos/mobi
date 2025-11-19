import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final paymentRepository = getIt<PaymentRepository>();
      final result = await paymentRepository.getPaymentMethods();

      if (result['success'] == true) {
        final List<dynamic> methodsData = result['data']['data'] ?? [];

        setState(() {
          _paymentMethods = methodsData.map((json) => json as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? 'Erro ao carregar métodos de pagamento');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePaymentMethod(int methodId) async {
    try {
      final paymentRepository = getIt<PaymentRepository>();
      final result = await paymentRepository.deletePaymentMethod(methodId);

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Método de pagamento removido'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        _loadPaymentMethods();
      } else {
        throw Exception(result['message'] ?? 'Erro ao remover método');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(int methodId, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover método de pagamento'),
        content: Text('Deseja remover $label?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deletePaymentMethod(methodId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formas de Pagamento'),
      ),
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: 'Adicionar Método de Pagamento',
            icon: Icons.add,
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddPaymentMethodScreen(),
                ),
              );

              if (result == true) {
                _loadPaymentMethods();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentMethods,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cash - Always available
        _buildPaymentMethodCard(
          icon: Icons.money,
          label: 'Dinheiro',
          subtitle: 'Pague em dinheiro ao motorista',
          color: AppConstants.successColor,
          isDefault: _paymentMethods.isEmpty,
          canDelete: false,
        ),
        const SizedBox(height: 8),
        // PIX - Always available
        _buildPaymentMethodCard(
          icon: Icons.qr_code,
          label: 'PIX',
          subtitle: 'Pagamento via PIX no final da corrida',
          color: AppConstants.infoColor,
          isDefault: false,
          canDelete: false,
        ),
        const SizedBox(height: 16),
        if (_paymentMethods.isNotEmpty) ...[
          const Text(
            'Meus Cartões',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._paymentMethods.map((method) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPaymentMethodCard(
                icon: Icons.credit_card,
                label: '•••• ${method['last4'] ?? '****'}',
                subtitle: '${_getCardBrand(method['card_brand'])} - ${method['cardholder_name'] ?? 'N/A'}',
                color: AppConstants.primaryColor,
                isDefault: method['is_default'] == true,
                canDelete: true,
                onDelete: () => _confirmDelete(method['id'], '•••• ${method['last4']}'),
              ),
            );
          }),
        ] else ...[
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.credit_card_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum cartão cadastrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adicione um cartão para pagamento rápido',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isDefault,
    required bool canDelete,
    VoidCallback? onDelete,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppConstants.successColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Padrão',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: canDelete
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }

  String _getCardBrand(String? brand) {
    if (brand == null) return 'Cartão';

    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'elo':
        return 'Elo';
      case 'amex':
        return 'American Express';
      default:
        return brand;
    }
  }
}
