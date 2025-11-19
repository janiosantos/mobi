📅 Plano de Sprint 1  - App de Mobilidade Urbana
🎯 Meta do Sprint
Entregar o fluxo completo de "Solicitação, Aceitação e Conclusão de Viagem" para o MVP, garantindo a funcionalidade básica para o Motorista e o Passageiro.
👥 Épicos Prioritários (Foco em Cliente e Motorista)


ID
Épico
Descrição
E01
Cadastro e Perfil
Funcionalidades de login, registro (Passageiro e Motorista) e gestão de dados essenciais.
E02
Localização e Matching
Rastreamento em tempo real (GPS), cálculo de rota e lógica de notificação/associação motorista-passageiro.
E03
Fluxo de Viagem
Experiência de solicitação, aceitação, início e fim da corrida.
E04
Transação e Feedback
Processo de pagamento (mock/simulado para MVP) e sistema de avaliação por estrelas.

🛠️ Backlog do Sprint (Tarefas Detalhadas)
Etapa 1: Infraestrutura e Base da Viagem
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-1: Como Passageiro, quero me cadastrar (nome, e-mail) para começar a usar o app.
Configurar ambiente de desenvolvimento (React Native/Flutter/etc.) e Banco de Dados (Firestore/MongoDB).
8
E01
Dev. Infra
M-1: Como Motorista, quero me cadastrar (documentos, veículo) e ter uma tela de status (Online/Offline).
Criar API REST/Funções Lambda para gerenciamento de usuários e validação de motoristas.
13
E01
Back-end
P-2: Como Passageiro, quero ver minha localização atual no mapa ao abrir o app.
Implementar geolocalização e renderização inicial do mapa (Google Maps API/Mapbox).
5
E02
Front-end
P-3: Como Passageiro, quero inserir endereços de Origem e Destino facilmente.
Implementar busca de endereços (Autocompletar) e marcação de Ponto A e Ponto B.
8
E02
Front-end
M-2: Como Motorista, quero que o app rastreie minha localização em tempo real enquanto estiver Online.
Desenvolver serviço de rastreamento de localização e atualização do DB em background.
13
E02
Back-end

Etapa 2: Fluxo de Transação e Conclusão
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-4: Como Passageiro, quero ver o preço e o tempo estimados antes de confirmar a viagem.
Implementar lógica de cálculo de tarifa (distância + tempo) e integração com API de rotas.
8
E03
Back-end
P-5: Como Passageiro, quero solicitar a corrida e ver o status "Buscando Motorista".
Criar a coleção de 'Viagens' no DB e a lógica de criação da solicitação.
5
E03
Back-end
M-3: Como Motorista, quero receber uma notificação visual e sonora quando uma viagem estiver próxima.
Desenvolver a lógica de "Matching" (distância do motorista ao ponto A) e notificação push.
13
E03
Back-end/Front-end
M-4: Como Motorista, quero aceitar a viagem com um toque.
Implementar o update do status da viagem (de 'Solicitada' para 'Aceita').
3
E03
Front-end/DB
P-6: Como Passageiro, quero ver o ícone do motorista se movendo no mapa em tempo real.
Exibir o ícone do motorista (localização M-2) no mapa do Passageiro e traçar a rota até o Ponto A.
8
E03
Front-end
A-1: Como Usuário (Passageiro/Motorista), quero que a viagem seja finalizada automaticamente.
Implementar o botão de "Finalizar Viagem" (Motorista) e a alteração final do status da corrida.
5
E04
Front-end
A-2: Como Usuário, quero processar o pagamento (Mock/Simulado) e ver o valor cobrado.
Criar interface simples para exibição do valor final e um botão "Pagar" (sem integração real, apenas mock de sucesso).
5
E04
Front-end
P-7: Como Passageiro, quero avaliar o motorista com 1 a 5 estrelas após o fim da corrida.
Criar o formulário de feedback e a lógica de atualização da nota do motorista no DB.
3
E04
Front-end/DB

✅ Definição de Pronto (Definition of Done - DoD)
Uma User Story só será considerada 'Pronta' se todos os seguintes critérios forem atendidos:
O código foi revisado (Code Review) por um colega.
O código foi testado unitariamente e integrado.
A funcionalidade foi testada com sucesso em um dispositivo real (ou simulador).
O Motorista e o Passageiro conseguem executar o fluxo de ponta a ponta: Login -> Solicitar -> Aceitar -> Finalizar -> Avaliar.
A documentação técnica da funcionalidade foi atualizada.

📅 Plano de Sprint 2 ) - App de Mobilidade Urbana

Status do Sprint 1: Concluído (MVP funcional)
🎯 Meta do Sprint
Expandir o serviço introduzindo categorias de veículos, iniciar a integração real de pagamentos e adicionar recursos essenciais de segurança e comunicação para otimizar a experiência do usuário e do motorista.
👥 Épicos Focados (Expansão e Usabilidade)
ID
Épico
Descrição
E05
Categorias de Veículos
Diferenciar o serviço, permitindo ao passageiro escolher o tipo de carro (Ex: Padrão, Comfort).
E06
Pagamento Real e Carteira
Implementação da lógica de gestão de cartões e integração com um gateway de pagamento (Mock/Sandbox).
E07
Comunicação e Segurança
Habilitar o chat entre usuários e a função de compartilhamento de viagem para segurança.
E08
Gestão de Ganhos (Motorista)
Fornecer ao motorista ferramentas para acompanhar seu desempenho financeiro.

🛠️ Backlog do Sprint (Tarefas Detalhadas)
Etapa 1: Categorias e Pagamentos
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-8: Como Passageiro, quero escolher entre diferentes categorias de veículos (Ex: Padrão, Comfort) antes de solicitar.
Criar/Atualizar a estrutura de dados de 'Categorias de Veículo' no DB e no Front-end (ícones e seleção).
8
E05
Front-end/DB
P-9: Como Passageiro, quero ver a estimativa de preço atualizada ao trocar a categoria de veículo.
Refatorar a lógica de cálculo de tarifa (P-4) para incluir o fator multiplicador da categoria selecionada.
8
E05
Back-end
P-10: Como Passageiro, quero poder cadastrar e gerenciar meus Cartões de Crédito/Débito.
Criar o módulo de 'Meios de Pagamento' e a interface para inserção de dados (tokenização mock/sandbox).
13
E06
Front-end
T-3: Configuração do ambiente de Sandbox/Testes para um Gateway de Pagamento (Ex: Stripe, Pagar.me).
Criação de chaves de API, webhooks de teste e setup inicial da biblioteca de integração.
8
E06
Back-end
M-5: Como Motorista, quero poder me habilitar/desabilitar em diferentes categorias de veículos.
Adicionar interface de seleção de categorias na tela de Motorista e validação de documentos/veículos associados.
5
E05
Front-end/DB

Etapa 2: Ganhos, Comunicação e Cancelamento
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-11: Como Passageiro, quero cancelar uma corrida que ainda não foi aceita ou cujo motorista ainda não chegou, sem penalidade.
Implementar a lógica de cancelamento e o update imediato do DB (Viagem -> 'Cancelada').
5
E07
Back-end
M-6: Como Motorista, quero ver um resumo dos meus ganhos diários e semanais no aplicativo.
Desenvolver consultas no DB para agregar dados de viagens concluídas e exibir em uma interface de 'Ganhos'.
13
E08
Back-end/Front-end
A-5: Como Usuário (Motorista/Passageiro), quero ter um chat simples dentro do app após a aceitação da corrida.
Criar a funcionalidade de chat (usando Firestore/Realtime Database) vinculada ao ID da viagem.
13
E07
Back-end/Front-end
A-6: Como Passageiro, quero compartilhar minha viagem em tempo real com um contato externo por um link.
Gerar um link simples com os dados da viagem (origem, destino, motorista) e habilitar o compartilhamento (via navigator.share).
8
E07
Front-end
T-4: Adicionar validações de dados no backend para garantir que apenas motoristas com veículos válidos possam aceitar corridas da respectiva categoria.
Implementar middlewares de segurança na API para matching de viagens.
5
E05
Back-end

✅ Definição de Pronto (Definition of Done - DoD)
Uma User Story só será considerada 'Pronta' se todos os seguintes critérios forem atendidos:
O código foi revisado (Code Review) por um colega.
Testes unitários e de integração foram executados e passaram.
A funcionalidade foi testada com sucesso em um dispositivo real, verificando a experiência em diferentes categorias e o fluxo de pagamento mock/sandbox.
O Motorista e o Passageiro conseguem usar os novos recursos de comunicação (chat) e a gestão de categorias.
A documentação técnica da funcionalidade foi atualizada.

📅 Plano de Sprint 3 ) - App de Mobilidade Urbana

Status do Sprint 2: Concluído (Categorias e Chat implementados)
🎯 Meta do Sprint
Implementar o sistema de Preço Dinâmico (Surge Pricing), introduzir a funcionalidade de Endereços Favoritos e Agendamento de Viagens, e estabelecer o Módulo de Suporte ao Cliente, visando otimizar a receita e a retenção de usuários.
👥 Épicos Focados (Eficiência e Retenção)
ID
Épico
Descrição
E09
Preço Dinâmico (Surge)
Criação e implementação do algoritmo que ajusta o preço baseado na demanda e oferta (geolocalizada).
E10
Agendamento e Favoritos
Permitir que o passageiro salve endereços e agende corridas com antecedência.
E11
Histórico de Viagens e Suporte
Criar a tela de histórico detalhado e o módulo inicial de contato com o suporte.
E12
Otimização de Cobrança
Finalizar a integração de pagamento real (cobrança e repasse de taxas) iniciada no Sprint 2.

🛠️ Backlog do Sprint (Tarefas Detalhadas)
Etapa 1: Preço Dinâmico e Agendamento
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-12: Como Passageiro, quero que o preço da corrida seja ajustado automaticamente em áreas de alta demanda (Preço Dinâmico).
Desenvolver a lógica de "Surge Pricing" no Back-end, monitorando motoristas próximos vs. solicitações ativas por região.
13
E09
Back-end
P-13: Como Passageiro, quero salvar meus endereços frequentes (Casa, Trabalho) para solicitá-los rapidamente.
Criar a tela de "Endereços Favoritos" e a coleção de dados do usuário para armazenar esses locais.
8
E10
Front-end/DB
P-14: Como Passageiro, quero agendar uma corrida para uma data e hora futuras.
Criar a interface de seleção de data/hora e a lógica de agendamento que coloca a corrida na fila de matching no momento certo.
13
E10
Back-end/Front-end
T-5: Implementar o cálculo da taxa de serviço da plataforma e comissão do motorista.
Refatorar a lógica de cobrança (E04) para deduzir a taxa de serviço e calcular o repasse líquido ao motorista.
8
E12
Back-end
M-7: Como Motorista, quero que o app destaque áreas no mapa com alta demanda e potencial de Preço Dinâmico.
Implementar a visualização de "mapa de calor" ou indicadores de alta demanda na tela do motorista.
8
E09
Front-end

Etapa 2: Suporte, Histórico e Finalização de Pagamento
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
A-7: Como Usuário, quero ver meu histórico completo de viagens, incluindo detalhes (mapa, preço, motorista/passageiro).
Criar as telas de "Histórico de Viagens" e buscar/renderizar os dados da coleção de 'Viagens'.
8
E11
Front-end/DB
A-8: Como Usuário, quero poder reportar um problema em uma viagem específica através de um formulário de suporte no app.
Criar a tela de "Suporte/Ajuda" vinculada ao ID da viagem, com campos de texto e categorias de problema.
5
E11
Front-end/DB
T-6: Finalizar a integração de Gateway de Pagamento, movendo da simulação (Mock/Sandbox) para a chamada de cobrança real (Produção).
Implementar a chamada final para o Gateway (Ex: chargeCustomer ou equivalente) para processamento real.
13
E12
Back-end
T-7: Implementar a lógica de repasse financeiro, garantindo que o valor líquido seja creditado na carteira/conta bancária do motorista.
Desenvolver a API de Repasse (Payout) para o motorista, após a dedução da taxa de serviço.
13
E12
Back-end
P-15: Como Passageiro, quero receber confirmação (e-mail ou notificação) do agendamento da minha viagem.
Configurar o serviço de e-mail/notificação push para confirmar agendamentos e alertar sobre o embarque.
5
E10
Back-end

✅ Definição de Pronto (Definition of Done - DoD)
Uma User Story só será considerada 'Pronta' se todos os seguintes critérios forem atendidos:
O código foi revisado (Code Review) por um colega.
Testes unitários, de integração e de carga (para o Surge Pricing) foram executados e passaram.
O sistema de Preço Dinâmico está ativo e funcional em ambiente de testes.
O fluxo de agendamento de viagens e a gestão de favoritos estão estáveis.
A integração de pagamento real (cobrança e repasse) está configurada para produção/stage.
A documentação técnica da funcionalidade foi atualizada.
📅 Plano de Sprint 5 ) - App de Mobilidade Urbana

Status do Sprint 4: Concluído (Promoções, Múltiplas Paradas e Testes Finais prontos)
🎯 Meta do Sprint
Implementar Viagens Compartilhadas (Pooling), introduzir a base para Serviços de Entrega e reforçar a Acessibilidade e Segurança, transformando o app em uma plataforma de serviços completa.
👥 Épicos Focados (Diversificação e Grande Escala)
ID
Épico
Descrição
E17
Viagens Compartilhadas (Pooling)
Lógica completa para agrupar passageiros com rotas similares, recalcular tarifa e otimizar rotas em tempo real.
E18
Serviços de Entrega e Logística (Base)
Estrutura para aceitar e gerenciar pedidos de entrega de itens pequenos (pacotes, documentos).
E19
Acessibilidade e Protocolos de Emergência
Recursos dedicados à acessibilidade (Ex: veículos adaptados) e um botão de emergência integrado e funcional.
E20
Monitoramento e Análise Operacional
Criação de dashboards internos e implementação de Geofencing para a gestão da plataforma.

🛠️ Backlog do Sprint (Tarefas Detalhadas)
Etapa 1: Pooling e Novos Serviços
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-20: Como Passageiro, quero solicitar uma viagem compartilhada (Pooling) para obter um preço mais baixo.
Desenvolver algoritmo de agrupamento que identifique passageiros com rotas sobrepostas e calcule a economia de tarifa.
21
E17
Back-end
T-11: Implementar a API de roteamento dinâmico que recalcula a rota e o preço em tempo real quando um novo passageiro entra ou sai.
Integração de serviço de roteamento para otimizar a ordem das paradas (Pickup/Dropoff).
13
E17
Back-end
P-21: Como Usuário, quero ter uma opção no app para solicitar a entrega de um pequeno item (Entrega Rápida).
Criar a interface de solicitação e a nova categoria de serviço ('Entrega Rápida') com regras de tarifação específicas.
8
E18
Front-end
M-11: Como Motorista, quero poder me habilitar/desabilitar para receber pedidos de Entrega.
Ajustar a tela de status do motorista para permitir a seleção de serviços (Passageiro, Entrega ou Ambos).
5
E18
Front-end/DB
A-9: Como Passageiro, quero poder indicar a necessidade de um veículo adaptado (Ex: cadeirante) para um matching preciso.
Adicionar um filtro de acessibilidade na tela de solicitação e no algoritmo de matching.
8
E19
Front-end/Back-end

Etapa 2: Segurança, Operações e Feedback
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
A-10: Como Usuário, quero ter um Botão de Emergência (Pânico) discreto, que notifique contatos de confiança e a central de monitoramento.
Implementar o botão de pânico e o serviço de notificação com envio da localização em tempo real para a central.
13
E19
Front-end/Back-end
T-12: Criar um Dashboard de Monitoramento Operacional interno para acompanhar métricas-chave (corridas ativas, receita/hora, mapa de calor em tempo real).
Desenvolver a interface web de administração e as APIs de relatórios.
13
E20
Back-end/Admin
M-12: Como Motorista, quero poder avaliar o Passageiro (1 a 5 estrelas) após a conclusão da corrida.
Criar o formulário de feedback do motorista e a lógica de atualização da nota do passageiro no DB.
5
E19
Front-end/DB
T-13: Implementar Geofencing para definir zonas operacionais (Ex: aeroportos, fronteiras) e regras de preço específicas por zona.
Configuração de limites geográficos no Back-end e integração com a lógica de tarifas dinâmicas (E09).
8
E20
Back-end
T-14: Realizar testes de penetração e vulnerabilidade (Ethical Hacking) nos módulos de pagamento e segurança (E12, E19).
Contratação e acompanhamento de auditoria de segurança externa ou interna.
13
E19
QA/Segurança

✅ Definição de Pronto (Definition of Done - DoD)
Uma User Story só será considerada 'Pronta' se todos os seguintes critérios forem atendidos:
O código foi revisado (Code Review) por um colega.
Testes unitários, de integração e testes de carga (para o Pooling) foram executados e passaram.
O algoritmo de Pooling está funcionando e as rotas dinâmicas são calculadas corretamente.
O Botão de Pânico está ativo e os protocolos de emergência foram testados com sucesso.
O Dashboard Operacional está recebendo dados em tempo real.
A documentação técnica da funcionalidade foi atualizada.
📅 Plano de Sprint 6 ) - App de Mobilidade Urbana

Status do Sprint 5: Concluído (Pooling, Entrega Base e Segurança Avançada prontos)
🎯 Meta do Sprint
Implementar o Programa de Fidelidade (Pontos e Níveis), configurar o sistema automatizado de Detecção de Fraudes e concluir o fluxo de Entrega Rápida, preparando a plataforma para o crescimento pós-lançamento.
👥 Épicos Focados (Retenção e Estabilidade)
ID
Épico
Descrição
E21
Fidelização e Recompensas
Desenvolvimento de um programa de pontos ou níveis de fidelidade para passageiros e motoristas.
E22
Segurança Avançada e Anti-Fraude
Criação de regras de detecção automática para atividades suspeitas (ex: auto-pedidos, pagamentos fraudulentos).
E23
Serviços de Entrega (Conclusão)
Implementar o rastreamento do pacote, confirmação de entrega e comunicação específica para o fluxo de logística.
E24
Analytics e Otimização de Funil
Integração completa com ferramentas de análise de dados para monitorar o comportamento do usuário e gargalos.

🛠️ Backlog do Sprint (Tarefas Detalhadas)
Etapa 1: Fidelização e Fraude
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-22: Como Passageiro, quero acumular pontos de fidelidade a cada corrida concluída.
Implementar a lógica de cálculo de pontos no Back-end (baseado no valor ou distância) e atualizar o perfil do usuário.
13
E21
Back-end
P-23: Como Passageiro, quero poder resgatar meus pontos por cupons de desconto ou benefícios.
Criar a "Loja de Recompensas" no app e o mecanismo de validação/consumo de pontos no Back-end.
8
E21
Front-end/Back-end
M-13: Como Motorista, quero alcançar diferentes níveis de status (Ex: Bronze, Prata) baseados no meu desempenho e frequência.
Criar os critérios de nível (E14) e desenvolver a interface de progresso para o motorista.
8
E21
Front-end/DB
T-15: Desenvolver e testar o algoritmo de Detecção de Fraude (Anti-Fraude) para marcar ou bloquear transações suspeitas (Ex: múltiplos cartões no mesmo dia).
Criação de regras de validação no Back-end, focadas em padrões de uso abusivo.
13
E22
Back-end
T-16: Implementar a verificação de identidade por foto para motoristas em situações de alto risco ou após denúncias (requer Machine Learning/API externa).
Integração com um serviço de verificação de identidade ou visão computacional.
13
E22
Back-end/Segurança

Etapa 2: Entrega e Otimização
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
P-24: Como Cliente de Entrega, quero rastrear o pacote no mapa em tempo real e ver o ETA (Tempo Estimado de Chegada).
Adaptar a funcionalidade de rastreamento de passageiros (P-6) para o fluxo de Entrega Rápida.
8
E23
Front-end
M-14: Como Motorista de Entrega, quero um campo de confirmação de entrega (Ex: Assinatura na Tela ou Foto do Item Entregue).
Implementar a tela de confirmação de entrega e o armazenamento da prova no DB.
8
E23
Front-end/DB
A-11: Como Usuário (Passageiro/Motorista/Entrega), quero ter uma opção de Suporte 24/7 (via Chatbot ou FAQ).
Criar o módulo de autoatendimento e o fluxo de escalonamento para agentes de suporte humano.
13
E24
Front-end/Admin
T-17: Concluir a integração com plataformas de Analytics (Ex: Google Analytics, Mixpanel) para monitoramento de funis.
Adicionar todos os eventos de usuário (cliques, abandono, conversão) em todos os fluxos críticos.
8
E24
Back-end/QA
T-18: Realizar o Teste de Carga final no sistema de Geofencing e Preço Dinâmico (E09, E20) com múltiplos cenários simulados de alta demanda.
Executar testes de estresse para garantir a estabilidade do servidor em picos de uso.
13
E24
QA

✅ Definição de Pronto (Definition of Done - DoD)
Uma User Story só será considerada 'Pronta' se todos os seguintes critérios forem atendidos:
O código foi revisado (Code Review) por um colega.
Testes unitários, de integração e testes de carga (T-18) foram executados e passaram.
O sistema de Pontos e Níveis está ativo e os usuários recebem recompensas corretamente.
As regras de Anti-Fraude (T-15) estão operacionais e enviando alertas para o Dashboard Operacional (T-12).
O fluxo de Entrega Rápida, incluindo a confirmação de entrega, está completo.
A documentação técnica da funcionalidade foi atualizada.
📅 Plano de Sprint 7 ) - App de Mobilidade Urbana

Status do Sprint 6: Concluído (Fidelização e Anti-Fraude implementados)
🎯 Meta do Sprint
Finalizar todas as pendências de pré-lançamento, submeter os aplicativos para as lojas (Google Play e App Store), implementar as primeiras campanhas de marketing e configurar o monitoramento de infraestrutura em tempo real.
👥 Épicos Focados (Distribuição e Estratégia de Mercado)
ID
Épico
Descrição
E25
Pré-Lançamento e Submissão
Preparação de todos os materiais visuais, textos e configurações para as lojas de aplicativos.
E26
Marketing e Aquisição Inicial
Implementação de ofertas de boas-vindas e configuração de campanhas de tráfego pago (ponto de partida).
E27
Monitoramento e Alertas Críticos
Configuração de ferramentas para detectar falhas, gargalos de performance e eventos de infraestrutura em tempo real.
E28
Revisão Legal e Compliance
Última auditoria das políticas de uso, privacidade e termos de serviço.

🛠️ Backlog do Sprint (Tarefas Detalhadas)
Etapa 1: Submissão e Marketing
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
T-19: Finalizar todos os assets visuais para as lojas (ícones, screenshots, vídeos promocionais).
Criação e otimização de imagens ASO (App Store Optimization) e revisão de textos.
8
E25
Design/Marketing
T-20: Preparar e submeter o aplicativo para Google Play e App Store (Versão 1.0.0).
Configuração das contas de desenvolvedor, upload dos bundles e preenchimento de formulários de compliance.
13
E25
Dev. Mobile
P-25: Criar uma oferta de primeira viagem gratuita ou com desconto para atrair novos passageiros.
Configurar o cupom de "Boas-Vindas" no sistema de Promoções (E13) e integrá-lo ao funil de cadastro.
8
E26
Marketing/Back-end
M-15: Criar uma Landing Page ou portal de inscrição dedicado para Motoristas (aquisição pré-lançamento).
Desenvolvimento web simples para captação de leads e upload de documentos preliminares.
5
E26
Marketing/Front-end
T-21: Implementar ferramentas de monitoramento de erros e falhas (Ex: Sentry, Firebase Crashlytics) na produção.
Adicionar os SDKs de monitoramento e configurar a pipeline de logs.
8
E27
Dev. Infra

Etapa 2: Alertas, Revisão e Go-Live
User Story
Tarefa Técnica
Estimativa (Pontos/Horas)
Épico
Responsável
T-22: Configurar dashboards de KPI de Lançamento (Novos Usuários, Taxa de Conversão de Corrida, LTV/CAC) no ambiente de Analytics.
Criar visualizações no painel de controle (T-12) para os métricas críticas pós-lançamento.
13
E27
Data/Analytics
T-23: Revisão final e aprovação das Políticas de Privacidade e Termos de Uso pela equipe jurídica.
Upload dos documentos finais e garantia de que estão acessíveis e em conformidade com as regras das lojas.
5
E28
Legal/Admin
T-24: Configurar alertas críticos para falhas de infraestrutura (Ex: falha no serviço de localização, falha na API de pagamento).
Definir thresholds de alerta e canais de notificação (Ex: Slack, e-mail) para a equipe de plantão.
8
E27
Dev. Infra
T-25: Auditoria final de performance e velocidade de carregamento em redes 3G e 4G simuladas.
Teste de estresse do aplicativo em condições reais de baixa conectividade para garantir estabilidade.
8
E25
QA
P-26: Desenvolver um fluxo de Onboarding interativo (tutorial de 3 passos) para a primeira vez do usuário.
Implementação de telas explicativas que destacam os diferenciais do app.
5
E26
Front-end
T-26: Decisão GO/NO-GO e Lançamento Oficial (Switch to Production).
Execução de testes de fumaça pós-lançamento e monitoramento intensivo das primeiras 24 horas.
13
E25
Liderança/QA

✅ Definição de Pronto (Definition of Done - DoD)
Uma User Story só será considerada 'Pronta' se todos os seguintes critérios forem atendidos:
O código foi revisado e testado.
O aplicativo foi submetido e aprovado nas lojas (App Store e Google Play) – ou está em fase de revisão final.
Os sistemas de monitoramento e alertas (E27) estão ativos e reportando dados.
O plano de aquisição inicial (E26) está configurado para o dia do lançamento.
O Teste de Carga e Performance Final (T-25) foi concluído sem falhas críticas.
A documentação técnica e de lançamento (Runbook) foi finalizada.

