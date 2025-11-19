import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            value: true,
            onChanged: (value) {
              // TODO: Implement notification settings
            },
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Som'),
            subtitle: const Text('Reproduzir som para notificações'),
            value: true,
            onChanged: (value) {
              // TODO: Implement sound settings
            },
            secondary: const Icon(Icons.volume_up),
          ),

          const Divider(),

          // Account Section
          _SectionHeader(title: 'Conta'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Métodos de Pagamento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to payment methods screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico de Corridas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to ride history screen
            },
          ),

          const Divider(),

          // Support Section
          _SectionHeader(title: 'Suporte'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Central de Ajuda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to help center
            },
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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Português (Brasil)'),
              value: 'pt_BR',
              groupValue: 'pt_BR',
              onChanged: (value) {
                Navigator.pop(context);
                // TODO: Change locale
              },
            ),
            RadioListTile<String>(
              title: const Text('English (US)'),
              value: 'en_US',
              groupValue: 'pt_BR',
              onChanged: (value) {
                Navigator.pop(context);
                // TODO: Change locale
              },
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es_ES',
              groupValue: 'pt_BR',
              onChanged: (value) {
                Navigator.pop(context);
                // TODO: Change locale
              },
            ),
          ],
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
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement logout
              Navigator.pop(context);
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
