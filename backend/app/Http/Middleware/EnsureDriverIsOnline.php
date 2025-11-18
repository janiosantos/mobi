<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureDriverIsOnline
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

        if (!$user->driverProfile || !$user->driverProfile->is_online) {
            return response()->json([
                'success' => false,
                'message' => 'You must be online to perform this action.',
                'is_online' => $user->driverProfile?->is_online ?? false,
            ], 403);
        }

        return $next($request);
    }
}
