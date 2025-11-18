<?php

namespace App\Repositories\Contracts;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

interface UserRepositoryInterface extends BaseRepositoryInterface
{
    public function findByEmail(string $email): ?User;

    public function findByPhone(string $phone): ?User;

    public function findByCpf(string $cpf): ?User;

    public function getDrivers(bool $approved = null): Collection;

    public function getPassengers(): Collection;

    public function banUser(int $userId, string $reason): bool;

    public function unbanUser(int $userId): bool;
}
