<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PaymentResource\Pages;
use App\Models\Payment;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class PaymentResource extends Resource
{
    protected static ?string $model = Payment::class;

    protected static ?string $navigationIcon = 'heroicon-o-banknotes';

    protected static ?string $navigationGroup = 'Financeiro';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informações do Pagamento')
                    ->schema([
                        Forms\Components\TextInput::make('payment_number')
                            ->label('Número do Pagamento')
                            ->disabled()
                            ->dehydrated(false),

                        Forms\Components\Select::make('ride_id')
                            ->label('Corrida')
                            ->relationship('ride', 'ride_number')
                            ->searchable()
                            ->preload()
                            ->required(),

                        Forms\Components\Select::make('user_id')
                            ->label('Usuário')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),

                        Forms\Components\Select::make('payment_type')
                            ->label('Tipo de Pagamento')
                            ->options([
                                'pix' => 'PIX',
                                'credit_card' => 'Cartão de Crédito',
                                'debit_card' => 'Cartão de Débito',
                                'cash' => 'Dinheiro',
                            ])
                            ->required(),

                        Forms\Components\Select::make('status')
                            ->label('Status')
                            ->options([
                                'pending' => 'Pendente',
                                'processing' => 'Processando',
                                'completed' => 'Concluído',
                                'failed' => 'Falhou',
                                'refunded' => 'Reembolsado',
                            ])
                            ->required(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Valores')
                    ->schema([
                        Forms\Components\TextInput::make('amount')
                            ->label('Valor Total')
                            ->numeric()
                            ->prefix('R$')
                            ->required(),

                        Forms\Components\TextInput::make('platform_fee')
                            ->label('Taxa da Plataforma')
                            ->numeric()
                            ->prefix('R$'),

                        Forms\Components\TextInput::make('driver_amount')
                            ->label('Valor do Motorista')
                            ->numeric()
                            ->prefix('R$'),

                        Forms\Components\TextInput::make('refund_amount')
                            ->label('Valor Reembolsado')
                            ->numeric()
                            ->prefix('R$'),
                    ])
                    ->columns(4),

                Forms\Components\Section::make('Gateway de Pagamento')
                    ->schema([
                        Forms\Components\TextInput::make('gateway')
                            ->label('Gateway')
                            ->default('mercadopago'),

                        Forms\Components\TextInput::make('gateway_payment_id')
                            ->label('ID do Pagamento no Gateway'),

                        Forms\Components\TextInput::make('gateway_transaction_id')
                            ->label('ID da Transação'),
                    ])
                    ->columns(3)
                    ->collapsible(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('payment_number')
                    ->label('Número')
                    ->searchable()
                    ->sortable()
                    ->copyable(),

                Tables\Columns\TextColumn::make('ride.ride_number')
                    ->label('Corrida')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('Cliente')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('payment_type')
                    ->label('Tipo')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pix' => 'PIX',
                        'credit_card' => 'Crédito',
                        'debit_card' => 'Débito',
                        'cash' => 'Dinheiro',
                        default => $state,
                    }),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('Status')
                    ->colors([
                        'warning' => 'pending',
                        'info' => 'processing',
                        'success' => 'completed',
                        'danger' => 'failed',
                        'gray' => 'refunded',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'Pendente',
                        'processing' => 'Processando',
                        'completed' => 'Concluído',
                        'failed' => 'Falhou',
                        'refunded' => 'Reembolsado',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('amount')
                    ->label('Valor')
                    ->money('BRL')
                    ->sortable(),

                Tables\Columns\TextColumn::make('platform_fee')
                    ->label('Taxa')
                    ->money('BRL')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('driver_amount')
                    ->label('Motorista')
                    ->money('BRL')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Data')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'pending' => 'Pendente',
                        'processing' => 'Processando',
                        'completed' => 'Concluído',
                        'failed' => 'Falhou',
                        'refunded' => 'Reembolsado',
                    ]),

                Tables\Filters\SelectFilter::make('payment_type')
                    ->label('Tipo')
                    ->options([
                        'pix' => 'PIX',
                        'credit_card' => 'Cartão de Crédito',
                        'debit_card' => 'Cartão de Débito',
                        'cash' => 'Dinheiro',
                    ]),

                Tables\Filters\Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('created_from')
                            ->label('De'),
                        Forms\Components\DatePicker::make('created_until')
                            ->label('Até'),
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
            'index' => Pages\ListPayments::route('/'),
            'create' => Pages\CreatePayment::route('/create'),
            'edit' => Pages\EditPayment::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'pending')->count();
    }
}
