<?php

namespace App\Filament\Resources\RideResource\Pages;

use App\Filament\Resources\RideResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListRides extends ListRecords
{
    protected static string $resource = RideResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('Todas'),
            'searching' => Tab::make('Procurando')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'searching'))
                ->badge(fn () => $this->getModel()::where('status', 'searching')->count()),
            'active' => Tab::make('Ativas')
                ->modifyQueryUsing(fn (Builder $query) => $query->whereIn('status', ['accepted', 'arrived', 'in_progress']))
                ->badge(fn () => $this->getModel()::whereIn('status', ['accepted', 'arrived', 'in_progress'])->count()),
            'completed' => Tab::make('Concluídas')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'completed')),
            'cancelled' => Tab::make('Canceladas')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'cancelled')),
        ];
    }
}
