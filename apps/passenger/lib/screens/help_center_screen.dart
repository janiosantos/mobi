import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de Ajuda')),
      body: ListView(
        children: [
          _HelpTile(
            icon: Icons.help_outline,
            title: 'Como solicitar uma corrida?',
            onTap: () => _showHelpDialog(context, 'Solicitar Corrida',
                '1. Na tela inicial, toque em "Para onde?"\n2. Selecione destino no mapa\n3. Confirme a corrida\n4. Aguarde motorista aceitar'),
          ),
          _HelpTile(
            icon: Icons.payment,
            title: 'Como adicionar método de pagamento?',
            onTap: () => _showHelpDialog(context, 'Pagamento',
                'Vá em Configurações > Métodos de Pagamento > Adicionar'),
          ),
          _HelpTile(
            icon: Icons.star,
            title: 'Como avaliar motorista?',
            onTap: () => _showHelpDialog(context, 'Avaliação',
                'Após a corrida, você receberá uma tela de avaliação automaticamente'),
          ),
          _HelpTile(
            icon: Icons.phone,
            title: 'Contatar Suporte',
            subtitle: 'suporte@mobi.com.br',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  static void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _HelpTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
