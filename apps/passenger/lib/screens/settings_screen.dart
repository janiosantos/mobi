import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _saveSoundSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    setState(() => _soundEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _SectionHeader(title: 'Aparência'),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return SwitchListTile(
                title: const Text('Modo Escuro'),
                subtitle: const Text('Ativar tema escuro'),
                value: state.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(const ToggleTheme());
                },
                secondary: Icon(
                  state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              );
            },
          ),

          const Divider(),

          // Language Section
          _SectionHeader(title: 'Idioma'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma do aplicativo'),
            subtitle: const Text('Português (Brasil)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),

          const Divider(),

          // Accessibility Section
          _SectionHeader(title: 'Acessibilidade'),
          ListTile(
            leading: const Icon(Icons.accessibility_new),
            title: const Text('Tamanho da fonte'),
            subtitle: const Text('Padrão'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              CustomSnackbar.showInfo(
                context,
                'Use as configurações do sistema para ajustar o tamanho do texto',
              );
            },
          ),

          const Divider(),

          // Notifications Section
          _SectionHeader(title: 'Notificações'),
          SwitchListTile(
            title: const Text('Notificações Push'),
            subtitle: const Text('Receber notificações de corridas'),
            value: _notificationsEnabled,
            onChanged: _saveNotificationSetting,
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Som'),
            subtitle: const Text('Reproduzir som para notificações'),
            value: _soundEnabled,
            onChanged: _saveSoundSetting,
            secondary: const Icon(Icons.volume_up),
          ),

          const Divider(),

          // Account Section
          _SectionHeader(title: 'Conta'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRoutes.goToProfile(context),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Métodos de Pagamento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRoutes.goToPaymentMethods(context),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico de Corridas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRoutes.goToRideHistory(context),
          ),

          const Divider(),

          // Support Section
          _SectionHeader(title: 'Suporte'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Central de Ajuda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRoutes.push(context, AppRoutes.helpCenter),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre'),
            subtitle: const Text('Versão 1.0.0'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),

          const Divider(),

          // Logout Section
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentLocale = prefs.getString('locale') ?? 'pt_BR';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Selecionar Idioma'),
        content: StatefulBuilder(
          builder: (statefulContext, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Português (Brasil)'),
                  value: 'pt_BR',
                  groupValue: currentLocale,
                  onChanged: (value) async {
                    if (value != null) {
                      await prefs.setString('locale', value);
                      if (context.mounted) {
                        Navigator.pop(context);
                        CustomSnackbar.showSuccess(
                          context,
                          'Idioma alterado. Reinicie o aplicativo para aplicar.',
                        );
                      }
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('English (US)'),
                  value: 'en_US',
                  groupValue: currentLocale,
                  onChanged: (value) async {
                    if (value != null) {
                      await prefs.setString('locale', value);
                      if (context.mounted) {
                        Navigator.pop(context);
                        CustomSnackbar.showSuccess(
                          context,
                          'Language changed. Restart the app to apply.',
                        );
                      }
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Español'),
                  value: 'es_ES',
                  groupValue: currentLocale,
                  onChanged: (value) async {
                    if (value != null) {
                      await prefs.setString('locale', value);
                      if (context.mounted) {
                        Navigator.pop(context);
                        CustomSnackbar.showSuccess(
                          context,
                          'Idioma cambiado. Reinicie la aplicación para aplicar.',
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MOBI',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_taxi, size: 48),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Plataforma de transporte por aplicativo com funcionalidades avançadas.',
        ),
        const SizedBox(height: 8),
        const Text('© 2024 MOBI. Todos os direitos reservados.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Dispatch logout event to AuthBloc
              context.read<AuthBloc>().add(const LogoutRequested());
              // Navigate to login screen
              AppRoutes.goToLogin(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
