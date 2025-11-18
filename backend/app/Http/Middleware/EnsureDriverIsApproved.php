<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureDriverIsApproved
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user || $user->user_type !== 'driver') {
            return response()->json([
                'success' => false,
                'message' => 'This action is only available for drivers.',
            ], 403);
        }

        if (!$user->driverProfile || $user->driverProfile->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Your driver profile must be approved to perform this action.',
                'driver_status' => $user->driverProfile?->status ?? 'no_profile',
            ], 403);
        }

        return $next($request);
    }
}
