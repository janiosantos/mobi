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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->string('payment_number')->unique(); // Human-readable payment ID
            $table->foreignId('ride_id')->constrained();
            $table->foreignId('user_id')->constrained(); // Payer (passenger)
            $table->foreignId('payment_method_id')->nullable()->constrained();
            $table->enum('payment_type', ['pix', 'credit_card', 'debit_card', 'cash', 'wallet']);
            $table->decimal('amount', 10, 2);
            $table->decimal('platform_fee', 10, 2)->default(0);
            $table->decimal('driver_amount', 10, 2);
            $table->enum('status', ['pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled'])->default('pending');
            $table->string('gateway')->default('mercadopago');
            $table->string('gateway_transaction_id')->nullable();
            $table->string('gateway_payment_id')->nullable();
            $table->text('gateway_response')->nullable();

            // PIX specific
            $table->string('pix_qr_code')->nullable();
            $table->text('pix_qr_code_base64')->nullable();
            $table->string('pix_transaction_id')->nullable();
            $table->timestamp('pix_expires_at')->nullable();

            // Card specific
            $table->string('card_brand')->nullable();
            $table->string('card_last_four')->nullable();
            $table->integer('installments')->default(1);

            // Refund Info
            $table->decimal('refund_amount', 10, 2)->nullable();
            $table->text('refund_reason')->nullable();
            $table->timestamp('refunded_at')->nullable();

            // Timestamps
            $table->timestamp('processed_at')->nullable();
            $table->timestamp('failed_at')->nullable();
            $table->text('failure_reason')->nullable();

            $table->timestamps();
            $table->softDeletes();

            $table->index('payment_number');
            $table->index('ride_id');
            $table->index('user_id');
            $table->index('status');
            $table->index('gateway_transaction_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
