<?php

namespace App\Filament\Widgets;

use App\Models\Ride;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Carbon;

class RidesChartWidget extends ChartWidget
{
    protected static ?string $heading = 'Corridas nos Últimos 7 Dias';

    protected static ?int $sort = 1;

    protected function getData(): array
    {
        $data = [];
        $labels = [];

        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i);
            $labels[] = $date->format('d/m');

            $completedRides = Ride::whereDate('created_at', $date)
                ->where('status', 'completed')
                ->count();

            $cancelledRides = Ride::whereDate('created_at', $date)
                ->where('status', 'cancelled')
                ->count();

            $data['completed'][] = $completedRides;
            $data['cancelled'][] = $cancelledRides;
        }

        return [
            'datasets' => [
                [
                    'label' => 'Concluídas',
                    'data' => $data['completed'],
                    'backgroundColor' => 'rgba(34, 197, 94, 0.2)',
                    'borderColor' => 'rgb(34, 197, 94)',
                    'borderWidth' => 2,
                ],
                [
                    'label' => 'Canceladas',
                    'data' => $data['cancelled'],
                    'backgroundColor' => 'rgba(239, 68, 68, 0.2)',
                    'borderColor' => 'rgb(239, 68, 68)',
                    'borderWidth' => 2,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
