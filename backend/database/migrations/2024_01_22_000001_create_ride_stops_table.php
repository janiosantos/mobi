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
        Schema::create('ride_stops', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained()->onDelete('cascade');
            $table->integer('stop_number'); // Order of stop (1, 2, 3)
            $table->string('address');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->integer('wait_time_minutes')->default(3); // Time to wait at stop
            $table->timestamp('arrived_at')->nullable();
            $table->timestamp('departed_at')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('ride_id');
            $table->index(['ride_id', 'stop_number']);
        });

        // Add support for multiple stops in rides table
        Schema::table('rides', function (Blueprint $table) {
            $table->boolean('has_stops')->default(false)->after('dropoff_longitude');
            $table->integer('stops_count')->default(0)->after('has_stops');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropColumn(['has_stops', 'stops_count']);
        });

        Schema::dropIfExists('ride_stops');
    }
};
