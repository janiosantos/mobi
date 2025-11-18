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
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_profile_id')->constrained()->onDelete('cascade');
            $table->foreignId('vehicle_category_id')->constrained();
            $table->string('make'); // Marca (ex: Toyota, Honda)
            $table->string('model'); // Modelo (ex: Corolla, Civic)
            $table->year('year');
            $table->string('color');
            $table->string('license_plate')->unique();
            $table->string('renavam')->unique()->nullable();
            $table->integer('seats')->default(4);
            $table->string('photo')->nullable();
            $table->boolean('has_air_conditioning')->default(true);
            $table->boolean('is_active')->default(true);
            $table->boolean('is_primary')->default(false);
            $table->timestamps();
            $table->softDeletes();

            $table->index('driver_profile_id');
            $table->index('vehicle_category_id');
            $table->index('license_plate');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vehicles');
    }
};
