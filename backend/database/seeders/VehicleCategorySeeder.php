<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\VehicleCategory;

class VehicleCategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'MOBI Economy',
                'slug' => 'economy',
                'description' => 'Opção econômica para o dia a dia',
                'base_fare' => 5.00,
                'price_per_km' => 2.00,
                'price_per_minute' => 0.40,
                'minimum_fare' => 8.00,
                'seats' => 4,
                'is_active' => true,
                'sort_order' => 1,
            ],
            [
                'name' => 'MOBI Comfort',
                'slug' => 'comfort',
                'description' => 'Conforto e qualidade com veículos mais novos',
                'base_fare' => 7.00,
                'price_per_km' => 2.50,
                'price_per_minute' => 0.50,
                'minimum_fare' => 12.00,
                'seats' => 4,
                'is_active' => true,
                'sort_order' => 2,
            ],
            [
                'name' => 'MOBI Premium',
                'slug' => 'premium',
                'description' => 'Viaje com luxo e exclusividade',
                'base_fare' => 10.00,
                'price_per_km' => 3.50,
                'price_per_minute' => 0.70,
                'minimum_fare' => 18.00,
                'seats' => 4,
                'is_active' => true,
                'sort_order' => 3,
            ],
            [
                'name' => 'MOBI XL',
                'slug' => 'xl',
                'description' => 'Para grupos de até 6 pessoas',
                'base_fare' => 8.00,
                'price_per_km' => 3.00,
                'price_per_minute' => 0.60,
                'minimum_fare' => 15.00,
                'seats' => 6,
                'is_active' => true,
                'sort_order' => 4,
            ],
            [
                'name' => 'MOBI Moto',
                'slug' => 'moto',
                'description' => 'Rápido e econômico, ideal para curtas distâncias',
                'base_fare' => 3.00,
                'price_per_km' => 1.50,
                'price_per_minute' => 0.30,
                'minimum_fare' => 5.00,
                'seats' => 1,
                'is_active' => true,
                'sort_order' => 5,
            ],
        ];

        foreach ($categories as $category) {
            VehicleCategory::updateOrCreate(
                ['slug' => $category['slug']],
                $category
            );
        }

        $this->command->info('Vehicle categories seeded successfully!');
    }
}
