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
        Schema::create('sos_alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('ride_id')->nullable()->constrained()->onDelete('set null');
            $table->string('status')->default('active'); // active, resolved, cancelled
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->decimal('accuracy', 8, 2)->nullable();
            $table->text('note')->nullable();
            $table->string('tracking_code')->unique();
            $table->timestamp('activated_at');
            $table->timestamp('deactivated_at')->nullable();
            $table->string('resolution')->nullable();
            $table->timestamp('last_heartbeat_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status']);
            $table->index('tracking_code');
            $table->index('activated_at');
        });

        Schema::create('sos_location_updates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sos_alert_id')->constrained()->onDelete('cascade');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->decimal('accuracy', 8, 2)->nullable();
            $table->timestamp('recorded_at');
            $table->timestamps();

            $table->index(['sos_alert_id', 'recorded_at']);
        });

        Schema::create('sos_notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sos_alert_id')->constrained()->onDelete('cascade');
            $table->foreignId('emergency_contact_id')->constrained()->onDelete('cascade');
            $table->string('status')->default('pending'); // pending, sent, failed
            $table->timestamp('sent_at')->nullable();
            $table->text('error_message')->nullable();
            $table->timestamps();

            $table->index(['sos_alert_id', 'status']);
        });

        Schema::create('sos_monitoring_alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sos_alert_id')->constrained()->onDelete('cascade');
            $table->string('reason');
            $table->text('details')->nullable();
            $table->string('status')->default('pending'); // pending, acknowledged, resolved
            $table->foreignId('acknowledged_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('acknowledged_at')->nullable();
            $table->timestamps();

            $table->index(['sos_alert_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sos_monitoring_alerts');
        Schema::dropIfExists('sos_notifications');
        Schema::dropIfExists('sos_location_updates');
        Schema::dropIfExists('sos_alerts');
    }
};
