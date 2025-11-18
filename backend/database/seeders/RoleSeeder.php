<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create roles
        $admin = Role::firstOrCreate(['name' => 'admin']);
        $driver = Role::firstOrCreate(['name' => 'driver']);
        $passenger = Role::firstOrCreate(['name' => 'passenger']);

        // Create permissions
        $permissions = [
            // Ride permissions
            'create-ride',
            'view-ride',
            'cancel-ride',
            'accept-ride',
            'start-ride',
            'complete-ride',

            // Driver permissions
            'manage-vehicle',
            'update-location',
            'manage-earnings',

            // Admin permissions
            'manage-users',
            'manage-drivers',
            'manage-categories',
            'manage-pricing',
            'view-reports',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Assign permissions to roles
        $admin->givePermissionTo(Permission::all());

        $driver->givePermissionTo([
            'view-ride',
            'accept-ride',
            'start-ride',
            'complete-ride',
            'cancel-ride',
            'manage-vehicle',
            'update-location',
            'manage-earnings',
        ]);

        $passenger->givePermissionTo([
            'create-ride',
            'view-ride',
            'cancel-ride',
        ]);

        $this->command->info('Roles and permissions seeded successfully!');
    }
}
