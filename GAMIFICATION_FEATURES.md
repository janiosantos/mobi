# 🎮 Sistema de Gamificação - MOBI Platform

Sistema completo de gamificação implementado para aumentar engajamento e retenção de usuários.

## 📊 Visão Geral

O sistema de gamificação do MOBI inclui:
- ⭐ **Levels & XP** - Sistema de níveis e experiência
- 🏆 **Badges** - Emblemas conquistáveis (4 raridades)
- 🎯 **Achievements** - Conquistas e desafios
- 📈 **Leaderboards** - Rankings competitivos
- 🔥 **Streaks** - Sequências de dias consecutivos
- 💰 **Rewards** - Recompensas em XP e dinheiro

---

## 🎯 Features Implementadas

### 1. Sistema de Levels (XP)

**Fórmula de XP:** `100 * level^1.5`

```
Level 1: 0 XP
Level 2: 100 XP
Level 3: 346 XP
Level 4: 800 XP
Level 5: 1,581 XP
Level 10: 10,000 XP
```

**Fontes de XP:**
- Completar corridas
- Conquistar achievements
- Ganhar badges
- Manter streaks

**Auto Level-Up:**
- Detecção automática quando XP suficiente
- Notificação em tempo real (WebSocket)
- Recompensas por nível

### 2. Badges (Emblemas)

**15 Badges Disponíveis:**

#### Rides (Corridas)
| Badge | Critério | Raridade | XP |
|-------|----------|----------|-----|
| 🚗 Primeiro Passo | 1 corrida | Common | 10 |
| 🗺️ Explorador | 50 corridas | Rare | 50 |
| ⭐ Veterano | 500 corridas | Epic | 200 |
| 👑 Lenda | 1000 corridas | Legendary | 500 |

#### Earnings (Ganhos)
| Badge | Critério | Raridade | XP |
|-------|----------|----------|-----|
| 💵 Primeiro Ganho | R$ 100 | Common | 10 |
| 💰 Empreendedor | R$ 10.000 | Epic | 150 |
| 🏆 Magnata | R$ 100.000 | Legendary | 500 |

#### Ratings (Avaliações)
| Badge | Critério | Raridade | XP |
|-------|----------|----------|-----|
| ⭐ Bem Avaliado | 4.5★ (20+ reviews) | Rare | 50 |
| 🌟 Cinco Estrelas | 4.8★ (50+ reviews) | Epic | 200 |
| 💎 Perfeição | 4.9★ (100+ reviews) | Legendary | 500 |

#### Streak (Sequências)
| Badge | Critério | Raridade | XP |
|-------|----------|----------|-----|
| 🔥 Dedicado | 7 dias consecutivos | Rare | 50 |
| ⚡ Incansável | 30 dias consecutivos | Epic | 200 |
| 🏃 Maratonista | 90 dias consecutivos | Legendary | 500 |

#### Special (Especiais)
| Badge | Critério | Raridade | XP |
|-------|----------|----------|-----|
| 🌙 Noturno | 50 corridas 22h-6h | Rare | 50 |
| 🎉 Fim de Semana | 100 corridas sábado/domingo | Rare | 50 |
| 🤝 Ajudante | Ajudar 10 usuários | Epic | 100 |

### 3. Achievements (Conquistas)

**9 Achievements Configurados:**

#### Progressive (Progressivos)
- **10 Corridas**: 50 XP
- **100 Corridas**: 200 XP + R$ 50
- **1000 Corridas**: 1000 XP + R$ 500

#### Milestone (Marcos)
- **Primeiro Mil**: R$ 1.000 ganhos - 100 XP
- **Dez Mil**: R$ 10.000 ganhos - 500 XP + R$ 100

#### Challenge (Desafios - Repetíveis)
- **Maratona Diária**: 20 corridas/dia - 200 XP + R$ 50
- **Semana Intensa**: 100 corridas/semana - 500 XP + R$ 200

#### Secret (Secretos)
- **Explorador Secreto**: Descobrir rotas secretas - 300 XP + R$ 100
- **Colecionador**: Todos badges comuns - 500 XP + R$ 250

### 4. Leaderboards (Rankings)

**Tipos de Rankings:**
- Weekly (Semanal)
- Monthly (Mensal)
- All-Time (Histórico)

**Categorias:**
- 🚗 **Rides**: Maior número de corridas
- 💰 **Earnings**: Maior faturamento
- ⭐ **Ratings**: Melhor avaliação
- 📊 **XP**: Maior experiência

**Features:**
- Top 50 posições
- Posição do usuário atual
- Score por categoria
- Atualização em tempo real

### 5. Streaks (Sequências)

**Sistema de Dias Consecutivos:**

```dart
Dia 1: ✅ Corrida realizada - Streak = 1
Dia 2: ✅ Corrida realizada - Streak = 2
Dia 3: ❌ Sem corridas - Streak = 0 (quebrado)
Dia 4: ✅ Corrida realizada - Streak = 1 (reinicia)
```

**Tracking:**
- Current Streak: Sequência atual
- Longest Streak: Maior sequência já alcançada
- Last Ride Date: Data da última corrida

**Badges por Streak:**
- 🔥 7 dias: Dedicado (50 XP)
- ⚡ 30 dias: Incansável (200 XP)
- 🏃 90 dias: Maratonista (500 XP)

### 6. Rewards (Recompensas)

**Tipos de Recompensas:**

1. **XP (Experiência)**
   - 10-1000 XP por achievement
   - XP acumulativo para level-up
   - XP por badges conquistados

2. **Money (Dinheiro Real)**
   - R$ 50-500 por achievement
   - Creditado na carteira do usuário
   - Pode ser usado em corridas

**Exemplos:**
```
Achievement: "100 Corridas"
→ 200 XP + R$ 50 reais

Badge: "Veterano" (500 corridas)
→ 200 XP

Level Up: Nível 5 → Nível 6
→ Notificação + Celebração na UI
```

---

## 🔌 API Endpoints

### Base URL: `/api/v1/gamification`

#### 1. Get User Profile
```http
GET /profile
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "level": 5,
      "current_xp": 250,
      "total_xp": 1831,
      "xp_to_next_level": 581,
      "progress_percentage": 43.03
    },
    "rides": {
      "total": 150,
      "completed": 145,
      "cancelled": 5,
      "completion_rate": 96.67
    },
    "earnings": {
      "total": 5432.50
    },
    "ratings": {
      "average": 4.8,
      "total": 120
    },
    "streak": {
      "current": 12,
      "longest": 25,
      "last_ride_date": "2024-11-19"
    },
    "badges": {
      "total": 5,
      "by_rarity": {
        "common": 1,
        "rare": 2,
        "epic": 2
      },
      "earned": [...]
    },
    "achievements": {
      "completed": [...],
      "in_progress": [...]
    }
  }
}
```

#### 2. Get All Badges
```http
GET /badges
```

**Response:** Badges agrupados por categoria

#### 3. Get Achievements
```http
GET /achievements
```

**Response:** Achievements com progresso atual

#### 4. Check Achievement Progress
```http
POST /achievements/check
```

**Response:** Achievements atualizados e recém-completados

#### 5. Get Leaderboard
```http
GET /leaderboard?type=weekly&category=rides&limit=50
```

**Params:**
- `type`: weekly | monthly | all_time
- `category`: rides | earnings | ratings | xp
- `limit`: 1-100 (default: 50)

#### 6. Get Global Stats
```http
GET /stats
```

**Response:** Estatísticas globais do sistema

---

## 📡 Real-Time Events

### WebSocket Channels

**Channel:** `private-user.{user_id}`

#### Event: `achievement.completed`
```json
{
  "achievement": {
    "id": 1,
    "name": "100 Corridas",
    "description": "Complete 100 corridas",
    "icon": "🚙",
    "xp_reward": 200,
    "money_reward": 50.00
  },
  "timestamp": "2024-11-19T12:00:00Z"
}
```

#### Event: `user.leveled-up`
```json
{
  "user_id": 123,
  "new_level": 6,
  "stats": {
    "total_xp": 2412,
    "current_xp": 0,
    "xp_to_next_level": 871
  },
  "timestamp": "2024-11-19T12:00:00Z"
}
```

---

## 🗄️ Database Schema

### Tables

1. **badges** - Badges disponíveis
2. **achievements** - Achievements configuradas
3. **user_stats** - Estatísticas do usuário
4. **user_achievements** - Progresso de achievements
5. **user_badges** - Badges conquistados
6. **leaderboards** - Rankings

### Relationships

```
User
  ├─ hasOne: UserStats
  ├─ hasMany: UserAchievement
  └─ belongsToMany: Badge

Badge
  ├─ belongsToMany: User
  └─ hasMany: Achievement

Achievement
  ├─ belongsTo: Badge
  └─ hasMany: UserAchievement
```

---

## 🎨 Flutter Models

### Badge Model
```dart
class Badge {
  final int id;
  final String name;
  final String icon;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final int points;
  final bool? isEarned;
}
```

### Achievement Model
```dart
class Achievement {
  final int id;
  final String name;
  final AchievementType type;
  final int targetValue;
  final int xpReward;
  final double moneyReward;
  final AchievementProgress? progress;
}
```

### UserStats Model
```dart
class UserStats {
  final int level;
  final int currentXp;
  final int totalXp;
  final RideStats? rides;
  final EarningsStats? earnings;
  final RatingStats? ratings;
  final StreakStats? streak;
}
```

---

## 📈 Métricas Trackadas

### Automatic Tracking

**Rides:**
- Total de corridas
- Corridas completadas
- Corridas canceladas
- Taxa de conclusão
- Corridas noturnas (22h-6h)
- Corridas de fim de semana

**Earnings:**
- Total ganho
- Ganhos mensais
- Média de ganhos por corrida

**Ratings:**
- Avaliação média
- Total de avaliações
- Distribuição de estrelas

**Streaks:**
- Dias consecutivos
- Maior sequência
- Data última corrida

**Time-based:**
- Corridas por dia
- Corridas por semana
- Corridas por mês
- Horários de pico

---

## 🚀 Como Usar

### Backend (Laravel)

1. **Rodar migrations:**
```bash
php artisan migrate
php artisan db:seed --class=GamificationSeeder
```

2. **Verificar progresso após corrida:**
```php
// Após completar corrida
$user->stats->addRide($ride);
$user->stats->updateRating($rating);
$user->checkLevelUp();

// Check achievements
foreach (Achievement::active()->get() as $achievement) {
    $achievement->checkProgress($user);
}
```

3. **Award badge manualmente:**
```php
$badge = Badge::find($badgeId);
$badge->awardTo($user);
```

### Frontend (Flutter)

1. **Fetch gamification profile:**
```dart
final response = await dio.get('/api/v1/gamification/profile');
final stats = UserStats.fromJson(response.data['data']);
```

2. **Listen to real-time events:**
```dart
channel.bind('achievement.completed', (data) {
  showAchievementPopup(data);
});

channel.bind('user.leveled-up', (data) {
  showLevelUpAnimation(data['new_level']);
});
```

---

## 🎯 Próximos Passos

### Funcionalidades Futuras

1. **Seasonal Events**
   - Eventos temporários
   - Badges exclusivos
   - Double XP weekends

2. **Social Features**
   - Comparar com amigos
   - Desafios entre usuários
   - Compartilhar conquistas

3. **Customização**
   - Avatares desbloqueáveis
   - Temas personalizados
   - Frames de perfil

4. **Analytics Dashboard**
   - Gráficos de progresso
   - Insights personalizados
   - Recomendações

---

**Desenvolvido com ❤️ para MOBI Platform**
