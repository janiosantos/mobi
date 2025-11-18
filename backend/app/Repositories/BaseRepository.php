<?php

namespace App\Repositories;

use App\Repositories\Contracts\BaseRepositoryInterface;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;

abstract class BaseRepository implements BaseRepositoryInterface
{
    protected Model $model;
    protected Builder $query;

    public function __construct(Model $model)
    {
        $this->model = $model;
        $this->query = $model->newQuery();
    }

    public function all(array $columns = ['*']): Collection
    {
        return $this->query->get($columns);
    }

    public function paginate(int $perPage = 15, array $columns = ['*']): LengthAwarePaginator
    {
        return $this->query->paginate($perPage, $columns);
    }

    public function find(int $id, array $columns = ['*']): ?Model
    {
        return $this->query->find($id, $columns);
    }

    public function findOrFail(int $id, array $columns = ['*']): Model
    {
        return $this->query->findOrFail($id, $columns);
    }

    public function findBy(string $field, mixed $value, array $columns = ['*']): ?Model
    {
        return $this->query->where($field, $value)->first($columns);
    }

    public function findWhere(array $where, array $columns = ['*']): Collection
    {
        return $this->query->where($where)->get($columns);
    }

    public function create(array $data): Model
    {
        return $this->model->create($data);
    }

    public function update(int $id, array $data): bool
    {
        $record = $this->find($id);

        if (!$record) {
            return false;
        }

        return $record->update($data);
    }

    public function delete(int $id): bool
    {
        $record = $this->find($id);

        if (!$record) {
            return false;
        }

        return $record->delete();
    }

    public function with(array $relations): self
    {
        $this->query = $this->query->with($relations);
        return $this;
    }

    public function orderBy(string $column, string $direction = 'asc'): self
    {
        $this->query = $this->query->orderBy($column, $direction);
        return $this;
    }

    protected function resetQuery(): void
    {
        $this->query = $this->model->newQuery();
    }
}
