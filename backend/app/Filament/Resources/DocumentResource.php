<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DocumentResource\Pages;
use App\Models\Document;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class DocumentResource extends Resource
{
    protected static ?string $model = Document::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-text';

    protected static ?string $navigationGroup = 'Motoristas';

    protected static ?int $navigationSort = 2;

    protected static ?string $navigationLabel = 'Documentos';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informações do Documento')
                    ->schema([
                        Forms\Components\Select::make('driver_profile_id')
                            ->label('Motorista')
                            ->relationship('driverProfile.user', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),

                        Forms\Components\Select::make('type')
                            ->label('Tipo de Documento')
                            ->options([
                                'cnh' => 'CNH (Carteira Nacional de Habilitação)',
                                'vehicle_registration' => 'CRLV (Documento do Veículo)',
                                'insurance' => 'Seguro do Veículo',
                                'background_check' => 'Antecedentes Criminais',
                                'photo' => 'Foto de Perfil',
                            ])
                            ->required(),

                        Forms\Components\FileUpload::make('file_url')
                            ->label('Arquivo')
                            ->image()
                            ->directory('documents')
                            ->visibility('private')
                            ->maxSize(5120) // 5MB
                            ->acceptedFileTypes(['image/*', 'application/pdf'])
                            ->required(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Aprovação')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Status')
                            ->options([
                                'pending' => 'Pendente',
                                'approved' => 'Aprovado',
                                'rejected' => 'Rejeitado',
                            ])
                            ->required()
                            ->default('pending'),

                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Motivo da Rejeição')
                            ->rows(3)
                            ->columnSpan(2)
                            ->visible(fn (Forms\Get $get) => $get('status') === 'rejected'),

                        Forms\Components\Select::make('reviewed_by')
                            ->label('Revisado por')
                            ->relationship('reviewer', 'name')
                            ->searchable()
                            ->disabled()
                            ->dehydrated(false),

                        Forms\Components\DateTimePicker::make('reviewed_at')
                            ->label('Data da Revisão')
                            ->disabled()
                            ->dehydrated(false),
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

                Tables\Columns\TextColumn::make('driverProfile.user.name')
                    ->label('Motorista')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\BadgeColumn::make('type')
                    ->label('Tipo')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'cnh' => 'CNH',
                        'vehicle_registration' => 'CRLV',
                        'insurance' => 'Seguro',
                        'background_check' => 'Antecedentes',
                        'photo' => 'Foto',
                        default => $state,
                    })
                    ->colors([
                        'primary' => 'cnh',
                        'success' => 'vehicle_registration',
                        'warning' => 'insurance',
                        'info' => 'background_check',
                        'secondary' => 'photo',
                    ]),

                Tables\Columns\ImageColumn::make('file_url')
                    ->label('Arquivo')
                    ->disk('private')
                    ->size(50),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('Status')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'approved',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'Pendente',
                        'approved' => 'Aprovado',
                        'rejected' => 'Rejeitado',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('reviewer.name')
                    ->label('Revisado por')
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('reviewed_at')
                    ->label('Data Revisão')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Enviado em')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Tipo de Documento')
                    ->options([
                        'cnh' => 'CNH',
                        'vehicle_registration' => 'CRLV',
                        'insurance' => 'Seguro',
                        'background_check' => 'Antecedentes',
                        'photo' => 'Foto',
                    ]),

                Tables\Filters\SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'pending' => 'Pendente',
                        'approved' => 'Aprovado',
                        'rejected' => 'Rejeitado',
                    ]),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('Aprovar')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->visible(fn (Document $record) => $record->status === 'pending')
                    ->action(function (Document $record) {
                        $record->update([
                            'status' => 'approved',
                            'reviewed_by' => auth()->id(),
                            'reviewed_at' => now(),
                        ]);
                    }),

                Tables\Actions\Action::make('reject')
                    ->label('Rejeitar')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Motivo da Rejeição')
                            ->required()
                            ->rows(3),
                    ])
                    ->visible(fn (Document $record) => $record->status === 'pending')
                    ->action(function (Document $record, array $data) {
                        $record->update([
                            'status' => 'rejected',
                            'rejection_reason' => $data['rejection_reason'],
                            'reviewed_by' => auth()->id(),
                            'reviewed_at' => now(),
                        ]);
                    }),

                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),

                    Tables\Actions\BulkAction::make('approve_selected')
                        ->label('Aprovar Selecionados')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(function ($records) {
                            $records->each(function (Document $record) {
                                if ($record->status === 'pending') {
                                    $record->update([
                                        'status' => 'approved',
                                        'reviewed_by' => auth()->id(),
                                        'reviewed_at' => now(),
                                    ]);
                                }
                            });
                        }),
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
            'index' => Pages\ListDocuments::route('/'),
            'create' => Pages\CreateDocument::route('/create'),
            'edit' => Pages\EditDocument::route('/{record}/edit'),
            'view' => Pages\ViewDocument::route('/{record}'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['driverProfile.user', 'reviewer']);
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'pending')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }
}
