<?php

namespace App\Filament\Widgets;

use App\Models\Payment;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Carbon;

class RevenueChartWidget extends ChartWidget
{
    protected static ?string $heading = 'Receita nos Últimos 7 Dias';

    protected static ?int $sort = 2;

    protected function getData(): array
    {
        $data = [];
        $labels = [];

        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i);
            $labels[] = $date->format('d/m');

            $revenue = Payment::whereDate('created_at', $date)
                ->where('status', 'completed')
                ->sum('amount');

            $platformFees = Payment::whereDate('created_at', $date)
                ->where('status', 'completed')
                ->sum('platform_fee');

            $data['revenue'][] = round($revenue, 2);
            $data['platform_fees'][] = round($platformFees, 2);
        }

        return [
            'datasets' => [
                [
                    'label' => 'Receita Total (R$)',
                    'data' => $data['revenue'],
                    'backgroundColor' => 'rgba(59, 130, 246, 0.2)',
                    'borderColor' => 'rgb(59, 130, 246)',
                    'borderWidth' => 2,
                ],
                [
                    'label' => 'Taxa da Plataforma (R$)',
                    'data' => $data['platform_fees'],
                    'backgroundColor' => 'rgba(168, 85, 247, 0.2)',
                    'borderColor' => 'rgb(168, 85, 247)',
                    'borderWidth' => 2,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
