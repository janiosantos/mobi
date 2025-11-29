<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterPassengerRequest;
use App\Http\Requests\Auth\RegisterDriverRequest;
use App\Http\Requests\Auth\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\DTOs\AuthDTO;
use App\DTOs\DriverDTO;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        protected AuthService $authService
    ) {}

    /**
     * Register a new passenger
     *
     * @OA\Post(
     *     path="/api/v1/auth/register/passenger",
     *     tags={"Authentication"},
     *     summary="Register a new passenger account",
     *     description="Create a new passenger account with email, password, and profile information",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"name", "email", "password", "phone"},
     *             @OA\Property(property="name", type="string", example="João Silva"),
     *             @OA\Property(property="email", type="string", format="email", example="joao@example.com"),
     *             @OA\Property(property="password", type="string", format="password", example="password123", minLength=8),
     *             @OA\Property(property="password_confirmation", type="string", format="password", example="password123"),
     *             @OA\Property(property="phone", type="string", example="11999999999"),
     *             @OA\Property(property="cpf", type="string", example="12345678900"),
     *             @OA\Property(property="birth_date", type="string", format="date", example="1990-01-15"),
     *             @OA\Property(property="gender", type="string", enum={"male", "female", "other"}, example="male"),
     *             @OA\Property(property="device_token", type="string", example="fcm_token_here"),
     *             @OA\Property(property="device_type", type="string", enum={"android", "ios"}, example="android")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Passenger registered successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Passageiro registrado com sucesso!"),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="user", type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="name", type="string", example="João Silva"),
     *                     @OA\Property(property="email", type="string", example="joao@example.com"),
     *                     @OA\Property(property="phone", type="string", example="11999999999"),
     *                     @OA\Property(property="user_type", type="string", example="passenger"),
     *                     @OA\Property(property="created_at", type="string", format="date-time")
     *                 ),
     *                 @OA\Property(property="token", type="string", example="1|abcdef123456...")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Erro de validação."),
     *             @OA\Property(property="errors", type="object")
     *         )
     *     )
     * )
     */
    public function registerPassenger(RegisterPassengerRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();

            // Handle profile photo upload
            if ($request->hasFile('profile_photo')) {
                $validated['profile_photo_url'] = $request->file('profile_photo')
                    ->store('profile-photos', 'public');
            }

            $authDTO = AuthDTO::fromArray($validated);
            $result = $this->authService->registerPassenger($authDTO);

            // Update device token if provided
            if (isset($validated['device_token'])) {
                $result['user']->update([
                    'device_token' => $validated['device_token'],
                    'device_type' => $validated['device_type'] ?? null,
                ]);
            }

            return response()->json([
                'message' => 'Passageiro registrado com sucesso!',
                'data' => [
                    'user' => new UserResource($result['user']),
                    'token' => $result['token'],
                ],
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Erro de validação.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao registrar passageiro.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Register a new driver
     */
    public function registerDriver(RegisterDriverRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();

            // Handle profile photo upload
            if ($request->hasFile('profile_photo')) {
                $validated['profile_photo_url'] = $request->file('profile_photo')
                    ->store('profile-photos', 'public');
            }

            $authDTO = AuthDTO::fromArray($validated);
            $driverDTO = DriverDTO::fromArray($validated);

            $result = $this->authService->registerDriver($authDTO, $driverDTO);

            // Update device token if provided
            if (isset($validated['device_token'])) {
                $result['user']->update([
                    'device_token' => $validated['device_token'],
                    'device_type' => $validated['device_type'] ?? null,
                ]);
            }

            return response()->json([
                'message' => 'Motorista registrado com sucesso! Aguarde aprovação.',
                'data' => [
                    'user' => new UserResource($result['user']->load('driverProfile')),
                    'token' => $result['token'],
                ],
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Erro de validação.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao registrar motorista.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Login user
     *
     * @OA\Post(
     *     path="/api/v1/auth/login",
     *     tags={"Authentication"},
     *     summary="Authenticate user and receive token",
     *     description="Login with email and password to receive authentication token",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"email", "password"},
     *             @OA\Property(property="email", type="string", format="email", example="joao@example.com"),
     *             @OA\Property(property="password", type="string", format="password", example="password123"),
     *             @OA\Property(property="device_token", type="string", example="fcm_token_here"),
     *             @OA\Property(property="device_type", type="string", enum={"android", "ios"}, example="android")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Login successful",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Login realizado com sucesso!"),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="user", type="object"),
     *                 @OA\Property(property="token", type="string", example="1|abcdef123456...")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Invalid credentials",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Credenciais inválidas.")
     *         )
     *     )
     * )
     */
    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();

            $result = $this->authService->login(
                $validated['email'],
                $validated['password']
            );

            // Update device token if provided
            if (isset($validated['device_token'])) {
                $result['user']->update([
                    'device_token' => $validated['device_token'],
                    'device_type' => $validated['device_type'] ?? null,
                ]);
            }

            return response()->json([
                'message' => 'Login realizado com sucesso!',
                'data' => [
                    'user' => new UserResource($result['user']->load('driverProfile')),
                    'token' => $result['token'],
                ],
            ], 200);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Credenciais inválidas.',
                'errors' => $e->errors(),
            ], 401);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao fazer login.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Logout user (revoke current token)
     *
     * @OA\Post(
     *     path="/api/v1/auth/logout",
     *     tags={"Authentication"},
     *     summary="Logout and revoke current token",
     *     description="Revoke the current authentication token",
     *     security={{"sanctum": {}}},
     *     @OA\Response(
     *         response=200,
     *         description="Logout successful",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Logout realizado com sucesso!")
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Unauthenticated"
     *     )
     * )
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            $this->authService->logout($request->user());

            return response()->json([
                'message' => 'Logout realizado com sucesso!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao fazer logout.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get authenticated user profile
     *
     * @OA\Get(
     *     path="/api/v1/auth/me",
     *     tags={"Authentication"},
     *     summary="Get current user profile",
     *     description="Retrieve the authenticated user's profile information",
     *     security={{"sanctum": {}}},
     *     @OA\Response(
     *         response=200,
     *         description="User profile retrieved successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="João Silva"),
     *                 @OA\Property(property="email", type="string", example="joao@example.com"),
     *                 @OA\Property(property="phone", type="string", example="11999999999"),
     *                 @OA\Property(property="user_type", type="string", example="passenger"),
     *                 @OA\Property(property="wallet_balance", type="number", format="float", example=50.00),
     *                 @OA\Property(property="level", type="integer", example=5),
     *                 @OA\Property(property="total_xp", type="integer", example=1250)
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Unauthenticated"
     *     )
     * )
     */
    public function profile(Request $request): JsonResponse
    {
        try {
            $user = $request->user()->load('driverProfile');

            return response()->json([
                'data' => new UserResource($user),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar perfil.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update user profile
     */
    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        try {
            $user = $request->user();
            $validated = $request->validated();

            // Handle profile photo upload
            if ($request->hasFile('profile_photo')) {
                // Delete old photo
                if ($user->profile_photo_url) {
                    Storage::disk('public')->delete($user->profile_photo_url);
                }

                $validated['profile_photo_url'] = $request->file('profile_photo')
                    ->store('profile-photos', 'public');
            }

            $user->update($validated);

            return response()->json([
                'message' => 'Perfil atualizado com sucesso!',
                'data' => new UserResource($user->fresh()),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar perfil.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Refresh auth token
     */
    public function refreshToken(Request $request): JsonResponse
    {
        try {
            $token = $this->authService->refreshToken($request->user());

            return response()->json([
                'message' => 'Token renovado com sucesso!',
                'data' => [
                    'token' => $token,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao renovar token.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete user account
     */
    public function deleteAccount(Request $request): JsonResponse
    {
        try {
            $this->authService->deleteAccount($request->user());

            return response()->json([
                'message' => 'Conta excluída com sucesso!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao excluir conta.',
                'error' => $e->getMessage(),
            ], 400);
        }
    }
}
