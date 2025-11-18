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
        Schema::create('earnings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_id')->constrained('users');
            $table->foreignId('ride_id')->constrained();
            $table->foreignId('payment_id')->nullable()->constrained();
            $table->decimal('ride_fare', 10, 2); // Total ride fare
            $table->decimal('platform_commission', 10, 2); // Commission taken by platform
            $table->decimal('platform_commission_percentage', 5, 2);
            $table->decimal('driver_earnings', 10, 2); // Amount driver receives
            $table->decimal('bonus', 10, 2)->default(0); // Extra bonuses
            $table->decimal('tip', 10, 2)->default(0); // Tips from passenger
            $table->decimal('total_earnings', 10, 2); // driver_earnings + bonus + tip
            $table->enum('status', ['pending', 'available', 'withdrawn', 'processing'])->default('pending');
            $table->timestamp('available_at')->nullable(); // When it becomes available for withdrawal
            $table->foreignId('withdrawal_id')->nullable()->constrained();
            $table->timestamps();

            $table->index('driver_id');
            $table->index('ride_id');
            $table->index('status');
            $table->index('available_at');
        });

        Schema::create('withdrawals', function (Blueprint $table) {
            $table->id();
            $table->string('withdrawal_number')->unique();
            $table->foreignId('driver_id')->constrained('users');
            $table->decimal('amount', 12, 2);
            $table->enum('method', ['pix', 'bank_transfer'])->default('pix');
            $table->enum('status', ['pending', 'processing', 'completed', 'failed', 'cancelled'])->default('pending');

            // Bank/PIX details (from driver_profile, snapshot at withdrawal time)
            $table->string('bank_name')->nullable();
            $table->string('bank_account_type')->nullable();
            $table->string('bank_agency')->nullable();
            $table->string('bank_account')->nullable();
            $table->string('pix_key')->nullable();
            $table->string('pix_key_type')->nullable();

            // Payment gateway info
            $table->string('gateway')->nullable();
            $table->string('gateway_transaction_id')->nullable();
            $table->text('gateway_response')->nullable();

            $table->text('notes')->nullable();
            $table->text('failure_reason')->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('failed_at')->nullable();
            $table->foreignId('processed_by')->nullable()->constrained('users');

            $table->timestamps();
            $table->softDeletes();

            $table->index('driver_id');
            $table->index('status');
            $table->index('withdrawal_number');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('earnings');
        Schema::dropIfExists('withdrawals');
    }
};
