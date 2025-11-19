<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class GamificationSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedBadges();
        $this->seedAchievements();
    }

    private function seedBadges(): void
    {
        $badges = [
            // Rides Badges
            [
                'name' => 'Primeiro Passo',
                'slug' => 'first-ride',
                'description' => 'Complete sua primeira corrida',
                'icon' => '🚗',
                'category' => 'rides',
                'rarity' => 'common',
                'points' => 10,
                'criteria' => json_encode(['rides_count' => 1]),
            ],
            [
                'name' => 'Explorador',
                'slug' => 'explorer',
                'description' => 'Complete 50 corridas',
                'icon' => '🗺️',
                'category' => 'rides',
                'rarity' => 'rare',
                'points' => 50,
                'criteria' => json_encode(['rides_count' => 50]),
            ],
            [
                'name' => 'Veterano',
                'slug' => 'veteran',
                'description' => 'Complete 500 corridas',
                'icon' => '⭐',
                'category' => 'rides',
                'rarity' => 'epic',
                'points' => 200,
                'criteria' => json_encode(['rides_count' => 500]),
            ],
            [
                'name' => 'Lenda',
                'slug' => 'legend',
                'description' => 'Complete 1000 corridas',
                'icon' => '👑',
                'category' => 'rides',
                'rarity' => 'legendary',
                'points' => 500,
                'criteria' => json_encode(['rides_count' => 1000]),
            ],

            // Earnings Badges
            [
                'name' => 'Primeiro Ganho',
                'slug' => 'first-earning',
                'description' => 'Ganhe seus primeiros R$ 100',
                'icon' => '💵',
                'category' => 'earnings',
                'rarity' => 'common',
                'points' => 10,
                'criteria' => json_encode(['total_earnings' => 100]),
            ],
            [
                'name' => 'Empreendedor',
                'slug' => 'entrepreneur',
                'description' => 'Ganhe R$ 10.000',
                'icon' => '💰',
                'category' => 'earnings',
                'rarity' => 'epic',
                'points' => 150,
                'criteria' => json_encode(['total_earnings' => 10000]),
            ],
            [
                'name' => 'Magnata',
                'slug' => 'tycoon',
                'description' => 'Ganhe R$ 100.000',
                'icon' => '🏆',
                'category' => 'earnings',
                'rarity' => 'legendary',
                'points' => 500,
                'criteria' => json_encode(['total_earnings' => 100000]),
            ],

            // Rating Badges
            [
                'name' => 'Bem Avaliado',
                'slug' => 'well-rated',
                'description' => 'Mantenha média 4.5 com 20+ avaliações',
                'icon' => '⭐',
                'category' => 'ratings',
                'rarity' => 'rare',
                'points' => 50,
                'criteria' => json_encode(['average_rating' => 4.5, 'min_ratings' => 20]),
            ],
            [
                'name' => 'Cinco Estrelas',
                'slug' => 'five-stars',
                'description' => 'Mantenha média 4.8 com 50+ avaliações',
                'icon' => '🌟',
                'category' => 'ratings',
                'rarity' => 'epic',
                'points' => 200,
                'criteria' => json_encode(['average_rating' => 4.8, 'min_ratings' => 50]),
            ],
            [
                'name' => 'Perfeição',
                'slug' => 'perfection',
                'description' => 'Mantenha média 4.9 com 100+ avaliações',
                'icon' => '💎',
                'category' => 'ratings',
                'rarity' => 'legendary',
                'points' => 500,
                'criteria' => json_encode(['average_rating' => 4.9, 'min_ratings' => 100]),
            ],

            // Streak Badges
            [
                'name' => 'Dedicado',
                'slug' => 'dedicated',
                'description' => 'Faça corridas por 7 dias consecutivos',
                'icon' => '🔥',
                'category' => 'streak',
                'rarity' => 'rare',
                'points' => 50,
                'criteria' => json_encode(['streak_days' => 7]),
            ],
            [
                'name' => 'Incansável',
                'slug' => 'unstoppable',
                'description' => 'Faça corridas por 30 dias consecutivos',
                'icon' => '⚡',
                'category' => 'streak',
                'rarity' => 'epic',
                'points' => 200,
                'criteria' => json_encode(['streak_days' => 30]),
            ],
            [
                'name' => 'Maratonista',
                'slug' => 'marathoner',
                'description' => 'Faça corridas por 90 dias consecutivos',
                'icon' => '🏃',
                'category' => 'streak',
                'rarity' => 'legendary',
                'points' => 500,
                'criteria' => json_encode(['streak_days' => 90]),
            ],

            // Special Badges
            [
                'name' => 'Noturno',
                'slug' => 'night-owl',
                'description' => 'Complete 50 corridas entre 22h e 6h',
                'icon' => '🌙',
                'category' => 'special',
                'rarity' => 'rare',
                'points' => 50,
                'criteria' => json_encode(['night_rides' => 50]),
            ],
            [
                'name' => 'Fim de Semana',
                'slug' => 'weekender',
                'description' => 'Complete 100 corridas em fins de semana',
                'icon' => '🎉',
                'category' => 'special',
                'rarity' => 'rare',
                'points' => 50,
                'criteria' => json_encode(['weekend_rides' => 100]),
            ],
            [
                'name' => 'Ajudante',
                'slug' => 'helper',
                'description' => 'Ajude 10 usuários com problemas',
                'icon' => '🤝',
                'category' => 'special',
                'rarity' => 'epic',
                'points' => 100,
                'criteria' => json_encode(['help_count' => 10]),
            ],
        ];

        DB::table('badges')->insert($badges);
    }

    private function seedAchievements(): void
    {
        $achievements = [
            // Progressive Achievements - Rides
            [
                'name' => '10 Corridas',
                'slug' => '10-rides',
                'description' => 'Complete 10 corridas',
                'icon' => '🚕',
                'type' => 'progressive',
                'target_value' => 10,
                'target_metric' => 'rides_count',
                'xp_reward' => 50,
                'money_reward' => 0,
                'badge_id' => null,
                'is_repeatable' => false,
            ],
            [
                'name' => '100 Corridas',
                'slug' => '100-rides',
                'description' => 'Complete 100 corridas',
                'icon' => '🚙',
                'type' => 'progressive',
                'target_value' => 100,
                'target_metric' => 'rides_count',
                'xp_reward' => 200,
                'money_reward' => 50.00,
                'badge_id' => null,
                'is_repeatable' => false,
            ],
            [
                'name' => '1000 Corridas',
                'slug' => '1000-rides',
                'description' => 'Complete 1000 corridas',
                'icon' => '🚗',
                'type' => 'progressive',
                'target_value' => 1000,
                'target_metric' => 'rides_count',
                'xp_reward' => 1000,
                'money_reward' => 500.00,
                'badge_id' => null,
                'is_repeatable' => false,
            ],

            // Milestone Achievements - Earnings
            [
                'name' => 'Primeiro Mil',
                'slug' => 'first-thousand',
                'description' => 'Ganhe R$ 1.000',
                'icon' => '💵',
                'type' => 'milestone',
                'target_value' => 1000,
                'target_metric' => 'total_earnings',
                'xp_reward' => 100,
                'money_reward' => 0,
                'badge_id' => null,
                'is_repeatable' => false,
            ],
            [
                'name' => 'Dez Mil',
                'slug' => 'ten-thousand',
                'description' => 'Ganhe R$ 10.000',
                'icon' => '💰',
                'type' => 'milestone',
                'target_value' => 10000,
                'target_metric' => 'total_earnings',
                'xp_reward' => 500,
                'money_reward' => 100.00,
                'badge_id' => null,
                'is_repeatable' => false,
            ],

            // Challenge Achievements
            [
                'name' => 'Maratona Diária',
                'slug' => 'daily-marathon',
                'description' => 'Complete 20 corridas em um único dia',
                'icon' => '🏁',
                'type' => 'challenge',
                'target_value' => 20,
                'target_metric' => 'daily_rides',
                'xp_reward' => 200,
                'money_reward' => 50.00,
                'badge_id' => null,
                'is_repeatable' => true,
            ],
            [
                'name' => 'Semana Intensa',
                'slug' => 'intense-week',
                'description' => 'Complete 100 corridas em uma semana',
                'icon' => '📅',
                'type' => 'challenge',
                'target_value' => 100,
                'target_metric' => 'weekly_rides',
                'xp_reward' => 500,
                'money_reward' => 200.00,
                'badge_id' => null,
                'is_repeatable' => true,
            ],

            // Secret Achievements
            [
                'name' => 'Explorador Secreto',
                'slug' => 'secret-explorer',
                'description' => 'Descubra todas as rotas secretas',
                'icon' => '🗺️',
                'type' => 'secret',
                'target_value' => 10,
                'target_metric' => 'secret_routes',
                'xp_reward' => 300,
                'money_reward' => 100.00,
                'badge_id' => null,
                'is_repeatable' => false,
            ],
            [
                'name' => 'Colecionador',
                'slug' => 'collector',
                'description' => 'Conquiste todos os badges comuns',
                'icon' => '🎖️',
                'type' => 'secret',
                'target_value' => 5,
                'target_metric' => 'common_badges',
                'xp_reward' => 500,
                'money_reward' => 250.00,
                'badge_id' => null,
                'is_repeatable' => false,
            ],
        ];

        DB::table('achievements')->insert($achievements);
    }
}
