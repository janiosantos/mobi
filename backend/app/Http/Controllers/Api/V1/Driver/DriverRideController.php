<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Requests\Ride\CancelRideRequest;
use App\Http\Requests\Ride\RateRideRequest;
use App\Http\Resources\RideResource;
use App\Http\Resources\RatingResource;
use App\Services\RideService;
use App\Models\Ride;
use App\Models\Rating;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DriverRideController extends Controller
{
    public function __construct(
        protected RideService $rideService
    ) {}

    /**
     * Get available rides near driver
     */
    public function available(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile || !$driverProfile->canAcceptRides()) {
                return response()->json([
                    'message' => 'Você não pode aceitar corridas no momento.',
                ], 403);
            }

            // Get driver's current location
            if (!$driverProfile->current_latitude || !$driverProfile->current_longitude) {
                return response()->json([
                    'message' => 'Localização do motorista não encontrada.',
                ], 400);
            }

            $radius = $request->input('radius', 5); // km

            $availableRides = Ride::where('status', 'searching')
                ->where('vehicle_category_id', $driverProfile->vehicles()->first()?->vehicle_category_id)
                ->whereNull('driver_id')
                ->with(['passenger', 'category'])
                ->get()
                ->filter(function ($ride) use ($driverProfile, $radius) {
                    $distance = $this->calculateDistance(
                        $driverProfile->current_latitude,
                        $driverProfile->current_longitude,
                        $ride->pickup_latitude,
                        $ride->pickup_longitude
                    );
                    return $distance <= $radius;
                })
                ->values();

            return response()->json([
                'data' => RideResource::collection($availableRides),
                'count' => $availableRides->count(),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar corridas disponíveis.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Accept a ride
     */
    public function accept(Request $request, Ride $ride): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile || !$driverProfile->canAcceptRides()) {
                return response()->json([
                    'message' => 'Você não pode aceitar corridas no momento.',
                ], 403);
            }

            // Get driver's primary vehicle
            $vehicle = $driverProfile->vehicles()->where('is_active', true)->first();

            if (!$vehicle) {
                return response()->json([
                    'message' => 'Você precisa ter um veículo ativo para aceitar corridas.',
                ], 400);
            }

            $ride = $this->rideService->acceptRide($ride, $driver, $vehicle);

            return response()->json([
                'message' => 'Corrida aceita com sucesso!',
                'data' => new RideResource($ride->load(['passenger', 'vehicle', 'category'])),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao aceitar corrida.',
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Mark driver as arrived at pickup location
     */
    public function arrived(Request $request, Ride $ride): JsonResponse
    {
        try {
            $driver = $request->user();

            if ($ride->driver_id !== $driver->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            $ride = $this->rideService->driverArrived($ride);

            return response()->json([
                'message' => 'Chegada confirmada!',
                'data' => new RideResource($ride),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao confirmar chegada.',
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Start the ride
     */
    public function start(Request $request, Ride $ride): JsonResponse
    {
        try {
            $driver = $request->user();

            if ($ride->driver_id !== $driver->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            $ride = $this->rideService->startRide($ride);

            return response()->json([
                'message' => 'Corrida iniciada!',
                'data' => new RideResource($ride),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao iniciar corrida.',
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Complete the ride
     */
    public function complete(Request $request, Ride $ride): JsonResponse
    {
        try {
            $driver = $request->user();

            if ($ride->driver_id !== $driver->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            $ride = $this->rideService->completeRide($ride);

            return response()->json([
                'message' => 'Corrida finalizada com sucesso!',
                'data' => new RideResource($ride),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao finalizar corrida.',
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Cancel ride
     */
    public function cancel(CancelRideRequest $request, Ride $ride): JsonResponse
    {
        try {
            $driver = $request->user();
            $validated = $request->validated();

            if ($ride->driver_id !== $driver->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para cancelar esta corrida.',
                ], 403);
            }

            $ride = $this->rideService->cancelRide(
                $ride,
                'driver',
                $validated['cancellation_reason']
            );

            return response()->json([
                'message' => 'Corrida cancelada.',
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
     * Get driver's ride history
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $perPage = $request->input('per_page', 15);

            $rides = Ride::where('driver_id', $driver->id)
                ->with(['passenger', 'vehicle', 'category', 'payment', 'ratings'])
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
     * Get active ride for driver
     */
    public function active(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();

            $activeRide = Ride::where('driver_id', $driver->id)
                ->whereIn('status', ['accepted', 'driver_arrived', 'in_progress'])
                ->with(['passenger', 'vehicle', 'category'])
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
     * Rate completed ride (driver rates passenger)
     */
    public function rate(RateRideRequest $request, Ride $ride): JsonResponse
    {
        try {
            $driver = $request->user();
            $validated = $request->validated();

            if ($ride->driver_id !== $driver->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para avaliar esta corrida.',
                ], 403);
            }

            if ($ride->status !== 'completed') {
                return response()->json([
                    'message' => 'Você só pode avaliar corridas concluídas.',
                ], 400);
            }

            $existingRating = Rating::where('ride_id', $ride->id)
                ->where('rater_id', $driver->id)
                ->first();

            if ($existingRating) {
                return response()->json([
                    'message' => 'Você já avaliou esta corrida.',
                ], 400);
            }

            $rating = Rating::create([
                'ride_id' => $ride->id,
                'rater_id' => $driver->id,
                'rated_id' => $ride->passenger_id,
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
                'tags' => $validated['tags'] ?? null,
            ]);

            // Update passenger's average rating
            $passenger = $ride->passenger;
            $passenger->update([
                'total_ratings' => $passenger->total_ratings + 1,
                'average_rating' => $passenger->ratings()->avg('rating'),
            ]);

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

    /**
     * Calculate distance between two coordinates using Haversine formula
     */
    private function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371; // km

        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }
}
