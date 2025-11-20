<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Requests\Driver\WithdrawEarningsRequest;
use App\Http\Resources\EarningResource;
use App\Http\Resources\WithdrawalResource;
use App\Models\Earning;
use App\Models\Withdrawal;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class EarningController extends Controller
{
    /**
     * List all earnings for driver
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $earnings = Earning::where('driver_id', $driverProfile->id)
            ->with('ride')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'message' => 'Earnings retrieved successfully',
            'data' => EarningResource::collection($earnings->items()),
            'meta' => [
                'current_page' => $earnings->currentPage(),
                'last_page' => $earnings->lastPage(),
                'per_page' => $earnings->perPage(),
                'total' => $earnings->total(),
            ],
        ]);
    }

    /**
     * Get earnings summary
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $totalEarnings = Earning::where('driver_id', $driverProfile->id)
            ->sum('driver_amount');

        $pendingEarnings = Earning::where('driver_id', $driverProfile->id)
            ->where('status', 'pending')
            ->sum('driver_amount');

        $paidEarnings = Earning::where('driver_id', $driverProfile->id)
            ->where('status', 'paid')
            ->sum('driver_amount');

        $thisMonthEarnings = Earning::where('driver_id', $driverProfile->id)
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->sum('driver_amount');

        $todayEarnings = Earning::where('driver_id', $driverProfile->id)
            ->whereDate('created_at', today())
            ->sum('driver_amount');

        return response()->json([
            'success' => true,
            'message' => 'Earnings summary retrieved successfully',
            'data' => [
                'total_earnings' => round($totalEarnings, 2),
                'pending_earnings' => round($pendingEarnings, 2),
                'paid_earnings' => round($paidEarnings, 2),
                'available_balance' => round($driverProfile->available_balance, 2),
                'this_month' => round($thisMonthEarnings, 2),
                'today' => round($todayEarnings, 2),
            ],
        ]);
    }

    /**
     * Get daily earnings
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function daily(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $date = $request->input('date', today()->toDateString());

        $earnings = Earning::where('driver_id', $driverProfile->id)
            ->whereDate('created_at', $date)
            ->with('ride')
            ->get();

        $totalAmount = $earnings->sum('driver_amount');
        $totalRides = $earnings->count();

        return response()->json([
            'success' => true,
            'message' => 'Daily earnings retrieved successfully',
            'data' => [
                'date' => $date,
                'total_amount' => round($totalAmount, 2),
                'total_rides' => $totalRides,
                'average_per_ride' => $totalRides > 0 ? round($totalAmount / $totalRides, 2) : 0,
                'earnings' => EarningResource::collection($earnings),
            ],
        ]);
    }

    /**
     * Get weekly earnings
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function weekly(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $startOfWeek = now()->startOfWeek();
        $endOfWeek = now()->endOfWeek();

        $earnings = Earning::where('driver_id', $driverProfile->id)
            ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
            ->get();

        // Group by day
        $earningsByDay = $earnings->groupBy(function ($earning) {
            return Carbon::parse($earning->created_at)->format('Y-m-d');
        })->map(function ($dayEarnings) {
            return [
                'total_amount' => round($dayEarnings->sum('driver_amount'), 2),
                'total_rides' => $dayEarnings->count(),
            ];
        });

        $totalAmount = $earnings->sum('driver_amount');
        $totalRides = $earnings->count();

        return response()->json([
            'success' => true,
            'message' => 'Weekly earnings retrieved successfully',
            'data' => [
                'week_start' => $startOfWeek->toDateString(),
                'week_end' => $endOfWeek->toDateString(),
                'total_amount' => round($totalAmount, 2),
                'total_rides' => $totalRides,
                'daily_breakdown' => $earningsByDay,
            ],
        ]);
    }

    /**
     * Get monthly earnings
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function monthly(Request $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $month = $request->input('month', now()->month);
        $year = $request->input('year', now()->year);

        $earnings = Earning::where('driver_id', $driverProfile->id)
            ->whereMonth('created_at', $month)
            ->whereYear('created_at', $year)
            ->get();

        // Group by week
        $earningsByWeek = $earnings->groupBy(function ($earning) {
            return Carbon::parse($earning->created_at)->weekOfYear;
        })->map(function ($weekEarnings) {
            return [
                'total_amount' => round($weekEarnings->sum('driver_amount'), 2),
                'total_rides' => $weekEarnings->count(),
            ];
        });

        $totalAmount = $earnings->sum('driver_amount');
        $totalRides = $earnings->count();

        return response()->json([
            'success' => true,
            'message' => 'Monthly earnings retrieved successfully',
            'data' => [
                'month' => $month,
                'year' => $year,
                'total_amount' => round($totalAmount, 2),
                'total_rides' => $totalRides,
                'weekly_breakdown' => $earningsByWeek,
            ],
        ]);
    }

    /**
     * Request withdrawal
     *
     * @param WithdrawEarningsRequest $request
     * @return JsonResponse
     */
    public function withdraw(WithdrawEarningsRequest $request): JsonResponse
    {
        $user = $request->user();
        $driverProfile = $user->driverProfile;

        $amount = $request->input('amount');

        // Check if driver has sufficient balance
        if ($amount > $driverProfile->available_balance) {
            return response()->json([
                'success' => false,
                'message' => 'Insufficient balance',
            ], 422);
        }

        // Create withdrawal request
        $withdrawal = DB::transaction(function () use ($driverProfile, $amount, $request) {
            $withdrawal = Withdrawal::create([
                'driver_id' => $driverProfile->id,
                'amount' => $amount,
                'status' => 'pending',
                'bank_account' => $request->input('bank_account'),
            ]);

            // Update driver balance
            $driverProfile->decrement('available_balance', $amount);

            return $withdrawal;
        });

        return response()->json([
            'success' => true,
            'message' => 'Withdrawal request created successfully',
            'data' => new WithdrawalResource($withdrawal),
        ], 201);
    }
}
