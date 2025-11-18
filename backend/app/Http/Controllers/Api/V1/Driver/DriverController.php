<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Requests\Driver\UpdateLocationRequest;
use App\Http\Requests\Driver\UpdateDriverProfileRequest;
use App\Http\Requests\Driver\UpdateBankAccountRequest;
use App\Http\Requests\Driver\ToggleOnlineStatusRequest;
use App\Http\Requests\Driver\UploadDocumentRequest;
use App\Http\Requests\Driver\WithdrawEarningsRequest;
use App\Http\Resources\DriverProfileResource;
use App\Http\Resources\DriverDocumentResource;
use App\Http\Resources\EarningResource;
use App\Http\Resources\WithdrawalResource;
use App\Models\DriverDocument;
use App\Models\Earning;
use App\Models\Withdrawal;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class DriverController extends Controller
{
    /**
     * Get driver profile
     */
    public function profile(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile()->with(['vehicles', 'documents'])->first();

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            return response()->json([
                'data' => new DriverProfileResource($driverProfile),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar perfil do motorista.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update driver profile
     */
    public function updateProfile(UpdateDriverProfileRequest $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $driverProfile->update($request->validated());

            return response()->json([
                'message' => 'Perfil atualizado com sucesso!',
                'data' => new DriverProfileResource($driverProfile->fresh()),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar perfil.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update driver location
     */
    public function updateLocation(UpdateLocationRequest $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $validated = $request->validated();

            $driverProfile->update([
                'current_latitude' => $validated['latitude'],
                'current_longitude' => $validated['longitude'],
                'heading' => $validated['heading'] ?? null,
                'speed' => $validated['speed'] ?? null,
                'location_updated_at' => now(),
            ]);

            return response()->json([
                'message' => 'Localização atualizada com sucesso!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar localização.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle online/offline status
     */
    public function toggleOnlineStatus(ToggleOnlineStatusRequest $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $validated = $request->validated();

            $updates = [
                'is_online' => $validated['is_online'],
                'is_available' => $validated['is_online'],
            ];

            if ($validated['is_online']) {
                $updates['current_latitude'] = $validated['latitude'];
                $updates['current_longitude'] = $validated['longitude'];
                $updates['location_updated_at'] = now();
            }

            $driverProfile->update($updates);

            $status = $validated['is_online'] ? 'online' : 'offline';

            return response()->json([
                'message' => "Status atualizado para {$status}!",
                'data' => new DriverProfileResource($driverProfile->fresh()),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar status.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update bank account
     */
    public function updateBankAccount(UpdateBankAccountRequest $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $driverProfile->update($request->validated());

            return response()->json([
                'message' => 'Dados bancários atualizados com sucesso!',
                'data' => new DriverProfileResource($driverProfile->fresh()),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar dados bancários.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Upload driver document
     */
    public function uploadDocument(UploadDocumentRequest $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $validated = $request->validated();

            // Upload file
            $documentPath = $request->file('document_file')
                ->store('driver-documents/' . $driver->id, 'private');

            // Create document record
            $document = DriverDocument::create([
                'driver_id' => $driverProfile->id,
                'document_type' => $validated['document_type'],
                'document_number' => $validated['document_number'] ?? null,
                'document_url' => $documentPath,
                'expiry_date' => $validated['expiry_date'] ?? null,
                'status' => 'pending',
            ]);

            return response()->json([
                'message' => 'Documento enviado com sucesso! Aguarde análise.',
                'data' => new DriverDocumentResource($document),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao enviar documento.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get driver documents
     */
    public function documents(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $documents = $driverProfile->documents;

            return response()->json([
                'data' => DriverDocumentResource::collection($documents),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar documentos.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get driver earnings
     */
    public function earnings(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $perPage = $request->input('per_page', 15);

            $earnings = Earning::where('driver_id', $driverProfile->id)
                ->with('ride')
                ->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'data' => EarningResource::collection($earnings),
                'summary' => [
                    'total_earnings' => number_format($driverProfile->total_earnings ?? 0, 2, '.', ''),
                    'available_balance' => number_format($driverProfile->available_balance ?? 0, 2, '.', ''),
                    'withdrawn_amount' => number_format($driverProfile->withdrawn_amount ?? 0, 2, '.', ''),
                ],
                'pagination' => [
                    'total' => $earnings->total(),
                    'per_page' => $earnings->perPage(),
                    'current_page' => $earnings->currentPage(),
                    'last_page' => $earnings->lastPage(),
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar ganhos.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Request withdrawal
     */
    public function requestWithdrawal(WithdrawEarningsRequest $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $validated = $request->validated();

            // Check if driver has enough balance
            if ($driverProfile->available_balance < $validated['amount']) {
                return response()->json([
                    'message' => 'Saldo insuficiente para saque.',
                ], 400);
            }

            // Check if driver has bank account or pix configured
            if ($validated['withdrawal_method'] === 'bank_transfer' && !$driverProfile->bank_account) {
                return response()->json([
                    'message' => 'Configure seus dados bancários primeiro.',
                ], 400);
            }

            if ($validated['withdrawal_method'] === 'pix' && !$driverProfile->pix_key) {
                return response()->json([
                    'message' => 'Configure sua chave PIX primeiro.',
                ], 400);
            }

            // Create withdrawal request
            $withdrawal = Withdrawal::create([
                'withdrawal_number' => 'WD-' . strtoupper(uniqid()),
                'driver_id' => $driverProfile->id,
                'amount' => $validated['amount'],
                'withdrawal_method' => $validated['withdrawal_method'],
                'status' => 'pending',
                'bank_name' => $driverProfile->bank_name,
                'bank_account_type' => $driverProfile->bank_account_type,
                'bank_agency' => $driverProfile->bank_agency,
                'bank_account' => $driverProfile->bank_account,
                'pix_key' => $driverProfile->pix_key,
                'pix_key_type' => $driverProfile->pix_key_type,
            ]);

            // Update available balance
            $driverProfile->decrement('available_balance', $validated['amount']);

            return response()->json([
                'message' => 'Solicitação de saque criada com sucesso! Processamento em até 2 dias úteis.',
                'data' => new WithdrawalResource($withdrawal),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao solicitar saque.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get withdrawal history
     */
    public function withdrawals(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $perPage = $request->input('per_page', 15);

            $withdrawals = Withdrawal::where('driver_id', $driverProfile->id)
                ->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'data' => WithdrawalResource::collection($withdrawals),
                'pagination' => [
                    'total' => $withdrawals->total(),
                    'per_page' => $withdrawals->perPage(),
                    'current_page' => $withdrawals->currentPage(),
                    'last_page' => $withdrawals->lastPage(),
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar saques.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get driver statistics
     */
    public function statistics(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            return response()->json([
                'data' => [
                    'total_rides' => $driverProfile->total_rides,
                    'completed_rides' => $driverProfile->completed_rides,
                    'cancelled_rides' => $driverProfile->cancelled_rides,
                    'acceptance_rate' => round($driverProfile->acceptance_rate ?? 0, 2),
                    'cancellation_rate' => round($driverProfile->cancellation_rate ?? 0, 2),
                    'average_rating' => round($driverProfile->average_rating ?? 0, 2),
                    'total_ratings' => $driverProfile->total_ratings,
                    'total_earnings' => number_format($driverProfile->total_earnings ?? 0, 2, '.', ''),
                    'available_balance' => number_format($driverProfile->available_balance ?? 0, 2, '.', ''),
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar estatísticas.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
