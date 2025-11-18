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
        Schema::create('driver_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_profile_id')->constrained()->onDelete('cascade');
            $table->enum('document_type', ['cnh', 'crlv', 'profile_photo', 'vehicle_photo', 'criminal_record', 'other']);
            $table->string('file_path');
            $table->string('file_name');
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size'); // bytes
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->text('rejection_reason')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users');
            $table->date('expiry_date')->nullable();
            $table->json('metadata')->nullable(); // For OCR data, AI analysis results, etc
            $table->timestamps();
            $table->softDeletes();

            $table->index('driver_profile_id');
            $table->index('document_type');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('driver_documents');
    }
};
