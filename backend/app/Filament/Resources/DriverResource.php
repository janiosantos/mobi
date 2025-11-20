<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DriverResource\Pages;
use App\Models\DriverProfile;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;

class DriverResource extends Resource
{
    protected static ?string $model = DriverProfile::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-circle';

    protected static ?string $navigationGroup = 'Gerenciamento de Motoristas';

    protected static ?string $navigationLabel = 'Motoristas';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informações do Motorista')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('Usuário')
                            ->relationship('user', 'name', fn (Builder $query) => $query->where('user_type', 'driver'))
                            ->searchable()
                            ->preload()
                            ->required()
                            ->createOptionForm([
                                Forms\Components\TextInput::make('name')
                                    ->required(),
                                Forms\Components\TextInput::make('email')
                                    ->email()
                                    ->required(),
                                Forms\Components\TextInput::make('phone')
                                    ->tel(),
                            ]),

                        Forms\Components\TextInput::make('license_number')
                            ->label('Número da CNH')
                            ->required()
                            ->maxLength(20),

                        Forms\Components\DatePicker::make('license_expiry')
                            ->label('Validade da CNH')
                            ->required()
                            ->minDate(now()),

                        Forms\Components\Select::make('license_category')
                            ->label('Categoria da CNH')
                            ->options([
                                'A' => 'A',
                                'B' => 'B',
                                'AB' => 'AB',
                                'C' => 'C',
                                'D' => 'D',
                                'E' => 'E',
                            ])
                            ->required(),

                        Forms\Components\Select::make('approval_status')
                            ->label('Status de Aprovação')
                            ->options([
                                'pending' => 'Pendente',
                                'approved' => 'Aprovado',
                                'rejected' => 'Rejeitado',
                                'suspended' => 'Suspenso',
                            ])
                            ->required()
                            ->default('pending'),

                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Motivo da Rejeição')
                            ->columnSpan(2)
                            ->visible(fn (Forms\Get $get) => $get('approval_status') === 'rejected'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Estatísticas')
                    ->schema([
                        Forms\Components\TextInput::make('total_rides')
                            ->label('Total de Corridas')
                            ->numeric()
                            ->default(0)
                            ->disabled(),

                        Forms\Components\TextInput::make('completed_rides')
                            ->label('Corridas Completas')
                            ->numeric()
                            ->default(0)
                            ->disabled(),

                        Forms\Components\TextInput::make('cancelled_rides')
                            ->label('Corridas Canceladas')
                            ->numeric()
                            ->default(0)
                            ->disabled(),

                        Forms\Components\TextInput::make('average_rating')
                            ->label('Avaliação Média')
                            ->numeric()
                            ->disabled()
                            ->suffix('⭐'),

                        Forms\Components\TextInput::make('total_earnings')
                            ->label('Ganhos Totais')
                            ->numeric()
                            ->prefix('R$')
                            ->disabled(),

                        Forms\Components\TextInput::make('available_balance')
                            ->label('Saldo Disponível')
                            ->numeric()
                            ->prefix('R$')
                            ->disabled(),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Forms\Components\Section::make('Status')
                    ->schema([
                        Forms\Components\Toggle::make('is_online')
                            ->label('Online')
                            ->default(false)
                            ->disabled(),

                        Forms\Components\Toggle::make('is_available')
                            ->label('Disponível')
                            ->default(true),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('Nome')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.email')
                    ->label('E-mail')
                    ->searchable()
                    ->copyable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('user.phone')
                    ->label('Telefone')
                    ->searchable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('license_number')
                    ->label('CNH')
                    ->searchable()
                    ->toggleable(),

                Tables\Columns\BadgeColumn::make('approval_status')
                    ->label('Status')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'approved',
                        'danger' => 'rejected',
                        'gray' => 'suspended',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'Pendente',
                        'approved' => 'Aprovado',
                        'rejected' => 'Rejeitado',
                        'suspended' => 'Suspenso',
                        default => $state,
                    }),

                Tables\Columns\IconColumn::make('is_online')
                    ->label('Online')
                    ->boolean()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('average_rating')
                    ->label('Avaliação')
                    ->sortable()
                    ->formatStateUsing(fn ($state) => $state ? number_format($state, 1) . ' ⭐' : 'N/A')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('total_rides')
                    ->label('Corridas')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('total_earnings')
                    ->label('Ganhos')
                    ->money('BRL')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Cadastrado em')
                    ->dateTime('d/m/Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('approval_status')
                    ->label('Status de Aprovação')
                    ->options([
                        'pending' => 'Pendente',
                        'approved' => 'Aprovado',
                        'rejected' => 'Rejeitado',
                        'suspended' => 'Suspenso',
                    ]),

                Tables\Filters\TernaryFilter::make('is_online')
                    ->label('Online'),

                Tables\Filters\TernaryFilter::make('is_available')
                    ->label('Disponível'),

                Tables\Filters\Filter::make('high_rating')
                    ->label('Alta Avaliação (4.5+)')
                    ->query(fn (Builder $query): Builder => $query->where('average_rating', '>=', 4.5)),

                Tables\Filters\Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('created_from')
                            ->label('Cadastrado a partir de'),
                        Forms\Components\DatePicker::make('created_until')
                            ->label('Cadastrado até'),
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
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),

                    Tables\Actions\Action::make('approve')
                        ->label('Aprovar')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->visible(fn (DriverProfile $record) => $record->approval_status === 'pending')
                        ->action(function (DriverProfile $record) {
                            $record->update([
                                'approval_status' => 'approved',
                                'approved_by' => auth()->id(),
                                'approved_at' => now(),
                            ]);

                            Notification::make()
                                ->title('Motorista aprovado com sucesso!')
                                ->success()
                                ->send();
                        }),

                    Tables\Actions\Action::make('reject')
                        ->label('Rejeitar')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->form([
                            Forms\Components\Textarea::make('rejection_reason')
                                ->label('Motivo da Rejeição')
                                ->required(),
                        ])
                        ->visible(fn (DriverProfile $record) => $record->approval_status === 'pending')
                        ->action(function (DriverProfile $record, array $data) {
                            $record->update([
                                'approval_status' => 'rejected',
                                'rejection_reason' => $data['rejection_reason'],
                            ]);

                            Notification::make()
                                ->title('Motorista rejeitado')
                                ->warning()
                                ->send();
                        }),

                    Tables\Actions\Action::make('suspend')
                        ->label('Suspender')
                        ->icon('heroicon-o-no-symbol')
                        ->color('warning')
                        ->requiresConfirmation()
                        ->visible(fn (DriverProfile $record) => $record->approval_status === 'approved')
                        ->action(function (DriverProfile $record) {
                            $record->update(['approval_status' => 'suspended']);

                            Notification::make()
                                ->title('Motorista suspenso')
                                ->warning()
                                ->send();
                        }),

                    Tables\Actions\Action::make('activate')
                        ->label('Reativar')
                        ->icon('heroicon-o-check-badge')
                        ->color('success')
                        ->requiresConfirmation()
                        ->visible(fn (DriverProfile $record) => $record->approval_status === 'suspended')
                        ->action(function (DriverProfile $record) {
                            $record->update(['approval_status' => 'approved']);

                            Notification::make()
                                ->title('Motorista reativado')
                                ->success()
                                ->send();
                        }),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('approve_bulk')
                        ->label('Aprovar Selecionados')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(function ($records) {
                            $records->each(function ($record) {
                                if ($record->approval_status === 'pending') {
                                    $record->update([
                                        'approval_status' => 'approved',
                                        'approved_by' => auth()->id(),
                                        'approved_at' => now(),
                                    ]);
                                }
                            });

                            Notification::make()
                                ->title('Motoristas aprovados em lote')
                                ->success()
                                ->send();
                        }),

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
            'index' => Pages\ListDrivers::route('/'),
            'create' => Pages\CreateDriver::route('/create'),
            'edit' => Pages\EditDriver::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with('user');
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('approval_status', 'pending')->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        $count = static::getModel()::where('approval_status', 'pending')->count();
        return $count > 0 ? 'warning' : 'success';
    }
}
