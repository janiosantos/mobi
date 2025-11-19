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
        Schema::create('ride_split_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // The person paying a split
            $table->foreignId('invited_by')->nullable()->constrained('users')->onDelete('set null'); // Who invited them
            $table->string('invite_code', 8)->unique();
            $table->decimal('amount', 10, 2); // Amount this person will pay
            $table->decimal('percentage', 5, 2)->nullable(); // Percentage of total (if split by %)
            $table->string('status')->default('pending'); // pending, accepted, paid, declined, expired
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('declined_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->text('decline_reason')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('ride_id');
            $table->index('user_id');
            $table->index('status');
            $table->index('invite_code');
        });

        // Add split payment fields to rides table
        Schema::table('rides', function (Blueprint $table) {
            $table->boolean('is_split_payment')->default(false)->after('payment_status');
            $table->integer('split_count')->default(0)->after('is_split_payment');
            $table->string('split_method')->nullable()->after('split_count'); // equal, custom, percentage
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropColumn(['is_split_payment', 'split_count', 'split_method']);
        });

        Schema::dropIfExists('ride_split_payments');
    }
};
