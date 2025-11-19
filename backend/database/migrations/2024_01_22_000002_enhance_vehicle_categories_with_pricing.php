<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('vehicle_categories', function (Blueprint $table) {
            $table->decimal('base_fare', 10, 2)->default(3.50)->after('description');
            $table->decimal('per_km_rate', 10, 2)->default(1.50)->after('base_fare');
            $table->decimal('per_minute_rate', 10, 2)->default(0.25)->after('per_km_rate');
            $table->decimal('minimum_fare', 10, 2)->default(5.00)->after('per_minute_rate');
            $table->json('features')->nullable()->after('minimum_fare');
            $table->renameColumn('max_passengers', 'capacity');
        });

        // Update existing data with default pricing and features
        $this->updateExistingCategories();
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('vehicle_categories', function (Blueprint $table) {
            $table->dropColumn(['base_fare', 'per_km_rate', 'per_minute_rate', 'minimum_fare', 'features']);
            $table->renameColumn('capacity', 'max_passengers');
        });
    }

    /**
     * Update existing categories with pricing and features.
     */
    private function updateExistingCategories(): void
    {
        $categories = [
            [
                'slug' => 'economy',
                'name' => 'Economy',
                'description' => 'Opção econômica para viagens do dia a dia',
                'icon' => '🚗',
                'base_fare' => 3.50,
                'per_km_rate' => 1.50,
                'per_minute_rate' => 0.25,
                'minimum_fare' => 5.00,
                'capacity' => 4,
                'features' => json_encode(['Ar condicionado', 'Música']),
                'sort_order' => 1,
            ],
            [
                'slug' => 'comfort',
                'name' => 'Comfort',
                'description' => 'Mais conforto para suas viagens',
                'icon' => '🚙',
                'base_fare' => 5.00,
                'per_km_rate' => 2.00,
                'per_minute_rate' => 0.35,
                'minimum_fare' => 8.00,
                'capacity' => 4,
                'features' => json_encode(['Ar condicionado', 'Música', 'Carros mais novos', 'Motoristas top avaliados']),
                'sort_order' => 2,
            ],
            [
                'slug' => 'premium',
                'name' => 'Premium',
                'description' => 'Viaje com luxo e exclusividade',
                'icon' => '🚘',
                'base_fare' => 8.00,
                'per_km_rate' => 3.50,
                'per_minute_rate' => 0.50,
                'minimum_fare' => 15.00,
                'capacity' => 4,
                'features' => json_encode(['Ar condicionado', 'Música', 'Carros premium', 'Wi-Fi', 'Água']),
                'sort_order' => 3,
            ],
            [
                'slug' => 'xl',
                'name' => 'XL',
                'description' => 'Para grupos de até 6 pessoas',
                'icon' => '🚐',
                'base_fare' => 6.00,
                'per_km_rate' => 2.50,
                'per_minute_rate' => 0.40,
                'minimum_fare' => 10.00,
                'capacity' => 6,
                'features' => json_encode(['Ar condicionado', 'Música', 'Mais espaço', 'Para grupos']),
                'sort_order' => 4,
            ],
            [
                'slug' => 'moto',
                'name' => 'Moto',
                'description' => 'Rápido e econômico para uma pessoa',
                'icon' => '🏍️',
                'base_fare' => 2.00,
                'per_km_rate' => 1.00,
                'per_minute_rate' => 0.15,
                'minimum_fare' => 3.00,
                'capacity' => 1,
                'features' => json_encode(['Rápido', 'Econômico', 'Capacete incluso']),
                'sort_order' => 5,
            ],
        ];

        foreach ($categories as $category) {
            DB::table('vehicle_categories')->updateOrInsert(
                ['slug' => $category['slug']],
                array_merge($category, [
                    'updated_at' => now(),
                    'created_at' => DB::raw('COALESCE(created_at, NOW())'),
                ])
            );
        }
    }
};
