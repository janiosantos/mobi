<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Rating extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'ride_id', 'rater_id', 'rated_id', 'rater_type',
        'rating', 'comment', 'tags', 'is_visible',
        'is_flagged', 'flag_reason',
    ];

    protected function casts(): array
    {
        return [
            'tags' => 'array',
            'is_visible' => 'boolean',
            'is_flagged' => 'boolean',
        ];
    }

    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    public function rater()
    {
        return $this->belongsTo(User::class, 'rater_id');
    }

    public function rated()
    {
        return $this->belongsTo(User::class, 'rated_id');
    }

    public function scopeVisible($query)
    {
        return $query->where('is_visible', true)->where('is_flagged', false);
    }
}
