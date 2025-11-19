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
        Schema::create('referrals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('referrer_id')->constrained('users')->onDelete('cascade'); // Who invited
            $table->foreignId('referred_id')->nullable()->constrained('users')->onDelete('set null'); // Who was invited
            $table->string('referral_code', 10)->unique(); // Unique referral code
            $table->string('referred_email')->nullable();
            $table->string('referred_phone')->nullable();
            $table->string('status')->default('pending'); // pending, registered, completed, expired
            $table->decimal('referrer_credit', 10, 2)->default(0); // Credit for referrer
            $table->decimal('referred_credit', 10, 2)->default(0); // Credit for referred user
            $table->boolean('referrer_credit_applied')->default(false);
            $table->boolean('referred_credit_applied')->default(false);
            $table->timestamp('registered_at')->nullable(); // When referred user registered
            $table->timestamp('completed_at')->nullable(); // When referral was completed (first ride)
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('referrer_id');
            $table->index('referred_id');
            $table->index('referral_code');
            $table->index('status');
        });

        // Add referral fields to users table
        Schema::table('users', function (Blueprint $table) {
            $table->string('referral_code', 10)->unique()->nullable()->after('wallet_balance');
            $table->foreignId('referred_by')->nullable()->constrained('users')->onDelete('set null')->after('referral_code');
            $table->decimal('referral_credits', 10, 2)->default(0)->after('referred_by');
            $table->integer('referrals_count')->default(0)->after('referral_credits');
            $table->integer('successful_referrals_count')->default(0)->after('referrals_count');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['referred_by']);
            $table->dropColumn([
                'referral_code',
                'referred_by',
                'referral_credits',
                'referrals_count',
                'successful_referrals_count',
            ]);
        });

        Schema::dropIfExists('referrals');
    }
};
