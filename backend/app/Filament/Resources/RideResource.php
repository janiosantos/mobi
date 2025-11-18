<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RideResource\Pages;
use App\Models\Ride;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class RideResource extends Resource
{
    protected static ?string $model = Ride::class;

    protected static ?string $navigationIcon = 'heroicon-o-map';

    protected static ?string $navigationGroup = 'Corridas';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informações da Corrida')
                    ->schema([
                        Forms\Components\TextInput::make('ride_number')
                            ->label('Número da Corrida')
                            ->disabled()
                            ->dehydrated(false),

                        Forms\Components\Select::make('passenger_id')
                            ->label('Passageiro')
                            ->relationship('passenger', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),

                        Forms\Components\Select::make('driver_id')
                            ->label('Motorista')
                            ->relationship('driver', 'name')
                            ->searchable()
                            ->preload(),

                        Forms\Components\Select::make('vehicle_category_id')
                            ->label('Categoria do Veículo')
                            ->relationship('category', 'name')
                            ->required(),

                        Forms\Components\Select::make('status')
                            ->label('Status')
                            ->options([
                                'searching' => 'Procurando Motorista',
                                'accepted' => 'Aceito',
                                'arrived' => 'Motorista Chegou',
                                'in_progress' => 'Em Andamento',
                                'completed' => 'Concluída',
                                'cancelled' => 'Cancelada',
                                'no_driver_found' => 'Sem Motorista',
                            ])
                            ->required(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Localização')
                    ->schema([
                        Forms\Components\TextInput::make('pickup_address')
                            ->label('Endereço de Partida')
                            ->required()
                            ->columnSpan(2),

                        Forms\Components\TextInput::make('pickup_latitude')
                            ->label('Latitude Partida')
                            ->numeric()
                            ->required(),

                        Forms\Components\TextInput::make('pickup_longitude')
                            ->label('Longitude Partida')
                            ->numeric()
                            ->required(),

                        Forms\Components\TextInput::make('dropoff_address')
                            ->label('Endereço de Destino')
                            ->required()
                            ->columnSpan(2),

                        Forms\Components\TextInput::make('dropoff_latitude')
                            ->label('Latitude Destino')
                            ->numeric()
                            ->required(),

                        Forms\Components\TextInput::make('dropoff_longitude')
                            ->label('Longitude Destino')
                            ->numeric()
                            ->required(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Valores')
                    ->schema([
                        Forms\Components\TextInput::make('estimated_price')
                            ->label('Preço Estimado')
                            ->numeric()
                            ->prefix('R$')
                            ->required(),

                        Forms\Components\TextInput::make('final_price')
                            ->label('Preço Final')
                            ->numeric()
                            ->prefix('R$'),

                        Forms\Components\TextInput::make('platform_fee')
                            ->label('Taxa da Plataforma')
                            ->numeric()
                            ->prefix('R$'),

                        Forms\Components\TextInput::make('driver_earnings')
                            ->label('Ganhos do Motorista')
                            ->numeric()
                            ->prefix('R$'),
                    ])
                    ->columns(4),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('ride_number')
                    ->label('Número')
                    ->searchable()
                    ->sortable()
                    ->copyable(),

                Tables\Columns\TextColumn::make('passenger.name')
                    ->label('Passageiro')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('driver.name')
                    ->label('Motorista')
                    ->searchable()
                    ->sortable()
                    ->default('N/A'),

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
                    ->label('Partida')
                    ->limit(30)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('dropoff_address')
                    ->label('Destino')
                    ->limit(30)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('estimated_price')
                    ->label('Estimado')
                    ->money('BRL')
                    ->sortable(),

                Tables\Columns\TextColumn::make('final_price')
                    ->label('Final')
                    ->money('BRL')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Criada em')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'searching' => 'Procurando',
                        'accepted' => 'Aceito',
                        'arrived' => 'Chegou',
                        'in_progress' => 'Em Andamento',
                        'completed' => 'Concluída',
                        'cancelled' => 'Cancelada',
                    ]),

                Tables\Filters\Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('created_from')
                            ->label('Criada a partir de'),
                        Forms\Components\DatePicker::make('created_until')
                            ->label('Criada até'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['created_from'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date),
                            )
                            ->when(
                                $data['created_until'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRides::route('/'),
            'create' => Pages\CreateRide::route('/create'),
            'edit' => Pages\EditRide::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'searching')->count();
    }
}
