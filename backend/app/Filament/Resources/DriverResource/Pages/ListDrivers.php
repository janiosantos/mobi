<?php

namespace App\Filament\Resources\DriverResource\Pages;

use App\Filament\Resources\DriverResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListDrivers extends ListRecords
{
    protected static string $resource = DriverResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('Todos')
                ->badge(fn () => \App\Models\DriverProfile::count()),

            'pending' => Tab::make('Pendentes')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('approval_status', 'pending'))
                ->badge(fn () => \App\Models\DriverProfile::where('approval_status', 'pending')->count())
                ->badgeColor('warning'),

            'approved' => Tab::make('Aprovados')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('approval_status', 'approved'))
                ->badge(fn () => \App\Models\DriverProfile::where('approval_status', 'approved')->count())
                ->badgeColor('success'),

            'rejected' => Tab::make('Rejeitados')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('approval_status', 'rejected'))
                ->badge(fn () => \App\Models\DriverProfile::where('approval_status', 'rejected')->count())
                ->badgeColor('danger'),

            'suspended' => Tab::make('Suspensos')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('approval_status', 'suspended'))
                ->badge(fn () => \App\Models\DriverProfile::where('approval_status', 'suspended')->count())
                ->badgeColor('gray'),

            'online' => Tab::make('Online')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_online', true))
                ->badge(fn () => \App\Models\DriverProfile::where('is_online', true)->count())
                ->badgeColor('primary'),
        ];
    }
}
