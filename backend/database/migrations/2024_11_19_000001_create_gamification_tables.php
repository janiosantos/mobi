<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('badges', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description');
            $table->string('icon')->nullable(); // URL ou emoji
            $table->enum('category', ['rides', 'earnings', 'ratings', 'streak', 'special'])->default('rides');
            $table->enum('rarity', ['common', 'rare', 'epic', 'legendary'])->default('common');
            $table->integer('points')->default(0); // Pontos de XP
            $table->json('criteria')->nullable(); // Critérios para conquistar
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('achievements', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description');
            $table->string('icon')->nullable();
            $table->enum('type', ['milestone', 'progressive', 'secret', 'challenge'])->default('milestone');
            $table->integer('target_value')->default(1); // Valor alvo (ex: 100 corridas)
            $table->string('target_metric'); // Métrica (rides_count, total_earnings, etc)
            $table->integer('xp_reward')->default(0);
            $table->decimal('money_reward', 10, 2)->default(0);
            $table->foreignId('badge_id')->nullable()->constrained()->nullOnDelete();
            $table->json('requirements')->nullable(); // Requisitos adicionais
            $table->boolean('is_repeatable')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('user_achievements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('achievement_id')->constrained()->cascadeOnDelete();
            $table->integer('current_progress')->default(0);
            $table->integer('target_progress');
            $table->boolean('is_completed')->default(false);
            $table->timestamp('completed_at')->nullable();
            $table->integer('times_completed')->default(0); // Para achievements repetíveis
            $table->timestamps();

            $table->unique(['user_id', 'achievement_id']);
            $table->index(['user_id', 'is_completed']);
        });

        Schema::create('user_badges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('badge_id')->constrained()->cascadeOnDelete();
            $table->timestamp('earned_at');
            $table->timestamps();

            $table->unique(['user_id', 'badge_id']);
        });

        Schema::create('user_stats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->integer('level')->default(1);
            $table->integer('current_xp')->default(0);
            $table->integer('total_xp')->default(0);
            $table->integer('xp_to_next_level')->default(100);
            $table->integer('total_rides')->default(0);
            $table->integer('completed_rides')->default(0);
            $table->integer('cancelled_rides')->default(0);
            $table->decimal('total_earnings', 10, 2)->default(0);
            $table->decimal('average_rating', 3, 2)->default(0);
            $table->integer('total_ratings')->default(0);
            $table->integer('current_streak')->default(0); // Dias consecutivos
            $table->integer('longest_streak')->default(0);
            $table->date('last_ride_date')->nullable();
            $table->json('monthly_stats')->nullable(); // Estatísticas por mês
            $table->timestamps();

            $table->unique('user_id');
        });

        Schema::create('leaderboards', function (Blueprint $table) {
            $table->id();
            $table->enum('type', ['weekly', 'monthly', 'all_time'])->default('weekly');
            $table->enum('category', ['rides', 'earnings', 'ratings', 'xp'])->default('rides');
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->integer('rank');
            $table->integer('score');
            $table->date('period_start');
            $table->date('period_end');
            $table->timestamps();

            $table->index(['type', 'category', 'period_start', 'period_end']);
            $table->index(['user_id', 'type', 'category']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('leaderboards');
        Schema::dropIfExists('user_stats');
        Schema::dropIfExists('user_badges');
        Schema::dropIfExists('user_achievements');
        Schema::dropIfExists('achievements');
        Schema::dropIfExists('badges');
    }
};
