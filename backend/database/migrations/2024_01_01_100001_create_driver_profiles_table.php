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
        Schema::create('driver_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('license_number')->unique(); // CNH
            $table->string('license_category'); // A, B, AB, C, D, E
            $table->date('license_expiry_date');
            $table->string('license_photo')->nullable();
            $table->enum('status', ['pending', 'under_review', 'approved', 'rejected', 'suspended'])->default('pending');
            $table->text('rejection_reason')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users');
            $table->boolean('is_online')->default(false);
            $table->boolean('is_available')->default(false);
            $table->decimal('current_latitude', 10, 7)->nullable();
            $table->decimal('current_longitude', 10, 7)->nullable();
            $table->decimal('heading', 5, 2)->nullable(); // direction in degrees
            $table->decimal('speed', 5, 2)->nullable(); // km/h
            $table->timestamp('last_location_update')->nullable();
            $table->timestamp('went_online_at')->nullable();
            $table->timestamp('went_offline_at')->nullable();
            $table->decimal('average_rating', 3, 2)->default(0)->nullable();
            $table->unsignedInteger('total_ratings')->default(0);
            $table->unsignedInteger('total_rides')->default(0);
            $table->unsignedInteger('total_rides_completed')->default(0);
            $table->unsignedInteger('total_rides_cancelled')->default(0);
            $table->decimal('acceptance_rate', 5, 2)->default(100)->nullable();
            $table->decimal('cancellation_rate', 5, 2)->default(0)->nullable();
            $table->decimal('total_earnings', 12, 2)->default(0);
            $table->decimal('available_balance', 12, 2)->default(0);
            $table->string('bank_name')->nullable();
            $table->string('bank_account_type')->nullable(); // corrente, poupança
            $table->string('bank_agency')->nullable();
            $table->string('bank_account')->nullable();
            $table->string('pix_key')->nullable();
            $table->enum('pix_key_type', ['cpf', 'cnpj', 'email', 'phone', 'random'])->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('status');
            $table->index('is_online');
            $table->index('is_available');
            $table->index(['current_latitude', 'current_longitude']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('driver_profiles');
    }
};
