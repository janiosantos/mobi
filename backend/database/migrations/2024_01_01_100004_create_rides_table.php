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
        Schema::create('rides', function (Blueprint $table) {
            $table->id();
            $table->string('ride_number')->unique(); // Human-readable ride ID
            $table->foreignId('passenger_id')->constrained('users');
            $table->foreignId('driver_id')->nullable()->constrained('users');
            $table->foreignId('vehicle_id')->nullable()->constrained();
            $table->foreignId('vehicle_category_id')->constrained();

            // Pickup Location
            $table->decimal('pickup_latitude', 10, 7);
            $table->decimal('pickup_longitude', 10, 7);
            $table->string('pickup_address');
            $table->string('pickup_city')->nullable();
            $table->string('pickup_state')->nullable();
            $table->string('pickup_country')->default('Brasil');
            $table->string('pickup_postal_code')->nullable();
            $table->text('pickup_notes')->nullable();

            // Dropoff Location
            $table->decimal('dropoff_latitude', 10, 7);
            $table->decimal('dropoff_longitude', 10, 7);
            $table->string('dropoff_address');
            $table->string('dropoff_city')->nullable();
            $table->string('dropoff_state')->nullable();
            $table->string('dropoff_country')->default('Brasil');
            $table->string('dropoff_postal_code')->nullable();
            $table->text('dropoff_notes')->nullable();

            // Ride Details
            $table->decimal('estimated_distance', 8, 2)->nullable(); // km
            $table->integer('estimated_duration')->nullable(); // minutes
            $table->decimal('actual_distance', 8, 2)->nullable(); // km
            $table->integer('actual_duration')->nullable(); // minutes
            $table->text('route_polyline')->nullable(); // Encoded polyline from Google

            // Pricing
            $table->decimal('estimated_price', 10, 2);
            $table->decimal('final_price', 10, 2)->nullable();
            $table->decimal('base_fare', 10, 2);
            $table->decimal('distance_fare', 10, 2);
            $table->decimal('time_fare', 10, 2);
            $table->decimal('surge_multiplier', 4, 2)->default(1.00);
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->foreignId('coupon_id')->nullable()->constrained();
            $table->decimal('platform_fee', 10, 2)->default(0);
            $table->decimal('driver_earnings', 10, 2)->nullable();

            // Status & Timestamps
            $table->enum('status', [
                'requested',           // Passageiro solicitou a corrida
                'searching',          // Procurando motorista
                'accepted',           // Motorista aceitou
                'driver_arrived',     // Motorista chegou no local de embarque
                'in_progress',        // Corrida iniciada
                'completed',          // Corrida finalizada
                'cancelled_by_passenger',
                'cancelled_by_driver',
                'cancelled_by_system',
                'no_driver_found'
            ])->default('requested');

            $table->timestamp('requested_at')->nullable();
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('driver_arrived_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();

            // Cancellation Info
            $table->enum('cancelled_by', ['passenger', 'driver', 'system'])->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->decimal('cancellation_fee', 10, 2)->nullable();

            // Payment
            $table->enum('payment_status', ['pending', 'processing', 'paid', 'failed', 'refunded'])->default('pending');
            $table->enum('payment_method', ['pix', 'credit_card', 'debit_card', 'cash', 'wallet'])->nullable();
            $table->foreignId('payment_id')->nullable()->constrained();

            // Additional Info
            $table->text('passenger_notes')->nullable();
            $table->integer('waiting_time')->default(0); // seconds
            $table->json('metadata')->nullable(); // For extra data

            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index('ride_number');
            $table->index('passenger_id');
            $table->index('driver_id');
            $table->index('status');
            $table->index('payment_status');
            $table->index('requested_at');
            $table->index('completed_at');
            $table->index(['pickup_latitude', 'pickup_longitude']);
            $table->index(['dropoff_latitude', 'dropoff_longitude']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rides');
    }
};
