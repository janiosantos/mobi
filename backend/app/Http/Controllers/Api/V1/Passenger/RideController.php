<?php

namespace App\Http\Controllers\Api\V1\Passenger;

use App\Http\Controllers\Controller;
use App\Http\Requests\Ride\RideEstimateRequest;
use App\Http\Requests\Ride\CreateRideRequest;
use App\Http\Requests\Ride\CancelRideRequest;
use App\Http\Requests\Ride\RateRideRequest;
use App\Http\Resources\RideResource;
use App\Http\Resources\RatingResource;
use App\Services\RideService;
use App\Services\DriverMatchingService;
use App\DTOs\RideDTO;
use App\Models\Ride;
use App\Models\Rating;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RideController extends Controller
{
    public function __construct(
        protected RideService $rideService,
        protected DriverMatchingService $driverMatchingService
    ) {}

    /**
     * Get ride estimate
     */
    public function estimate(RideEstimateRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();
            $rideDTO = RideDTO::fromArray($validated);

            $estimate = $this->rideService->estimateRide($rideDTO);

            return response()->json([
                'message' => 'Estimativa calculada com sucesso!',
                'data' => $estimate,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao calcular estimativa.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create a new ride
     */
    public function store(CreateRideRequest $request): JsonResponse
    {
        try {
            $passenger = $request->user();
            $validated = $request->validated();
            $rideDTO = RideDTO::fromArray($validated);

            // Create ride
            $ride = $this->rideService->createRide($passenger, $rideDTO);

            // Find and notify nearby drivers
            $this->driverMatchingService->notifyNearbyDrivers($ride);

            return response()->json([
                'message' => 'Corrida criada com sucesso! Procurando motoristas...',
                'data' => new RideResource($ride->load(['category', 'passenger'])),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao criar corrida.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get passenger's ride history
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $passenger = $request->user();
            $perPage = $request->input('per_page', 15);

            $rides = Ride::where('passenger_id', $passenger->id)
                ->with(['driver', 'vehicle', 'category', 'payment', 'ratings'])
                ->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'data' => RideResource::collection($rides),
                'pagination' => [
                    'total' => $rides->total(),
                    'per_page' => $rides->perPage(),
                    'current_page' => $rides->currentPage(),
                    'last_page' => $rides->lastPage(),
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar histórico de corridas.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get specific ride details
     */
    public function show(Request $request, Ride $ride): JsonResponse
    {
        try {
            $passenger = $request->user();

            // Verify passenger owns this ride
            if ($ride->passenger_id !== $passenger->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para ver esta corrida.',
                ], 403);
            }

            $ride->load(['driver', 'vehicle', 'category', 'payment', 'ratings', 'messages']);

            return response()->json([
                'data' => new RideResource($ride),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar corrida.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get active ride for passenger
     */
    public function active(Request $request): JsonResponse
    {
        try {
            $passenger = $request->user();

            $activeRide = Ride::where('passenger_id', $passenger->id)
                ->whereIn('status', [
                    'requested', 'searching', 'accepted',
                    'driver_arrived', 'in_progress'
                ])
                ->with(['driver', 'vehicle', 'category'])
                ->first();

            if (!$activeRide) {
                return response()->json([
                    'message' => 'Nenhuma corrida ativa encontrada.',
                    'data' => null,
                ], 200);
            }

            return response()->json([
                'data' => new RideResource($activeRide),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar corrida ativa.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cancel ride
     */
    public function cancel(CancelRideRequest $request, Ride $ride): JsonResponse
    {
        try {
            $passenger = $request->user();
            $validated = $request->validated();

            // Verify passenger owns this ride
            if ($ride->passenger_id !== $passenger->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para cancelar esta corrida.',
                ], 403);
            }

            $ride = $this->rideService->cancelRide(
                $ride,
                'passenger',
                $validated['cancellation_reason']
            );

            return response()->json([
                'message' => 'Corrida cancelada com sucesso.',
                'data' => new RideResource($ride),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao cancelar corrida.',
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Rate completed ride
     */
    public function rate(RateRideRequest $request, Ride $ride): JsonResponse
    {
        try {
            $passenger = $request->user();
            $validated = $request->validated();

            // Verify passenger owns this ride
            if ($ride->passenger_id !== $passenger->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para avaliar esta corrida.',
                ], 403);
            }

            // Verify ride is completed
            if ($ride->status !== 'completed') {
                return response()->json([
                    'message' => 'Você só pode avaliar corridas concluídas.',
                ], 400);
            }

            // Check if already rated
            $existingRating = Rating::where('ride_id', $ride->id)
                ->where('rater_id', $passenger->id)
                ->first();

            if ($existingRating) {
                return response()->json([
                    'message' => 'Você já avaliou esta corrida.',
                ], 400);
            }

            // Create rating
            $rating = Rating::create([
                'ride_id' => $ride->id,
                'rater_id' => $passenger->id,
                'rated_id' => $ride->driver_id,
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
                'tags' => $validated['tags'] ?? null,
            ]);

            // Update driver's average rating
            $driver = $ride->driver;
            $driver->update([
                'total_ratings' => $driver->total_ratings + 1,
                'average_rating' => $driver->ratings()->avg('rating'),
            ]);

            // Also update driver profile
            if ($driver->driverProfile) {
                $driver->driverProfile->update([
                    'total_ratings' => $driver->total_ratings,
                    'average_rating' => $driver->average_rating,
                ]);
            }

            return response()->json([
                'message' => 'Avaliação enviada com sucesso!',
                'data' => new RatingResource($rating),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao enviar avaliação.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
