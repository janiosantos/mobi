<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pricing_rules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_category_id')->nullable()->constrained();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('base_fare', 10, 2)->default(5.00);
            $table->decimal('price_per_km', 10, 2)->default(2.50);
            $table->decimal('price_per_minute', 10, 2)->default(0.50);
            $table->decimal('minimum_fare', 10, 2)->default(8.00);
            $table->time('effective_from_time')->nullable();
            $table->time('effective_to_time')->nullable();
            $table->json('effective_days')->nullable(); // [1,2,3,4,5] for Mon-Fri
            $table->decimal('multiplier', 4, 2)->default(1.00);
            $table->integer('priority')->default(0); // Higher priority rules take precedence
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index('vehicle_category_id');
            $table->index('is_active');
            $table->index('priority');
        });

        Schema::create('surge_pricing_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_category_id')->nullable()->constrained();
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->decimal('radius', 8, 2)->default(2000); // meters
            $table->string('area_name')->nullable();
            $table->decimal('multiplier', 4, 2);
            $table->integer('demand_level'); // Number of ride requests
            $table->integer('supply_level'); // Number of available drivers
            $table->timestamp('starts_at');
            $table->timestamp('ends_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['latitude', 'longitude']);
            $table->index('is_active');
            $table->index('starts_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('surge_pricing_logs');
        Schema::dropIfExists('pricing_rules');
    }
};
