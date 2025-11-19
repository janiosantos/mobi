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
        // Emergency contacts table
        Schema::create('emergency_contacts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->string('phone');
            $table->string('relationship')->nullable(); // 'mother', 'father', 'spouse', 'friend'
            $table->boolean('is_primary')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'is_primary']);
        });

        // Add safety fields to rides table
        Schema::table('rides', function (Blueprint $table) {
            $table->boolean('share_trip')->default(false)->after('status');
            $table->string('share_code', 6)->unique()->nullable()->after('share_trip');
            $table->timestamp('share_expires_at')->nullable()->after('share_code');
            $table->timestamp('sos_triggered_at')->nullable()->after('share_expires_at');
            $table->text('sos_note')->nullable()->after('sos_triggered_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropColumn(['share_trip', 'share_code', 'share_expires_at', 'sos_triggered_at', 'sos_note']);
        });

        Schema::dropIfExists('emergency_contacts');
    }
};
