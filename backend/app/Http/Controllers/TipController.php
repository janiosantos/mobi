<?php

namespace App\Http\Controllers;

use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TipController extends Controller
{
    /**
     * Add tip to a completed ride.
     */
    public function addTip(Request $request, Ride $ride): JsonResponse
    {
        // Verify user is the passenger
        if ($ride->passenger_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Verify ride is completed
        if ($ride->status !== 'completed') {
            return response()->json([
                'message' => 'Can only tip completed rides'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1|max:1000',
            'type' => 'required|in:percentage,fixed,custom',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $amount = $request->input('amount');
        $type = $request->input('type');

        // Calculate tip amount based on type
        $tipAmount = match($type) {
            'percentage' => ($ride->final_price * $amount) / 100,
            'fixed' => $amount,
            'custom' => $amount,
            default => $amount,
        };

        $ride->update([
            'tip_amount' => $tipAmount,
            'tip_type' => $type,
        ]);

        // Update driver earnings with tip
        // TODO: Add to driver earnings

        return response()->json([
            'data' => [
                'ride_id' => $ride->id,
                'tip_amount' => $tipAmount,
                'tip_type' => $type,
                'total_amount' => $ride->final_price + $tipAmount,
            ],
            'message' => 'Tip added successfully'
        ]);
    }

    /**
     * Get suggested tip amounts for a ride.
     */
    public function getSuggestions(Ride $ride): JsonResponse
    {
        $price = $ride->final_price;

        return response()->json([
            'data' => [
                'suggestions' => [
                    [
                        'label' => '5%',
                        'amount' => round(($price * 0.05), 2),
                        'type' => 'percentage',
                        'value' => 5,
                    ],
                    [
                        'label' => '10%',
                        'amount' => round(($price * 0.10), 2),
                        'type' => 'percentage',
                        'value' => 10,
                    ],
                    [
                        'label' => '15%',
                        'amount' => round(($price * 0.15), 2),
                        'type' => 'percentage',
                        'value' => 15,
                    ],
                    [
                        'label' => 'R$ 5,00',
                        'amount' => 5.00,
                        'type' => 'fixed',
                        'value' => 5,
                    ],
                    [
                        'label' => 'R$ 10,00',
                        'amount' => 10.00,
                        'type' => 'fixed',
                        'value' => 10,
                    ],
                ],
                'ride_price' => $price,
            ]
        ]);
    }
}
