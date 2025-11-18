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
        Schema::create('payment_methods', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['credit_card', 'debit_card', 'pix']);
            $table->boolean('is_default')->default(false);

            // Card Info (encrypted/tokenized)
            $table->string('card_token')->nullable(); // Token from payment gateway
            $table->string('card_brand')->nullable(); // Visa, Mastercard, etc
            $table->string('card_last_four')->nullable();
            $table->string('card_holder_name')->nullable();
            $table->string('card_expiry_month')->nullable();
            $table->string('card_expiry_year')->nullable();

            // Pix Info
            $table->string('pix_key')->nullable();
            $table->enum('pix_key_type', ['cpf', 'cnpj', 'email', 'phone', 'random'])->nullable();

            // Gateway Info
            $table->string('gateway')->default('mercadopago'); // mercadopago, stripe, etc
            $table->string('gateway_customer_id')->nullable();
            $table->string('gateway_payment_method_id')->nullable();

            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('type');
            $table->index('is_default');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payment_methods');
    }
};
