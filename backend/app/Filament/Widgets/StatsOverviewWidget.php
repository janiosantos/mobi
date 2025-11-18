<?php

namespace App\Filament\Widgets;

use App\Models\Ride;
use App\Models\User;
use App\Models\Payment;
use App\Models\DriverProfile;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Number;

class StatsOverviewWidget extends BaseWidget
{
    protected function getStats(): array
    {
        $totalRevenue = Payment::where('status', 'completed')->sum('amount');
        $todayRevenue = Payment::where('status', 'completed')
            ->whereDate('created_at', today())
            ->sum('amount');

        $totalRides = Ride::count();
        $todayRides = Ride::whereDate('created_at', today())->count();

        $activeDrivers = DriverProfile::where('is_online', true)->count();
        $totalDrivers = User::where('user_type', 'driver')->count();

        $activeRides = Ride::whereIn('status', ['searching', 'accepted', 'arrived', 'in_progress'])->count();

        return [
            Stat::make('Receita Total', 'R$ ' . Number::format($totalRevenue, precision: 2))
                ->description('Hoje: R$ ' . Number::format($todayRevenue, precision: 2))
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success')
                ->chart([7, 12, 8, 15, 20, 18, 25]),

            Stat::make('Corridas Totais', Number::format($totalRides))
                ->description('Hoje: ' . $todayRides . ' corridas')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('info')
                ->chart([10, 15, 12, 18, 22, 20, 25]),

            Stat::make('Motoristas Online', $activeDrivers . ' de ' . $totalDrivers)
                ->description('Taxa de atividade: ' . ($totalDrivers > 0 ? round(($activeDrivers / $totalDrivers) * 100, 1) : 0) . '%')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('warning')
                ->chart([5, 8, 6, 10, 12, 9, $activeDrivers]),

            Stat::make('Corridas Ativas', $activeRides)
                ->description('Em andamento agora')
                ->descriptionIcon('heroicon-m-map')
                ->color('primary')
                ->chart([2, 5, 3, 8, 6, 4, $activeRides]),
        ];
    }

    protected static ?int $sort = 0;
}
