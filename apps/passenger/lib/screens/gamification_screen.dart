import 'package:flutter/material.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gamificação'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Nível'), Tab(text: 'Conquistas'), Tab(text: 'Ranking')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLevelTab(),
            _buildAchievementsTab(),
            _buildLeaderboardTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Nível 5', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('1.250 XP', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                LinearProgressIndicator(value: 0.68),
                SizedBox(height: 8),
                Text('250 / 368 XP para o próximo nível'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AchievementTile(icon: '🚗', title: 'Primeira Corrida', subtitle: 'Complete 1 corrida', unlocked: true),
        _AchievementTile(icon: '💯', title: 'Centenário', subtitle: 'Complete 100 corridas', unlocked: false),
        _AchievementTile(icon: '⭐', title: 'Estrela', subtitle: 'Mantenha 4.8+ de avaliação', unlocked: true),
      ],
    );
  }

  Widget _buildLeaderboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LeaderboardTile(rank: 1, name: 'Carlos Silva', score: 15230),
        _LeaderboardTile(rank: 2, name: 'Ana Costa', score: 12450),
        _LeaderboardTile(rank: 45, name: 'Você', score: 1250, highlighted: true),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String icon, title, subtitle;
  final bool unlocked;
  const _AchievementTile({required this.icon, required this.title, required this.subtitle, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: unlocked ? null : Colors.grey[200],
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 32)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: unlocked ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.lock),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final bool highlighted;
  const _LeaderboardTile({required this.rank, required this.name, required this.score, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlighted ? Colors.blue[50] : null,
      child: ListTile(
        leading: CircleAvatar(child: Text('#$rank')),
        title: Text(name, style: TextStyle(fontWeight: highlighted ? FontWeight.bold : null)),
        trailing: Text('$score XP'),
      ),
    );
  }
}
