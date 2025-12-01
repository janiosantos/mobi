import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Map<String, List<Map<String, String>>> _helpCategories = {
    'Corridas': [
      {
        'question': 'Como solicitar uma corrida?',
        'answer':
            '1. Na tela inicial, toque em "Para onde?"\n2. Digite o destino ou selecione no mapa\n3. Escolha a categoria de veículo\n4. Confirme o endereço de partida\n5. Toque em "Solicitar Corrida"\n6. Aguarde o motorista aceitar (geralmente em poucos segundos)'
      },
      {
        'question': 'Como cancelar uma corrida?',
        'answer':
            'Você pode cancelar a corrida antes do motorista chegar:\n1. Abra a tela da corrida\n2. Toque em "Cancelar Corrida"\n3. Confirme o cancelamento\n\nAtenção: Cancelamentos após o motorista ter chegado podem gerar taxa de cancelamento.'
      },
      {
        'question': 'Como agendar uma corrida?',
        'answer':
            '1. Na tela inicial, toque em "Agendar Corrida"\n2. Escolha data e hora (até 30 dias de antecedência)\n3. Defina origem e destino\n4. Confirme o agendamento\n\nVocê receberá uma notificação 30 minutos antes e o motorista será buscado automaticamente no horário agendado.'
      },
      {
        'question': 'Como adicionar paradas intermediárias?',
        'answer':
            'Durante a solicitação da corrida:\n1. Toque em "Adicionar Parada"\n2. Digite o endereço da parada\n3. Defina o tempo de espera desejado\n4. Você pode adicionar até 3 paradas\n\nO preço será recalculado automaticamente considerando as paradas.'
      },
      {
        'question': 'Como compartilhar minha viagem?',
        'answer':
            'Para maior segurança:\n1. Durante a corrida, toque em "Compartilhar Viagem"\n2. Escolha o contato ou gere um link público\n3. O destinatário poderá acompanhar sua viagem em tempo real\n\nO link expira automaticamente quando a corrida terminar.'
      },
    ],
    'Pagamentos': [
      {
        'question': 'Como adicionar método de pagamento?',
        'answer':
            '1. Vá em Configurações > Métodos de Pagamento\n2. Toque em "Adicionar Método"\n3. Escolha entre PIX, Cartão de Crédito/Débito, ou Dinheiro\n4. Para cartões, insira os dados solicitados\n5. Confirme para salvar\n\nVocê pode ter múltiplos métodos cadastrados e escolher qual usar em cada corrida.'
      },
      {
        'question': 'Como funciona o pagamento com PIX?',
        'answer':
            'Com PIX é rápido e seguro:\n1. Ao final da corrida, escolha "Pagar com PIX"\n2. Um QR Code será gerado\n3. Abra seu app bancário e escaneie o código\n4. Confirme o pagamento\n\nO pagamento é processado instantaneamente e você receberá confirmação no app.'
      },
      {
        'question': 'Como usar cupons de desconto?',
        'answer':
            'Para aplicar um cupom:\n1. Na tela de confirmação da corrida, toque em "Adicionar Cupom"\n2. Digite o código do cupom\n3. Toque em "Aplicar"\n4. O desconto será aplicado no valor final\n\nCupons têm condições de uso (valor mínimo, validade, etc) que são verificadas automaticamente.'
      },
      {
        'question': 'Como funciona a carteira digital?',
        'answer':
            'A carteira é seu saldo no app:\n• Adicione créditos antecipadamente\n• Use para pagar corridas instantaneamente\n• Receba bônus por recarga\n• Sem taxas adicionais\n\nPara adicionar saldo: Configurações > Carteira > Adicionar Créditos'
      },
      {
        'question': 'Como dividir o pagamento?',
        'answer':
            'Para dividir a corrida com amigos:\n1. Ao final da corrida, toque em "Dividir Pagamento"\n2. Convide os participantes (até 4 pessoas)\n3. Cada um receberá uma solicitação de pagamento\n4. Pagamento aprovado quando todos confirmarem\n\nO valor é dividido igualmente entre todos os participantes.'
      },
    ],
    'Segurança': [
      {
        'question': 'Como usar o botão de emergência (SOS)?',
        'answer':
            'Em caso de emergência:\n1. Toque no botão vermelho "SOS" na tela da corrida\n2. Seus contatos de emergência serão notificados automaticamente\n3. Sua localização será compartilhada em tempo real\n4. O suporte será acionado imediatamente\n\nUse apenas em situações reais de emergência.'
      },
      {
        'question': 'Como adicionar contatos de emergência?',
        'answer':
            '1. Vá em Configurações > Segurança > Contatos de Emergência\n2. Toque em "Adicionar Contato"\n3. Escolha um contato da sua agenda ou digite manualmente\n4. Defina se é o contato principal\n5. Salve\n\nRecomendamos adicionar pelo menos 2 contatos de confiança.'
      },
      {
        'question': 'Como avaliar a segurança do motorista?',
        'answer':
            'Todos os motoristas passam por verificação:\n• Checagem de antecedentes criminais\n• Validação de documentos (CNH, veículo)\n• Análise de histórico de direção\n• Avaliações de outros passageiros\n\nVocê pode ver a avaliação média do motorista antes de aceitar a corrida.'
      },
      {
        'question': 'Como reportar um problema de segurança?',
        'answer':
            'Se algo não estiver certo:\n1. Durante a corrida: use o botão SOS\n2. Após a corrida: vá em Histórico > Selecione a corrida > Reportar Problema\n3. Escolha a categoria do problema\n4. Descreva o ocorrido\n5. Envie\n\nTodos os reports são analisados pela equipe de segurança em até 24h.'
      },
    ],
    'Conta': [
      {
        'question': 'Como atualizar meu perfil?',
        'answer':
            '1. Vá em Configurações > Meu Perfil\n2. Toque no campo que deseja editar\n3. Faça as alterações necessárias\n4. Toque em "Salvar"\n\nVocê pode alterar: nome, foto, telefone, e-mail, e data de nascimento.'
      },
      {
        'question': 'Como alterar minha senha?',
        'answer':
            '1. Vá em Configurações > Segurança > Alterar Senha\n2. Digite sua senha atual\n3. Digite a nova senha (mínimo 8 caracteres)\n4. Confirme a nova senha\n5. Toque em "Salvar"\n\nUse uma senha forte com letras, números e caracteres especiais.'
      },
      {
        'question': 'Como salvar locais favoritos?',
        'answer':
            '1. Vá em Configurações > Locais Salvos\n2. Toque em "Adicionar Local"\n3. Escolha o tipo (Casa, Trabalho, ou Favorito)\n4. Digite ou selecione o endereço\n5. Salve\n\nLocais salvos aparecem como sugestões rápidas ao solicitar corridas.'
      },
      {
        'question': 'Como ver meu histórico de corridas?',
        'answer':
            '1. Na tela inicial, toque em "Histórico"\n2. Você verá todas as suas corridas anteriores\n3. Toque em uma corrida para ver detalhes completos\n\nDetalhes incluem: rota, tempo, valor pago, motorista, e avaliação.'
      },
      {
        'question': 'Como excluir minha conta?',
        'answer':
            'Se deseja excluir sua conta:\n1. Vá em Configurações > Conta > Excluir Conta\n2. Leia os avisos sobre a exclusão\n3. Confirme sua senha\n4. Toque em "Excluir Permanentemente"\n\nAtenção: Esta ação é irreversível e todos os seus dados serão apagados em 30 dias.'
      },
    ],
    'Gamificação': [
      {
        'question': 'Como funciona o sistema de níveis?',
        'answer':
            'Você ganha XP (experiência) completando corridas:\n• Cada corrida concluída = XP\n• Bônus por avaliações 5 estrelas\n• Bônus por sequências de dias\n• Bônus por conquistas desbloqueadas\n\nQuanto mais XP, maior seu nível e melhores as recompensas!'
      },
      {
        'question': 'Como desbloquear conquistas?',
        'answer':
            'Conquistas são desbloqueadas automaticamente:\n• Complete objetivos específicos\n• Mantenha bom comportamento\n• Use o app frequentemente\n• Alcance marcos importantes\n\nVocê pode ver seu progresso em Gamificação > Conquistas'
      },
      {
        'question': 'Como funciona o ranking?',
        'answer':
            'O ranking compara você com outros usuários:\n• Rankings: Semanal, Mensal, e Geral\n• Critérios: XP total, corridas, avaliações\n• Top players ganham recompensas especiais\n• Seu ranking aparece destacado\n\nCompita de forma saudável e divirta-se!'
      },
      {
        'question': 'Qual a vantagem de subir de nível?',
        'answer':
            'Níveis maiores trazem benefícios:\n• Descontos exclusivos\n• Prioridade no atendimento\n• Cupons especiais\n• Badges e conquistas únicas\n• Reconhecimento na comunidade\n\nContinue usando o app para evoluir!'
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, List<Map<String, String>>>> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _helpCategories.entries.toList();
    }

    final filtered = <String, List<Map<String, String>>>{};
    for (var category in _helpCategories.entries) {
      final filteredQuestions = category.value.where((item) {
        return item['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      if (filteredQuestions.isNotEmpty) {
        filtered[category.key] = filteredQuestions;
      }
    }

    return filtered.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Ajuda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: _showContactSupport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar na Central de Ajuda...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: filteredCategories.isEmpty
                ? _buildEmptySearch()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return _CategorySection(
                        title: category.key,
                        items: category.value,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum resultado encontrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar com outras palavras',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showContactSupport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Contatar Suporte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _ContactOption(
              icon: Icons.email,
              title: 'E-mail',
              subtitle: 'suporte@mobi.com.br',
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.phone,
              title: 'Telefone',
              subtitle: '0800 123 4567',
              onTap: () => _launchPhone(),
            ),
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.chat,
              title: 'WhatsApp',
              subtitle: '(11) 98765-4321',
              onTap: () => _launchWhatsApp(),
            ),
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.help_outline,
              title: 'FAQ Online',
              subtitle: 'www.mobi.com.br/faq',
              onTap: () => _launchWebsite(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'suporte@mobi.com.br',
      query: 'subject=Suporte MOBI App',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          CustomSnackbar.showInfo(context, 'E-mail: suporte@mobi.com.br');
        }
      }
    } catch (e) {
      if (mounted) {
        await Clipboard.setData(const ClipboardData(text: 'suporte@mobi.com.br'));
        CustomSnackbar.showSuccess(context, 'E-mail copiado para a área de transferência');
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '08001234567');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          CustomSnackbar.showInfo(context, 'Telefone: 0800 123 4567');
        }
      }
    } catch (e) {
      if (mounted) {
        await Clipboard.setData(const ClipboardData(text: '0800 123 4567'));
        CustomSnackbar.showSuccess(context, 'Telefone copiado para a área de transferência');
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/5511987654321?text=Olá, preciso de ajuda com o app MOBI');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          CustomSnackbar.showInfo(context, 'WhatsApp: (11) 98765-4321');
        }
      }
    } catch (e) {
      if (mounted) {
        await Clipboard.setData(const ClipboardData(text: '(11) 98765-4321'));
        CustomSnackbar.showSuccess(context, 'Número copiado para a área de transferência');
      }
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.mobi.com.br/faq');

    try {
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          CustomSnackbar.showInfo(context, 'Visite: www.mobi.com.br/faq');
        }
      }
    } catch (e) {
      if (mounted) {
        await Clipboard.setData(const ClipboardData(text: 'www.mobi.com.br/faq'));
        CustomSnackbar.showSuccess(context, 'Link copiado para a área de transferência');
      }
    }
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const _CategorySection({
    required this.title,
    required this.items,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Corridas':
        return Icons.directions_car;
      case 'Pagamentos':
        return Icons.payment;
      case 'Segurança':
        return Icons.shield;
      case 'Conta':
        return Icons.person;
      case 'Gamificação':
        return Icons.emoji_events;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Corridas':
        return Colors.blue;
      case 'Pagamentos':
        return Colors.green;
      case 'Segurança':
        return Colors.red;
      case 'Conta':
        return Colors.orange;
      case 'Gamificação':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getCategoryColor(title).withOpacity(0.2),
                child: Icon(
                  _getCategoryIcon(title),
                  color: _getCategoryColor(title),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _FAQItem(
              question: item['question']!,
              answer: item['answer']!,
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: onTap,
      ),
    );
  }
}
