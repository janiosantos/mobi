<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\VehicleCategoryResource;
use App\Models\VehicleCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * Get all active vehicle categories
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $categories = VehicleCategory::active()
                ->orderBy('sort_order')
                ->orderBy('name')
                ->get();

            return response()->json([
                'data' => VehicleCategoryResource::collection($categories),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar categorias de veículos.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get specific category
     */
    public function show(Request $request, VehicleCategory $category): JsonResponse
    {
        try {
            if (!$category->is_active) {
                return response()->json([
                    'message' => 'Categoria não disponível.',
                ], 404);
            }

            return response()->json([
                'data' => new VehicleCategoryResource($category),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar categoria.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
