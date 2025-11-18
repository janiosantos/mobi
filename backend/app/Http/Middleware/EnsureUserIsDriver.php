<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsDriver
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || $request->user()->user_type !== 'driver') {
            return response()->json([
                'success' => false,
                'message' => 'This action is only available for drivers.',
            ], 403);
        }

        return $next($request);
    }
}
