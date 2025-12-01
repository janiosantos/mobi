<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CouponResource\Pages;
use App\Models\Coupon;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class CouponResource extends Resource
{
    protected static ?string $model = Coupon::class;

    protected static ?string $navigationIcon = 'heroicon-o-ticket';

    protected static ?string $navigationGroup = 'Marketing';

    protected static ?int $navigationSort = 1;

    protected static ?string $navigationLabel = 'Cupons';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informações do Cupom')
                    ->schema([
                        Forms\Components\TextInput::make('code')
                            ->label('Código')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(50)
                            ->uppercase()
                            ->alphaDash()
                            ->placeholder('Ex: PRIMEIRAVIAGEM'),

                        Forms\Components\Textarea::make('description')
                            ->label('Descrição')
                            ->rows(2)
                            ->maxLength(255)
                            ->columnSpan(2),

                        Forms\Components\Select::make('type')
                            ->label('Tipo')
                            ->options([
                                'percentage' => 'Porcentagem',
                                'fixed' => 'Valor Fixo',
                            ])
                            ->required()
                            ->reactive(),

                        Forms\Components\TextInput::make('value')
                            ->label(fn (Forms\Get $get) => $get('type') === 'percentage' ? 'Porcentagem (%)' : 'Valor (R$)')
                            ->numeric()
                            ->required()
                            ->minValue(0)
                            ->maxValue(fn (Forms\Get $get) => $get('type') === 'percentage' ? 100 : 999999)
                            ->prefix(fn (Forms\Get $get) => $get('type') === 'fixed' ? 'R$' : '')
                            ->suffix(fn (Forms\Get $get) => $get('type') === 'percentage' ? '%' : ''),

                        Forms\Components\TextInput::make('max_discount')
                            ->label('Desconto Máximo (R$)')
                            ->numeric()
                            ->minValue(0)
                            ->prefix('R$')
                            ->helperText('Deixe em branco para sem limite')
                            ->visible(fn (Forms\Get $get) => $get('type') === 'percentage'),

                        Forms\Components\TextInput::make('min_ride_value')
                            ->label('Valor Mínimo da Corrida (R$)')
                            ->numeric()
                            ->minValue(0)
                            ->prefix('R$')
                            ->helperText('Deixe em branco para sem mínimo'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Limites de Uso')
                    ->schema([
                        Forms\Components\TextInput::make('max_uses')
                            ->label('Máximo de Usos Totais')
                            ->numeric()
                            ->minValue(1)
                            ->helperText('Deixe em branco para uso ilimitado'),

                        Forms\Components\TextInput::make('max_uses_per_user')
                            ->label('Máximo de Usos por Usuário')
                            ->numeric()
                            ->minValue(1)
                            ->default(1),

                        Forms\Components\TextInput::make('uses_count')
                            ->label('Usos Atuais')
                            ->numeric()
                            ->disabled()
                            ->dehydrated(false)
                            ->default(0),
                    ])
                    ->columns(3),

                Forms\Components\Section::make('Validade')
                    ->schema([
                        Forms\Components\DateTimePicker::make('valid_from')
                            ->label('Válido a partir de')
                            ->required()
                            ->default(now()),

                        Forms\Components\DateTimePicker::make('valid_until')
                            ->label('Válido até')
                            ->required()
                            ->after('valid_from'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Ativo')
                            ->default(true)
                            ->helperText('Desative para pausar o cupom sem excluí-lo'),
                    ])
                    ->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('Código')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->copyable(),

                Tables\Columns\TextColumn::make('description')
                    ->label('Descrição')
                    ->limit(40)
                    ->toggleable(),

                Tables\Columns\BadgeColumn::make('type')
                    ->label('Tipo')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'percentage' => 'Porcentagem',
                        'fixed' => 'Valor Fixo',
                        default => $state,
                    })
                    ->colors([
                        'primary' => 'percentage',
                        'success' => 'fixed',
                    ]),

                Tables\Columns\TextColumn::make('value')
                    ->label('Valor')
                    ->formatStateUsing(function (Coupon $record): string {
                        if ($record->type === 'percentage') {
                            return $record->value . '%';
                        }
                        return 'R$ ' . number_format($record->value, 2, ',', '.');
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('uses_count')
                    ->label('Usos')
                    ->formatStateUsing(function (Coupon $record): string {
                        $current = $record->uses_count;
                        $max = $record->max_uses ?? '∞';
                        return "$current / $max";
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('valid_until')
                    ->label('Válido até')
                    ->date('d/m/Y')
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Ativo')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('Status')
                    ->getStateUsing(function (Coupon $record): string {
                        if (!$record->is_active) {
                            return 'inactive';
                        }
                        if ($record->valid_until->isPast()) {
                            return 'expired';
                        }
                        if ($record->valid_from->isFuture()) {
                            return 'scheduled';
                        }
                        if ($record->max_uses && $record->uses_count >= $record->max_uses) {
                            return 'depleted';
                        }
                        return 'active';
                    })
                    ->colors([
                        'success' => 'active',
                        'warning' => 'scheduled',
                        'danger' => ['expired', 'depleted'],
                        'secondary' => 'inactive',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'Ativo',
                        'scheduled' => 'Agendado',
                        'expired' => 'Expirado',
                        'depleted' => 'Esgotado',
                        'inactive' => 'Inativo',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Criado em')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Tipo')
                    ->options([
                        'percentage' => 'Porcentagem',
                        'fixed' => 'Valor Fixo',
                    ]),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Ativo'),

                Tables\Filters\Filter::make('expired')
                    ->label('Apenas Expirados')
                    ->query(fn (Builder $query) => $query->where('valid_until', '<', now())),

                Tables\Filters\Filter::make('active_now')
                    ->label('Apenas Ativos Agora')
                    ->query(fn (Builder $query) => $query
                        ->where('is_active', true)
                        ->where('valid_from', '<=', now())
                        ->where('valid_until', '>=', now())
                    ),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),

                Tables\Actions\Action::make('toggle_active')
                    ->label(fn (Coupon $record) => $record->is_active ? 'Desativar' : 'Ativar')
                    ->icon(fn (Coupon $record) => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                    ->color(fn (Coupon $record) => $record->is_active ? 'danger' : 'success')
                    ->requiresConfirmation()
                    ->action(fn (Coupon $record) => $record->update([
                        'is_active' => !$record->is_active,
                    ])),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),

                    Tables\Actions\BulkAction::make('activate')
                        ->label('Ativar Selecionados')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_active' => true])),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Desativar Selecionados')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(fn ($records) => $records->each->update(['is_active' => false])),
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
            'index' => Pages\ListCoupons::route('/'),
            'create' => Pages\CreateCoupon::route('/create'),
            'edit' => Pages\EditCoupon::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $active = static::getModel()::where('is_active', true)
            ->where('valid_from', '<=', now())
            ->where('valid_until', '>=', now())
            ->count();

        return $active > 0 ? (string) $active : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }
}
