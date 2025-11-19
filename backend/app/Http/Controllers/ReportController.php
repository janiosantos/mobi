<?php

namespace App\Http\Controllers;

use App\Models\Ride;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    /**
     * Get ride history with filters.
     */
    public function rideHistory(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Ride::query();

        // Filter by user type
        if ($user->isPassenger()) {
            $query->where('passenger_id', $user->id);
        } elseif ($user->isDriver()) {
            $query->where('driver_id', $user->id);
        }

        // Filter by date range
        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->input('start_date'));
        }

        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->input('end_date'));
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->input('status'));
        }

        // Order by most recent
        $rides = $query->with(['passenger', 'driver', 'category'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($rides);
    }

    /**
     * Get spending summary for passengers.
     */
    public function spendingSummary(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->isPassenger()) {
            return response()->json([
                'message' => 'Only passengers can view spending summary'
            ], 403);
        }

        $period = $request->input('period', 'all'); // all, month, week, year

        $query = Ride::where('passenger_id', $user->id)
            ->completed();

        // Apply period filter
        switch ($period) {
            case 'week':
                $query->where('completed_at', '>=', now()->subWeek());
                break;
            case 'month':
                $query->where('completed_at', '>=', now()->subMonth());
                break;
            case 'year':
                $query->where('completed_at', '>=', now()->subYear());
                break;
        }

        $summary = $query->selectRaw('
            COUNT(*) as total_rides,
            SUM(final_price) as total_spent,
            AVG(final_price) as average_price,
            SUM(discount_amount) as total_discounts,
            SUM(tip_amount) as total_tips,
            MIN(final_price) as cheapest_ride,
            MAX(final_price) as most_expensive_ride
        ')->first();

        // Get rides by category
        $byCategory = Ride::where('passenger_id', $user->id)
            ->completed()
            ->when($period !== 'all', function($q) use ($period) {
                switch ($period) {
                    case 'week':
                        $q->where('completed_at', '>=', now()->subWeek());
                        break;
                    case 'month':
                        $q->where('completed_at', '>=', now()->subMonth());
                        break;
                    case 'year':
                        $q->where('completed_at', '>=', now()->subYear());
                        break;
                }
            })
            ->join('vehicle_categories', 'rides.vehicle_category_id', '=', 'vehicle_categories.id')
            ->groupBy('vehicle_categories.id', 'vehicle_categories.name')
            ->selectRaw('
                vehicle_categories.name as category_name,
                COUNT(*) as rides_count,
                SUM(rides.final_price) as total_spent
            ')
            ->get();

        // Get monthly trend (last 6 months)
        $monthlyTrend = Ride::where('passenger_id', $user->id)
            ->completed()
            ->where('completed_at', '>=', now()->subMonths(6))
            ->groupByRaw('YEAR(completed_at), MONTH(completed_at)')
            ->selectRaw('
                YEAR(completed_at) as year,
                MONTH(completed_at) as month,
                COUNT(*) as rides_count,
                SUM(final_price) as total_spent
            ')
            ->orderByRaw('YEAR(completed_at) DESC, MONTH(completed_at) DESC')
            ->get();

        return response()->json([
            'data' => [
                'summary' => $summary,
                'by_category' => $byCategory,
                'monthly_trend' => $monthlyTrend,
                'period' => $period,
            ]
        ]);
    }

    /**
     * Get earnings summary for drivers.
     */
    public function earningsSummary(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->isDriver()) {
            return response()->json([
                'message' => 'Only drivers can view earnings summary'
            ], 403);
        }

        $period = $request->input('period', 'all'); // all, month, week, year

        $query = Ride::where('driver_id', $user->id)
            ->completed();

        // Apply period filter
        switch ($period) {
            case 'week':
                $query->where('completed_at', '>=', now()->subWeek());
                break;
            case 'month':
                $query->where('completed_at', '>=', now()->subMonth());
                break;
            case 'year':
                $query->where('completed_at', '>=', now()->subYear());
                break;
        }

        $summary = $query->selectRaw('
            COUNT(*) as total_rides,
            SUM(driver_earnings) as total_earnings,
            AVG(driver_earnings) as average_earnings,
            SUM(tip_amount) as total_tips,
            SUM(actual_distance) as total_distance_km,
            SUM(actual_duration) as total_duration_minutes
        ')->first();

        // Calculate metrics
        $acceptance_rate = $this->calculateAcceptanceRate($user->id, $period);
        $cancellation_rate = $this->calculateCancellationRate($user->id, $period);

        // Get daily earnings (last 7 days)
        $dailyEarnings = Ride::where('driver_id', $user->id)
            ->completed()
            ->where('completed_at', '>=', now()->subDays(7))
            ->groupByRaw('DATE(completed_at)')
            ->selectRaw('
                DATE(completed_at) as date,
                COUNT(*) as rides_count,
                SUM(driver_earnings) as total_earnings,
                SUM(tip_amount) as total_tips
            ')
            ->orderBy('date', 'desc')
            ->get();

        // Get hourly performance
        $hourlyPerformance = Ride::where('driver_id', $user->id)
            ->completed()
            ->where('completed_at', '>=', now()->subMonth())
            ->groupByRaw('HOUR(completed_at)')
            ->selectRaw('
                HOUR(completed_at) as hour,
                COUNT(*) as rides_count,
                AVG(driver_earnings) as avg_earnings
            ')
            ->orderBy('hour')
            ->get();

        return response()->json([
            'data' => [
                'summary' => $summary,
                'acceptance_rate' => $acceptance_rate,
                'cancellation_rate' => $cancellation_rate,
                'daily_earnings' => $dailyEarnings,
                'hourly_performance' => $hourlyPerformance,
                'period' => $period,
            ]
        ]);
    }

    /**
     * Get user statistics.
     */
    public function userStats(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = [
            'total_rides' => 0,
            'average_rating' => $user->average_rating,
            'total_ratings' => $user->total_ratings,
            'member_since' => $user->created_at,
            'wallet_balance' => $user->wallet_balance,
        ];

        if ($user->isPassenger()) {
            $stats['total_rides'] = Ride::where('passenger_id', $user->id)->completed()->count();
            $stats['total_spent'] = Ride::where('passenger_id', $user->id)
                ->completed()
                ->sum('final_price');
            $stats['total_discounts'] = Ride::where('passenger_id', $user->id)
                ->completed()
                ->sum('discount_amount');
            $stats['favorite_category'] = $this->getFavoriteCategory($user->id);
        }

        if ($user->isDriver()) {
            $stats['total_rides'] = Ride::where('driver_id', $user->id)->completed()->count();
            $stats['total_earnings'] = Ride::where('driver_id', $user->id)
                ->completed()
                ->sum('driver_earnings');
            $stats['total_tips'] = Ride::where('driver_id', $user->id)
                ->completed()
                ->sum('tip_amount');
            $stats['total_distance_km'] = Ride::where('driver_id', $user->id)
                ->completed()
                ->sum('actual_distance');
        }

        return response()->json([
            'data' => $stats
        ]);
    }

    /**
     * Export ride history to CSV.
     */
    public function export(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Ride::query();

        if ($user->isPassenger()) {
            $query->where('passenger_id', $user->id);
        } elseif ($user->isDriver()) {
            $query->where('driver_id', $user->id);
        }

        // Filter by date range
        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->input('start_date'));
        }

        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->input('end_date'));
        }

        $rides = $query->with(['category'])
            ->completed()
            ->orderBy('completed_at', 'desc')
            ->get();

        // Generate CSV data
        $csvData = $this->generateCsvData($rides, $user);

        return response()->json([
            'data' => $csvData,
            'message' => 'Export generated successfully'
        ]);
    }

    /**
     * Calculate driver acceptance rate.
     */
    private function calculateAcceptanceRate(int $driverId, string $period): float
    {
        $query = Ride::where('driver_id', $driverId);

        switch ($period) {
            case 'week':
                $query->where('created_at', '>=', now()->subWeek());
                break;
            case 'month':
                $query->where('created_at', '>=', now()->subMonth());
                break;
            case 'year':
                $query->where('created_at', '>=', now()->subYear());
                break;
        }

        $total = $query->count();
        $accepted = $query->whereNotNull('accepted_at')->count();

        return $total > 0 ? ($accepted / $total) * 100 : 0;
    }

    /**
     * Calculate driver cancellation rate.
     */
    private function calculateCancellationRate(int $driverId, string $period): float
    {
        $query = Ride::where('driver_id', $driverId);

        switch ($period) {
            case 'week':
                $query->where('created_at', '>=', now()->subWeek());
                break;
            case 'month':
                $query->where('created_at', '>=', now()->subMonth());
                break;
            case 'year':
                $query->where('created_at', '>=', now()->subYear());
                break;
        }

        $total = $query->whereNotNull('accepted_at')->count();
        $cancelled = $query->where('status', 'cancelled_by_driver')->count();

        return $total > 0 ? ($cancelled / $total) * 100 : 0;
    }

    /**
     * Get passenger's favorite category.
     */
    private function getFavoriteCategory(int $passengerId): ?array
    {
        $favorite = Ride::where('passenger_id', $passengerId)
            ->completed()
            ->join('vehicle_categories', 'rides.vehicle_category_id', '=', 'vehicle_categories.id')
            ->groupBy('vehicle_categories.id', 'vehicle_categories.name')
            ->selectRaw('
                vehicle_categories.id,
                vehicle_categories.name,
                COUNT(*) as rides_count
            ')
            ->orderBy('rides_count', 'desc')
            ->first();

        return $favorite ? [
            'id' => $favorite->id,
            'name' => $favorite->name,
            'rides_count' => $favorite->rides_count,
        ] : null;
    }

    /**
     * Generate CSV data for export.
     */
    private function generateCsvData($rides, User $user): array
    {
        $data = [];

        // Header
        $header = ['Data', 'Hora', 'Categoria', 'Origem', 'Destino', 'Distância (km)', 'Duração (min)', 'Valor', 'Status'];

        if ($user->isDriver()) {
            $header[] = 'Ganho';
            $header[] = 'Gorjeta';
        }

        $data[] = $header;

        // Rows
        foreach ($rides as $ride) {
            $row = [
                $ride->completed_at?->format('d/m/Y') ?? $ride->created_at->format('d/m/Y'),
                $ride->completed_at?->format('H:i') ?? $ride->created_at->format('H:i'),
                $ride->category?->name ?? 'N/A',
                substr($ride->pickup_address, 0, 50),
                substr($ride->dropoff_address, 0, 50),
                number_format($ride->actual_distance ?? 0, 2, ',', '.'),
                $ride->actual_duration ?? 0,
                'R$ ' . number_format($ride->final_price, 2, ',', '.'),
                $ride->status,
            ];

            if ($user->isDriver()) {
                $row[] = 'R$ ' . number_format($ride->driver_earnings ?? 0, 2, ',', '.');
                $row[] = 'R$ ' . number_format($ride->tip_amount ?? 0, 2, ',', '.');
            }

            $data[] = $row;
        }

        return $data;
    }
}
