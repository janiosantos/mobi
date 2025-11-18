<?php

namespace App\Services;

use App\Models\User;
use App\Models\DriverProfile;
use App\DTOs\AuthDTO;
use App\DTOs\DriverDTO;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function __construct(
        protected UserRepositoryInterface $userRepository
    ) {}

    /**
     * Register a new passenger
     */
    public function registerPassenger(AuthDTO $data): array
    {
        return DB::transaction(function () use ($data) {
            // Check if email already exists
            if ($this->userRepository->findByEmail($data->email)) {
                throw ValidationException::withMessages([
                    'email' => ['This email is already registered.'],
                ]);
            }

            // Check if phone already exists
            if ($this->userRepository->findByPhone($data->phone)) {
                throw ValidationException::withMessages([
                    'phone' => ['This phone number is already registered.'],
                ]);
            }

            // Create user
            $user = $this->userRepository->create([
                'name' => $data->name,
                'email' => $data->email,
                'phone' => $data->phone,
                'password' => Hash::make($data->password),
                'user_type' => 'passenger',
                'cpf' => $data->cpf,
                'birth_date' => $data->birthDate,
                'gender' => $data->gender,
            ]);

            // Assign passenger role
            $user->assignRole('passenger');

            // Generate token
            $token = $user->createToken('auth_token', ['passenger'])->plainTextToken;

            Log::info('Passenger registered', ['user_id' => $user->id]);

            return [
                'user' => $user,
                'token' => $token,
            ];
        });
    }

    /**
     * Register a new driver
     */
    public function registerDriver(AuthDTO $authData, DriverDTO $driverData): array
    {
        return DB::transaction(function () use ($authData, $driverData) {
            // Check if email already exists
            if ($this->userRepository->findByEmail($authData->email)) {
                throw ValidationException::withMessages([
                    'email' => ['This email is already registered.'],
                ]);
            }

            // Check if phone already exists
            if ($this->userRepository->findByPhone($authData->phone)) {
                throw ValidationException::withMessages([
                    'phone' => ['This phone number is already registered.'],
                ]);
            }

            // Create user
            $user = $this->userRepository->create([
                'name' => $authData->name,
                'email' => $authData->email,
                'phone' => $authData->phone,
                'password' => Hash::make($authData->password),
                'user_type' => 'driver',
                'cpf' => $authData->cpf,
                'birth_date' => $authData->birthDate,
                'gender' => $authData->gender,
            ]);

            // Create driver profile
            $driverProfile = DriverProfile::create([
                'user_id' => $user->id,
                'license_number' => $driverData->licenseNumber,
                'license_category' => $driverData->licenseCategory,
                'license_expiry_date' => $driverData->licenseExpiryDate,
                'bank_name' => $driverData->bankName,
                'bank_account_type' => $driverData->bankAccountType,
                'bank_agency' => $driverData->bankAgency,
                'bank_account' => $driverData->bankAccount,
                'pix_key' => $driverData->pixKey,
                'pix_key_type' => $driverData->pixKeyType,
                'status' => 'pending', // Requires admin approval
            ]);

            // Assign driver role
            $user->assignRole('driver');

            // Generate token
            $token = $user->createToken('auth_token', ['driver'])->plainTextToken;

            Log::info('Driver registered', ['user_id' => $user->id]);

            return [
                'user' => $user->load('driverProfile'),
                'token' => $token,
            ];
        });
    }

    /**
     * Login user
     */
    public function login(string $email, string $password): array
    {
        $user = $this->userRepository->findByEmail($email);

        if (!$user || !Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if ($user->is_banned) {
            throw ValidationException::withMessages([
                'email' => ['Your account has been suspended. Reason: ' . $user->ban_reason],
            ]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Your account is inactive. Please contact support.'],
            ]);
        }

        // Update last active
        $user->update(['last_active_at' => now()]);

        // Generate token with abilities based on user type
        $abilities = [$user->user_type];
        $token = $user->createToken('auth_token', $abilities)->plainTextToken;

        Log::info('User logged in', ['user_id' => $user->id]);

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    /**
     * Logout user (revoke current token)
     */
    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();

        Log::info('User logged out', ['user_id' => $user->id]);
    }

    /**
     * Refresh token
     */
    public function refreshToken(User $user): string
    {
        // Revoke current token
        $user->currentAccessToken()->delete();

        // Create new token
        $abilities = [$user->user_type];
        $token = $user->createToken('auth_token', $abilities)->plainTextToken;

        return $token;
    }

    /**
     * Delete user account
     */
    public function deleteAccount(User $user): bool
    {
        return DB::transaction(function () use ($user) {
            // Check if user has active rides
            if ($user->user_type === 'passenger') {
                $activeRides = $user->ridesAsPassenger()->active()->count();
                if ($activeRides > 0) {
                    throw new \Exception('Cannot delete account with active rides.');
                }
            } elseif ($user->user_type === 'driver') {
                $activeRides = $user->ridesAsDriver()->active()->count();
                if ($activeRides > 0) {
                    throw new \Exception('Cannot delete account with active rides.');
                }
            }

            // Revoke all tokens
            $user->tokens()->delete();

            // Soft delete user
            $user->delete();

            Log::info('User account deleted', ['user_id' => $user->id]);

            return true;
        });
    }
}
