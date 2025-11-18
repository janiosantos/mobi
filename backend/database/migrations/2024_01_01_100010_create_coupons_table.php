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
        Schema::create('coupons', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->text('description')->nullable();
            $table->enum('type', ['percentage', 'fixed_amount', 'first_ride_free']);
            $table->decimal('discount_value', 10, 2); // Percentage or fixed amount
            $table->decimal('max_discount_amount', 10, 2)->nullable(); // Max discount for percentage coupons
            $table->decimal('min_ride_amount', 10, 2)->nullable(); // Minimum ride value to use coupon
            $table->integer('max_uses')->nullable(); // Total uses across all users
            $table->integer('max_uses_per_user')->default(1);
            $table->integer('current_uses')->default(0);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->boolean('first_ride_only')->default(false);
            $table->json('allowed_categories')->nullable(); // Vehicle categories
            $table->json('allowed_user_ids')->nullable(); // Specific users only
            $table->timestamps();
            $table->softDeletes();

            $table->index('code');
            $table->index('is_active');
            $table->index('expires_at');
        });

        Schema::create('coupon_usage', function (Blueprint $table) {
            $table->id();
            $table->foreignId('coupon_id')->constrained();
            $table->foreignId('user_id')->constrained();
            $table->foreignId('ride_id')->constrained();
            $table->decimal('discount_amount', 10, 2);
            $table->timestamp('used_at');
            $table->timestamps();

            $table->index('coupon_id');
            $table->index('user_id');
            $table->index('ride_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('coupon_usage');
        Schema::dropIfExists('coupons');
    }
};
