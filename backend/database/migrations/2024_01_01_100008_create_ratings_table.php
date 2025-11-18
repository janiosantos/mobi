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
        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained();
            $table->foreignId('rater_id')->constrained('users'); // Who is rating
            $table->foreignId('rated_id')->constrained('users'); // Who is being rated
            $table->enum('rater_type', ['passenger', 'driver']);
            $table->unsignedTinyInteger('rating'); // 1-5 stars
            $table->text('comment')->nullable();
            $table->json('tags')->nullable(); // ["pontual", "educado", "carro limpo"]
            $table->boolean('is_visible')->default(true);
            $table->boolean('is_flagged')->default(false);
            $table->text('flag_reason')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('ride_id');
            $table->index('rater_id');
            $table->index('rated_id');
            $table->index('rater_type');

            // Ensure one rating per person per ride
            $table->unique(['ride_id', 'rater_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ratings');
    }
};
