<?php

namespace App\Http\Controllers;

/**
 * @OA\Info(
 *     title="MOBI API",
 *     version="1.0.0",
 *     description="Comprehensive API documentation for MOBI ride-sharing platform. This API provides endpoints for passenger and driver mobile applications, admin panel, and third-party integrations.",
 *     @OA\Contact(
 *         name="MOBI Development Team",
 *         email="dev@mobi.com.br"
 *     ),
 *     @OA\License(
 *         name="MIT",
 *         url="https://opensource.org/licenses/MIT"
 *     )
 * )
 *
 * @OA\Server(
 *     url="http://localhost:8000",
 *     description="Local Development Server"
 * )
 *
 * @OA\Server(
 *     url="https://api-staging.mobi.com.br",
 *     description="Staging Server"
 * )
 *
 * @OA\Server(
 *     url="https://api.mobi.com.br",
 *     description="Production Server"
 * )
 *
 * @OA\SecurityScheme(
 *     securityScheme="sanctum",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT",
 *     description="Laravel Sanctum authentication. Include token in Authorization header as 'Bearer {token}'"
 * )
 *
 * @OA\Tag(
 *     name="Authentication",
 *     description="User registration, login, logout, and profile management"
 * )
 *
 * @OA\Tag(
 *     name="Passenger - Rides",
 *     description="Ride management for passengers (create, track, cancel, rate)"
 * )
 *
 * @OA\Tag(
 *     name="Driver - Rides",
 *     description="Ride management for drivers (accept, start, complete)"
 * )
 *
 * @OA\Tag(
 *     name="Driver - Management",
 *     description="Driver profile, documents, vehicles, earnings"
 * )
 *
 * @OA\Tag(
 *     name="Payments",
 *     description="Payment methods and transaction history"
 * )
 *
 * @OA\Tag(
 *     name="Gamification",
 *     description="Achievements, badges, leaderboards, and XP system"
 * )
 *
 * @OA\Tag(
 *     name="Safety",
 *     description="SOS alerts, emergency contacts, trip sharing"
 * )
 *
 * @OA\Tag(
 *     name="Chat",
 *     description="In-ride messaging between passenger and driver"
 * )
 *
 * @OA\Tag(
 *     name="Miscellaneous",
 *     description="Categories, coupons, referrals, saved places"
 * )
 */
abstract class Controller
{
    //
}
