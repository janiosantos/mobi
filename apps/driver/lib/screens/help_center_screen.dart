import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Ajuda'),
      ),
      body: ListView(
        children: [
          _HelpTile(
            icon: Icons.help_outline,
            title: 'Como aceitar corridas?',
            onTap: () => _showHelpDialog(
              context,
              'Aceitar Corridas',
              '1. Fique online tocando no botão "Ficar Online"\n'
                  '2. Aguarde solicitações de corrida\n'
                  '3. Toque em "Aceitar" quando receber uma solicitação\n'
                  '4. Siga as instruções no mapa até o passageiro',
            ),
          ),
          _HelpTile(
            icon: Icons.help_outline,
            title: 'Como concluir uma corrida?',
            onTap: () => _showHelpDialog(
              context,
              'Concluir Corrida',
              '1. Toque em "Cheguei" ao chegar no local de embarque\n'
                  '2. Toque em "Iniciar Corrida" quando o passageiro entrar\n'
                  '3. Siga a rota até o destino\n'
                  '4. Toque em "Concluir" ao chegar no destino\n'
                  '5. Aguarde o pagamento ser processado',
            ),
          ),
          _HelpTile(
            icon: Icons.attach_money,
            title: 'Como funcionam os ganhos?',
            onTap: () => _showHelpDialog(
              context,
              'Ganhos',
              'Seus ganhos são calculados com base em:\n'
                  '- Tarifa base\n'
                  '- Distância percorrida\n'
                  '- Tempo da corrida\n'
                  '- Gorjetas dos passageiros\n\n'
                  'A taxa da plataforma é descontada automaticamente.',
            ),
          ),
          _HelpTile(
            icon: Icons.account_balance,
            title: 'Como sacar meus ganhos?',
            onTap: () => _showHelpDialog(
              context,
              'Saque',
              'Para sacar seus ganhos:\n'
                  '1. Vá em "Ganhos"\n'
                  '2. Toque em "Solicitar Saque"\n'
                  '3. Escolha sua conta bancária\n'
                  '4. Confirme o valor\n\n'
                  'O dinheiro será transferido em até 2 dias úteis.',
            ),
          ),
          _HelpTile(
            icon: Icons.car_rental,
            title: 'Como adicionar um veículo?',
            onTap: () => _showHelpDialog(
              context,
              'Adicionar Veículo',
              '1. Vá em Configurações > Veículos\n'
                  '2. Toque em "Adicionar Veículo"\n'
                  '3. Preencha os dados do veículo\n'
                  '4. Faça upload dos documentos\n'
                  '5. Aguarde aprovação',
            ),
          ),
          const Divider(),
          _HelpTile(
            icon: Icons.phone,
            title: 'Contatar Suporte',
            subtitle: 'suporte-motorista@mobi.com.br',
            onTap: () {
              CustomSnackbar.showInfo(
                context,
                'Entre em contato pelo email ou telefone (11) 1234-5678',
              );
            },
          ),
          _HelpTile(
            icon: Icons.chat,
            title: 'Chat ao vivo',
            subtitle: 'Disponível 24/7',
            onTap: () {
              CustomSnackbar.showInfo(
                context,
                'Chat ao vivo em breve!',
              );
            },
          ),
        ],
      ),
    );
  }

  static void _showHelpDialog(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

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
