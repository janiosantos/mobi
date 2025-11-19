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
        Schema::table('rides', function (Blueprint $table) {
            $table->boolean('is_scheduled')->default(false)->after('status');
            $table->timestamp('scheduled_at')->nullable()->after('is_scheduled');
            $table->timestamp('scheduled_pickup_window_start')->nullable()->after('scheduled_at');
            $table->timestamp('scheduled_pickup_window_end')->nullable()->after('scheduled_pickup_window_start');
            $table->string('scheduled_status')->nullable()->after('scheduled_pickup_window_end');
            // Values: pending, confirmed, driver_assigned, cancelled

            // Indexes
            $table->index('is_scheduled');
            $table->index('scheduled_at');
            $table->index('scheduled_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropIndex(['is_scheduled']);
            $table->dropIndex(['scheduled_at']);
            $table->dropIndex(['scheduled_status']);

            $table->dropColumn([
                'is_scheduled',
                'scheduled_at',
                'scheduled_pickup_window_start',
                'scheduled_pickup_window_end',
                'scheduled_status',
            ]);
        });
    }
};
