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
