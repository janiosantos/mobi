import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';
import 'dart:math' as math;

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _badges = [];
  List<Map<String, dynamic>> _leaderboard = [];

  bool _isLoadingProfile = true;
  bool _isLoadingAchievements = true;
  bool _isLoadingLeaderboard = true;

  bool _hasProfileError = false;
  bool _hasAchievementsError = false;
  bool _hasLeaderboardError = false;

  String _errorMessage = '';
  String _leaderboardPeriod = 'all_time'; // all_time, weekly, monthly

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
    _loadAchievements();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _hasProfileError = false;
    });

    try {
      final authService = getIt<AuthService>();
      final token = await authService.getToken();

      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final apiService = getIt<ApiService>();
      final response = await apiService.get('/gamification/profile');

      if (response.statusCode == 200) {
        setState(() {
          _profile = response.data['data'];
          _isLoadingProfile = false;
        });
      } else {
        throw Exception('Erro ao carregar perfil');
      }
    } catch (e) {
      setState(() {
        _hasProfileError = true;
        _errorMessage = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoadingAchievements = true;
      _hasAchievementsError = false;
    });

    try {
      final apiService = getIt<ApiService>();

      // Load both achievements and badges
      final achievementsResponse = await apiService.get('/gamification/achievements');
      final badgesResponse = await apiService.get('/gamification/badges');

      if (achievementsResponse.statusCode == 200 && badgesResponse.statusCode == 200) {
        setState(() {
          _achievements = List<Map<String, dynamic>>.from(achievementsResponse.data['data'] ?? []);
          _badges = List<Map<String, dynamic>>.from(badgesResponse.data['data'] ?? []);
          _isLoadingAchievements = false;
        });
      } else {
        throw Exception('Erro ao carregar conquistas');
      }
    } catch (e) {
      setState(() {
        _hasAchievementsError = true;
        _errorMessage = e.toString();
        _isLoadingAchievements = false;
      });
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoadingLeaderboard = true;
      _hasLeaderboardError = false;
    });

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.get('/gamification/leaderboard?period=$_leaderboardPeriod');

      if (response.statusCode == 200) {
        setState(() {
          _leaderboard = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
          _isLoadingLeaderboard = false;
        });
      } else {
        throw Exception('Erro ao carregar ranking');
      }
    } catch (e) {
      setState(() {
        _hasLeaderboardError = true;
        _errorMessage = e.toString();
        _isLoadingLeaderboard = false;
      });
    }
  }

  double _calculateXPProgress() {
    if (_profile == null) return 0.0;

    final currentXP = _profile!['current_xp'] ?? 0;
    final level = _profile!['level'] ?? 1;
    final xpForNextLevel = _calculateXPForLevel(level + 1);

    return currentXP / xpForNextLevel;
  }

  int _calculateXPForLevel(int level) {
    // Formula from backend: 100 * level^1.5
    return (100 * math.pow(level, 1.5)).round();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gamificação'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.star), text: 'Nível'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Conquistas'),
              Tab(icon: Icon(Icons.leaderboard), text: 'Ranking'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadProfile();
                _loadAchievements();
                _loadLeaderboard();
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
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
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasProfileError) {
      return _buildErrorWidget('Erro ao carregar perfil', _loadProfile);
    }

    if (_profile == null) {
      return const Center(child: Text('Sem dados disponíveis'));
    }

    final level = _profile!['level'] ?? 1;
    final totalXP = _profile!['total_xp'] ?? 0;
    final currentXP = _profile!['current_xp'] ?? 0;
    final xpForNext = _calculateXPForLevel(level + 1);
    final progress = _calculateXPProgress();
    final currentStreak = _profile!['current_streak'] ?? 0;
    final longestStreak = _profile!['longest_streak'] ?? 0;
    final totalRides = _profile!['stats']?['total_rides'] ?? 0;
    final averageRating = _profile!['stats']?['average_rating'] ?? 0.0;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Level Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.stars,
                    size: 64,
                    color: _getLevelColor(level),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nível $level',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalXP.toStringAsFixed(0)} XP Total',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(level)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$currentXP / $xpForNext XP para o próximo nível',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: 'Sequência Atual',
                  value: '$currentStreak dias',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.military_tech,
                  label: 'Maior Sequência',
                  value: '$longestStreak dias',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.directions_car,
                  label: 'Total de Corridas',
                  value: '$totalRides',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  label: 'Avaliação Média',
                  value: averageRating.toStringAsFixed(1),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Badges Section
          if (_badges.isNotEmpty) ...[
            const Text(
              'Emblemas Conquistados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _badges.length,
              itemBuilder: (context, index) {
                final badge = _badges[index];
                return _buildBadge(badge);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    if (_isLoadingAchievements) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasAchievementsError) {
      return _buildErrorWidget('Erro ao carregar conquistas', _loadAchievements);
    }

    if (_achievements.isEmpty) {
      return _buildEmptyWidget(
        icon: Icons.emoji_events,
        title: 'Nenhuma conquista ainda',
        subtitle: 'Complete corridas para desbloquear conquistas',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final achievement = _achievements[index];
          final name = achievement['name'] ?? 'Conquista';
          final description = achievement['description'] ?? '';
          final currentProgress = achievement['current_progress'] ?? 0;
          final targetValue = achievement['target_value'] ?? 1;
          final completedAt = achievement['completed_at'];
          final xpReward = achievement['xp_reward'] ?? 0;
          final isCompleted = completedAt != null;
          final progress = targetValue > 0 ? currentProgress / targetValue : 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isCompleted ? 3 : 1,
            color: isCompleted ? null : Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.emoji_events : Icons.lock_outline,
                        size: 40,
                        color: isCompleted ? Colors.amber : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? null : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+$xpReward XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!isCompleted) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currentProgress / $targetValue',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Column(
      children: [
        // Period Selector
        Container(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'weekly', label: Text('Semanal'), icon: Icon(Icons.calendar_today)),
              ButtonSegment(value: 'monthly', label: Text('Mensal'), icon: Icon(Icons.calendar_month)),
              ButtonSegment(value: 'all_time', label: Text('Geral'), icon: Icon(Icons.all_inclusive)),
            ],
            selected: {_leaderboardPeriod},
            onSelectionChanged: (Set<String> selected) {
              setState(() {
                _leaderboardPeriod = selected.first;
              });
              _loadLeaderboard();
            },
          ),
        ),

        Expanded(
          child: _isLoadingLeaderboard
              ? const Center(child: CircularProgressIndicator())
              : _hasLeaderboardError
                  ? _buildErrorWidget('Erro ao carregar ranking', _loadLeaderboard)
                  : _leaderboard.isEmpty
                      ? _buildEmptyWidget(
                          icon: Icons.leaderboard,
                          title: 'Ranking vazio',
                          subtitle: 'Complete corridas para aparecer no ranking',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadLeaderboard,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _leaderboard.length,
                            itemBuilder: (context, index) {
                              final entry = _leaderboard[index];
                              final rank = entry['rank'] ?? (index + 1);
                              final userName = entry['user']?['name'] ?? 'Usuário';
                              final score = entry['score'] ?? 0;
                              final isCurrentUser = entry['is_current_user'] == true;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: isCurrentUser ? 4 : 1,
                                color: isCurrentUser ? Colors.blue[50] : null,
                                child: ListTile(
                                  leading: _buildRankBadge(rank),
                                  title: Text(
                                    isCurrentUser ? 'Você' : userName,
                                    style: TextStyle(
                                      fontWeight: isCurrentUser ? FontWeight.bold : null,
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${score.toStringAsFixed(0)} XP',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Map<String, dynamic> badge) {
    final icon = badge['icon'] ?? '🏆';
    final name = badge['name'] ?? '';
    final rarity = badge['rarity'] ?? 'common';

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(badge['description'] ?? ''),
                const SizedBox(height: 8),
                Chip(
                  label: Text(rarity.toUpperCase()),
                  backgroundColor: _getRarityColor(rarity),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    IconData? icon;

    if (rank == 1) {
      color = Colors.amber;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      color = Colors.grey[400]!;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      color = Colors.brown[300]!;
      icon = Icons.emoji_events;
    } else {
      color = Colors.blue;
    }

    return CircleAvatar(
      backgroundColor: color,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 20)
          : Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 50) return Colors.purple;
    if (level >= 30) return Colors.amber;
    if (level >= 15) return Colors.blue;
    return Colors.green;
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
