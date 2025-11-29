<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\RideResource;
use App\Models\Ride;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestRidesWidget extends BaseWidget
{
    protected static ?int $sort = 3;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Ride::query()
                    ->latest()
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('ride_number')
                    ->label('Número')
                    ->searchable()
                    ->copyable(),

                Tables\Columns\TextColumn::make('passenger.name')
                    ->label('Passageiro')
                    ->searchable()
                    ->limit(20),

                Tables\Columns\TextColumn::make('driver.name')
                    ->label('Motorista')
                    ->searchable()
                    ->limit(20)
                    ->default('Aguardando...'),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('Status')
                    ->colors([
                        'warning' => 'searching',
                        'info' => 'accepted',
                        'primary' => 'arrived',
                        'success' => ['in_progress', 'completed'],
                        'danger' => ['cancelled', 'no_driver_found'],
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'searching' => 'Procurando',
                        'accepted' => 'Aceito',
                        'arrived' => 'Chegou',
                        'in_progress' => 'Em Andamento',
                        'completed' => 'Concluída',
                        'cancelled' => 'Cancelada',
                        'no_driver_found' => 'Sem Motorista',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('pickup_address')
                    ->label('Origem')
                    ->limit(30)
                    ->tooltip(fn (Ride $record): string => $record->pickup_address),

                Tables\Columns\TextColumn::make('final_price')
                    ->label('Valor')
                    ->money('BRL')
                    ->default(fn (Ride $record) => $record->estimated_price)
                    ->formatStateUsing(fn ($state, Ride $record) =>
                        $record->final_price
                            ? 'R$ ' . number_format($record->final_price, 2, ',', '.')
                            : 'R$ ' . number_format($record->estimated_price, 2, ',', '.')
                    ),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Criada')
                    ->dateTime('d/m H:i')
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('Ver')
                    ->icon('heroicon-o-eye')
                    ->url(fn (Ride $record): string => RideResource::getUrl('edit', ['record' => $record])),
            ]);
    }

    protected function getTableHeading(): string
    {
        return 'Últimas Corridas';
    }
}
