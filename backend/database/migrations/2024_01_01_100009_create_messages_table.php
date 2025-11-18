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
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained();
            $table->foreignId('sender_id')->constrained('users');
            $table->foreignId('recipient_id')->constrained('users');
            $table->enum('sender_type', ['passenger', 'driver']);
            $table->text('message');
            $table->enum('type', ['text', 'image', 'location', 'system'])->default('text');
            $table->string('attachment_url')->nullable();
            $table->decimal('location_latitude', 10, 7)->nullable();
            $table->decimal('location_longitude', 10, 7)->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('ride_id');
            $table->index('sender_id');
            $table->index('recipient_id');
            $table->index('is_read');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
