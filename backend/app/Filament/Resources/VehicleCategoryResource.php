<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VehicleCategoryResource\Pages;
use App\Models\VehicleCategory;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class VehicleCategoryResource extends Resource
{
    protected static ?string $model = VehicleCategory::class;

    protected static ?string $navigationIcon = 'heroicon-o-truck';

    protected static ?string $navigationGroup = 'Configurações';

    protected static ?int $navigationSort = 1;

    protected static ?string $navigationLabel = 'Categorias de Veículos';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informações Básicas')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nome')
                            ->required()
                            ->maxLength(100)
                            ->placeholder('Ex: Economy, Comfort, Premium'),

                        Forms\Components\TextInput::make('code')
                            ->label('Código')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(50)
                            ->alphaDash()
                            ->lowercase()
                            ->placeholder('Ex: economy, comfort'),

                        Forms\Components\Textarea::make('description')
                            ->label('Descrição')
                            ->rows(3)
                            ->maxLength(500)
                            ->columnSpan(2),

                        Forms\Components\FileUpload::make('icon_url')
                            ->label('Ícone')
                            ->image()
                            ->directory('categories')
                            ->maxSize(1024)
                            ->acceptedFileTypes(['image/png', 'image/svg+xml'])
                            ->helperText('PNG ou SVG, máximo 1MB'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Ativo')
                            ->default(true),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Precificação')
                    ->schema([
                        Forms\Components\TextInput::make('base_price')
                            ->label('Preço Base (R$)')
                            ->numeric()
                            ->required()
                            ->minValue(0)
                            ->prefix('R$')
                            ->step(0.01)
                            ->helperText('Valor cobrado ao iniciar a corrida'),

                        Forms\Components\TextInput::make('price_per_km')
                            ->label('Preço por KM (R$)')
                            ->numeric()
                            ->required()
                            ->minValue(0)
                            ->prefix('R$')
                            ->step(0.01)
                            ->helperText('Valor cobrado por quilômetro'),

                        Forms\Components\TextInput::make('price_per_minute')
                            ->label('Preço por Minuto (R$)')
                            ->numeric()
                            ->required()
                            ->minValue(0)
                            ->prefix('R$')
                            ->step(0.01)
                            ->helperText('Valor cobrado por minuto de viagem'),

                        Forms\Components\TextInput::make('minimum_price')
                            ->label('Preço Mínimo (R$)')
                            ->numeric()
                            ->required()
                            ->minValue(0)
                            ->prefix('R$')
                            ->step(0.01)
                            ->helperText('Valor mínimo a ser cobrado'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Características do Veículo')
                    ->schema([
                        Forms\Components\TextInput::make('max_passengers')
                            ->label('Máximo de Passageiros')
                            ->numeric()
                            ->required()
                            ->minValue(1)
                            ->maxValue(10)
                            ->default(4),

                        Forms\Components\KeyValue::make('features')
                            ->label('Características')
                            ->keyLabel('Característica')
                            ->valueLabel('Descrição')
                            ->reorderable()
                            ->addActionLabel('Adicionar Característica')
                            ->helperText('Ex: Ar condicionado, Wi-Fi, Porta-malas grande')
                            ->columnSpan(2),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('icon_url')
                    ->label('Ícone')
                    ->size(40)
                    ->defaultImageUrl('/images/default-category.png'),

                Tables\Columns\TextColumn::make('name')
                    ->label('Nome')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('code')
                    ->label('Código')
                    ->searchable()
                    ->badge()
                    ->color('primary'),

                Tables\Columns\TextColumn::make('base_price')
                    ->label('Preço Base')
                    ->money('BRL')
                    ->sortable(),

                Tables\Columns\TextColumn::make('price_per_km')
                    ->label('Por KM')
                    ->money('BRL')
                    ->sortable(),

                Tables\Columns\TextColumn::make('price_per_minute')
                    ->label('Por Min')
                    ->money('BRL')
                    ->sortable(),

                Tables\Columns\TextColumn::make('minimum_price')
                    ->label('Mínimo')
                    ->money('BRL')
                    ->sortable(),

                Tables\Columns\TextColumn::make('max_passengers')
                    ->label('Passageiros')
                    ->alignCenter()
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Ativo')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\TextColumn::make('rides_count')
                    ->label('Corridas')
                    ->counts('rides')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Criado em')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Ativo'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),

                Tables\Actions\Action::make('toggle_active')
                    ->label(fn (VehicleCategory $record) => $record->is_active ? 'Desativar' : 'Ativar')
                    ->icon(fn (VehicleCategory $record) => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                    ->color(fn (VehicleCategory $record) => $record->is_active ? 'danger' : 'success')
                    ->requiresConfirmation()
                    ->action(fn (VehicleCategory $record) => $record->update([
                        'is_active' => !$record->is_active,
                    ])),
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
            'index' => Pages\ListVehicleCategories::route('/'),
            'create' => Pages\CreateVehicleCategory::route('/create'),
            'edit' => Pages\EditVehicleCategory::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) static::getModel()::where('is_active', true)->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }
}
