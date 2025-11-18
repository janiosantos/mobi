<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Requests\Vehicle\AddVehicleRequest;
use App\Http\Resources\VehicleResource;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class VehicleController extends Controller
{
    /**
     * Get driver's vehicles
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile) {
                return response()->json([
                    'message' => 'Perfil de motorista não encontrado.',
                ], 404);
            }

            $vehicles = $driverProfile->vehicles()->with('category')->get();

            return response()->json([
                'data' => VehicleResource::collection($vehicles),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar veículos.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Add new vehicle
     */
    public function store(AddVehicleRequest $request): JsonResponse
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

            // Handle photo upload
            if ($request->hasFile('photo')) {
                $validated['photo_url'] = $request->file('photo')
                    ->store('vehicle-photos', 'public');
            }

            // If this is the first vehicle, set as active
            $isFirstVehicle = $driverProfile->vehicles()->count() === 0;

            $vehicle = Vehicle::create([
                'driver_id' => $driverProfile->id,
                'vehicle_category_id' => $validated['vehicle_category_id'],
                'make' => $validated['make'],
                'model' => $validated['model'],
                'year' => $validated['year'],
                'color' => $validated['color'],
                'license_plate' => $validated['license_plate'],
                'photo_url' => $validated['photo_url'] ?? null,
                'is_active' => $isFirstVehicle,
            ]);

            return response()->json([
                'message' => 'Veículo adicionado com sucesso!',
                'data' => new VehicleResource($vehicle->load('category')),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao adicionar veículo.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get specific vehicle
     */
    public function show(Request $request, Vehicle $vehicle): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if ($vehicle->driver_id !== $driverProfile?->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para ver este veículo.',
                ], 403);
            }

            $vehicle->load('category');

            return response()->json([
                'data' => new VehicleResource($vehicle),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar veículo.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update vehicle
     */
    public function update(Request $request, Vehicle $vehicle): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if ($vehicle->driver_id !== $driverProfile?->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para editar este veículo.',
                ], 403);
            }

            $validated = $request->validate([
                'color' => 'sometimes|string|max:50',
                'photo' => 'nullable|image|max:2048',
                'is_active' => 'sometimes|boolean',
            ]);

            // Handle photo upload
            if ($request->hasFile('photo')) {
                // Delete old photo
                if ($vehicle->photo_url) {
                    Storage::disk('public')->delete($vehicle->photo_url);
                }

                $validated['photo_url'] = $request->file('photo')
                    ->store('vehicle-photos', 'public');
            }

            // If setting as active, deactivate other vehicles
            if (isset($validated['is_active']) && $validated['is_active']) {
                Vehicle::where('driver_id', $driverProfile->id)
                    ->where('id', '!=', $vehicle->id)
                    ->update(['is_active' => false]);
            }

            $vehicle->update($validated);

            return response()->json([
                'message' => 'Veículo atualizado com sucesso!',
                'data' => new VehicleResource($vehicle->fresh('category')),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar veículo.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete vehicle
     */
    public function destroy(Request $request, Vehicle $vehicle): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if ($vehicle->driver_id !== $driverProfile?->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para excluir este veículo.',
                ], 403);
            }

            // Delete photo if exists
            if ($vehicle->photo_url) {
                Storage::disk('public')->delete($vehicle->photo_url);
            }

            $wasActive = $vehicle->is_active;
            $vehicle->delete();

            // If deleted vehicle was active, activate another one
            if ($wasActive) {
                $newActive = Vehicle::where('driver_id', $driverProfile->id)->first();
                if ($newActive) {
                    $newActive->update(['is_active' => true]);
                }
            }

            return response()->json([
                'message' => 'Veículo removido com sucesso!',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao remover veículo.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Set vehicle as active
     */
    public function setActive(Request $request, Vehicle $vehicle): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if ($vehicle->driver_id !== $driverProfile?->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            // Deactivate all other vehicles
            Vehicle::where('driver_id', $driverProfile->id)
                ->where('id', '!=', $vehicle->id)
                ->update(['is_active' => false]);

            // Activate this vehicle
            $vehicle->update(['is_active' => true]);

            return response()->json([
                'message' => 'Veículo ativado com sucesso!',
                'data' => new VehicleResource($vehicle->fresh('category')),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao ativar veículo.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
