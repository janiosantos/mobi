import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'earnings_screen.dart';
import 'profile_screen.dart';
import 'ride_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = false;
  bool _isTogglingOnline = false;
  final ApiService _apiService = getIt<ApiService>();

  @override
  void initState() {
    super.initState();
    _loadOnlineStatus();
  }

  Future<void> _loadOnlineStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isOnline = prefs.getBool('driver_is_online') ?? false;
      });
    } catch (e) {
      // Ignore errors loading status
    }
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    if (_isTogglingOnline) return;

    setState(() {
      _isTogglingOnline = true;
    });

    try {
      final response = await _apiService.toggleOnlineStatus();

      if (response.response.statusCode == 200) {
        final data = response.data;
        final bool newStatus = data['data']?['is_online'] ?? value;

        setState(() {
          _isOnline = newStatus;
          _isTogglingOnline = false;
        });

        // Save status locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('driver_is_online', newStatus);

        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            newStatus
                ? 'Você está online! Pronto para receber corridas'
                : 'Você está offline',
          );
        }
      } else {
        throw Exception('Failed to toggle online status');
      }
    } catch (e) {
      setState(() {
        _isTogglingOnline = false;
      });

      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Erro ao alterar status: ${e.toString()}',
        );
      }
    }
  }

  void _navigateToNotifications() {
    CustomSnackbar.showInfo(
      context,
      'Central de notificações em desenvolvimento',
    );
    // TODO: Navigate to notifications screen when implemented
    // Navigator.pushNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MOBI Motorista'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (_isTogglingOnline)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: _isOnline,
                    onChanged: _toggleOnlineStatus,
                    activeColor: AppConstants.successColor,
                  ),
                const SizedBox(width: 8),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOnline ? AppConstants.successColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _navigateToNotifications,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Corridas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Ganhos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const RideHistoryScreen();
      case 2:
        return const EarningsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadOnlineStatus,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_isOnline
                          ? AppConstants.successColor
                          : Colors.grey)
                      .withOpacity(0.1),
                ),
                child: Icon(
                  _isOnline ? Icons.check_circle : Icons.offline_bolt,
                  size: 60,
                  color: _isOnline ? AppConstants.successColor : Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Status Title
              Text(
                _isOnline ? 'Você está online!' : 'Você está offline',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Status Description
              Text(
                _isOnline
                    ? 'Aguardando solicitações de corrida...'
                    : 'Ative o modo online para receber corridas',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Toggle Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTogglingOnline
                      ? null
                      : () => _toggleOnlineStatus(!_isOnline),
                  icon: _isTogglingOnline
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(_isOnline ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    _isTogglingOnline
                        ? 'Aguarde...'
                        : (_isOnline ? 'Ficar Offline' : 'Ficar Online'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOnline
                        ? Colors.orange
                        : AppConstants.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Cards
              if (_isOnline) ...[
                const Divider(height: 48),
                _buildInfoCard(
                  icon: Icons.info_outline,
                  title: 'Dicas para Motoristas Online',
                  items: [
                    'Mantenha seu veículo em bom estado',
                    'Seja educado com os passageiros',
                    'Siga as rotas sugeridas',
                    'Mantenha o app atualizado',
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppConstants.successColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
