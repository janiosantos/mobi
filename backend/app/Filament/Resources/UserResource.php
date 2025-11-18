<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationGroup = 'Gerenciamento de Usuários';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informações Pessoais')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nome')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('email')
                            ->label('E-mail')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),

                        Forms\Components\TextInput::make('phone')
                            ->label('Telefone')
                            ->tel()
                            ->maxLength(20),

                        Forms\Components\Select::make('user_type')
                            ->label('Tipo de Usuário')
                            ->options([
                                'passenger' => 'Passageiro',
                                'driver' => 'Motorista',
                                'admin' => 'Administrador',
                            ])
                            ->required(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Documentação')
                    ->schema([
                        Forms\Components\TextInput::make('cpf')
                            ->label('CPF')
                            ->maxLength(14),

                        Forms\Components\DatePicker::make('birth_date')
                            ->label('Data de Nascimento')
                            ->maxDate(now()->subYears(18)),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Acesso')
                    ->schema([
                        Forms\Components\TextInput::make('password')
                            ->label('Senha')
                            ->password()
                            ->dehydrateStateUsing(fn ($state) => filled($state) ? bcrypt($state) : null)
                            ->dehydrated(fn ($state) => filled($state))
                            ->required(fn (string $context): bool => $context === 'create'),

                        Forms\Components\Toggle::make('is_verified')
                            ->label('E-mail Verificado')
                            ->default(false),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Ativo')
                            ->default(true),
                    ])
                    ->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('name')
                    ->label('Nome')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('email')
                    ->label('E-mail')
                    ->searchable()
                    ->sortable()
                    ->copyable(),

                Tables\Columns\TextColumn::make('phone')
                    ->label('Telefone')
                    ->searchable(),

                Tables\Columns\BadgeColumn::make('user_type')
                    ->label('Tipo')
                    ->colors([
                        'primary' => 'passenger',
                        'success' => 'driver',
                        'danger' => 'admin',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'passenger' => 'Passageiro',
                        'driver' => 'Motorista',
                        'admin' => 'Administrador',
                        default => $state,
                    }),

                Tables\Columns\IconColumn::make('is_verified')
                    ->label('Verificado')
                    ->boolean(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Ativo')
                    ->boolean(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Criado em')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('user_type')
                    ->label('Tipo de Usuário')
                    ->options([
                        'passenger' => 'Passageiro',
                        'driver' => 'Motorista',
                        'admin' => 'Administrador',
                    ]),

                Tables\Filters\TernaryFilter::make('is_verified')
                    ->label('E-mail Verificado'),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Ativo'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
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
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->withoutGlobalScopes();
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
}
