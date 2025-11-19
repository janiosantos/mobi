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
        Schema::create('shared_rides', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('vehicle_id')->nullable()->constrained()->onDelete('set null');
            $table->decimal('pickup_latitude', 10, 7);
            $table->decimal('pickup_longitude', 10, 7);
            $table->string('pickup_address');
            $table->decimal('dropoff_latitude', 10, 7);
            $table->decimal('dropoff_longitude', 10, 7);
            $table->string('dropoff_address');
            $table->timestamp('departure_time');
            $table->integer('max_passengers')->default(4);
            $table->integer('current_passengers')->default(0);
            $table->decimal('price_per_seat', 10, 2);
            $table->enum('status', ['scheduled', 'in_progress', 'completed', 'cancelled'])->default('scheduled');
            $table->timestamps();

            $table->index(['driver_id', 'status']);
            $table->index(['departure_time', 'status']);
            $table->index(['pickup_latitude', 'pickup_longitude']);
            $table->index(['dropoff_latitude', 'dropoff_longitude']);
        });

        Schema::create('shared_ride_passengers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shared_ride_id')->constrained()->onDelete('cascade');
            $table->foreignId('passenger_id')->constrained('users')->onDelete('cascade');
            $table->decimal('pickup_latitude', 10, 7);
            $table->decimal('pickup_longitude', 10, 7);
            $table->string('pickup_address');
            $table->decimal('dropoff_latitude', 10, 7);
            $table->decimal('dropoff_longitude', 10, 7);
            $table->string('dropoff_address');
            $table->enum('status', ['pending', 'confirmed', 'picked_up', 'dropped_off', 'cancelled'])->default('confirmed');
            $table->decimal('price', 10, 2);
            $table->timestamps();

            $table->index(['shared_ride_id', 'status']);
            $table->index(['passenger_id', 'status']);
            $table->unique(['shared_ride_id', 'passenger_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('shared_ride_passengers');
        Schema::dropIfExists('shared_rides');
    }
};
