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
        Schema::create('ride_locations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained()->onDelete('cascade');
            $table->foreignId('driver_id')->constrained('users');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->decimal('heading', 5, 2)->nullable(); // direction in degrees (0-360)
            $table->decimal('speed', 5, 2)->nullable(); // km/h
            $table->decimal('accuracy', 6, 2)->nullable(); // meters
            $table->timestamp('recorded_at');
            $table->timestamps();

            $table->index('ride_id');
            $table->index('driver_id');
            $table->index('recorded_at');
            $table->index(['latitude', 'longitude']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ride_locations');
    }
};
