<?php

namespace App\Repositories;

use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class UserRepository extends BaseRepository implements UserRepositoryInterface
{
    public function __construct(User $model)
    {
        parent::__construct($model);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->model->where('email', $email)->first();
    }

    public function findByPhone(string $phone): ?User
    {
        return $this->model->where('phone', $phone)->first();
    }

    public function findByCpf(string $cpf): ?User
    {
        return $this->model->where('cpf', $cpf)->first();
    }

    public function getDrivers(bool $approved = null): Collection
    {
        $query = $this->model->drivers();

        if ($approved !== null) {
            $query->whereHas('driverProfile', function ($q) use ($approved) {
                $status = $approved ? 'approved' : 'pending';
                $q->where('status', $status);
            });
        }

        return $query->with('driverProfile')->get();
    }

    public function getPassengers(): Collection
    {
        return $this->model->passengers()->get();
    }

    public function banUser(int $userId, string $reason): bool
    {
        return $this->update($userId, [
            'is_banned' => true,
            'banned_at' => now(),
            'ban_reason' => $reason,
            'is_active' => false,
        ]);
    }

    public function unbanUser(int $userId): bool
    {
        return $this->update($userId, [
            'is_banned' => false,
            'banned_at' => null,
            'ban_reason' => null,
            'is_active' => true,
        ]);
    }
}
