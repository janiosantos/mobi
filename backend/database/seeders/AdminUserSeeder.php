<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admin = User::firstOrCreate(
            ['email' => 'admin@mobi.com'],
            [
                'name' => 'MOBI Admin',
                'email' => 'admin@mobi.com',
                'phone' => '+5511999999999',
                'password' => Hash::make('admin123456'),
                'user_type' => 'admin',
                'cpf' => '000.000.000-00',
                'birth_date' => '1990-01-01',
                'is_active' => true,
                'is_verified' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        // Assign admin role
        if (!$admin->hasRole('admin')) {
            $admin->assignRole('admin');
        }

        $this->command->info('Admin user created successfully!');
        $this->command->info('Email: admin@mobi.com');
        $this->command->info('Password: admin123456');
    }
}
