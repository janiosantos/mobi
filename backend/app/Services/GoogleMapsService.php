<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class GoogleMapsService
{
    protected Client $client;
    protected string $apiKey;
    protected string $directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json';
    protected string $distanceMatrixUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    protected string $geocodingUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

    public function __construct()
    {
        $this->client = new Client([
            'timeout' => 10,
            'verify' => false,
        ]);
        $this->apiKey = config('services.google.maps.api_key');
    }

    /**
     * Get directions between two points
     */
    public function getDirections(
        float $originLat,
        float $originLng,
        float $destLat,
        float $destLng,
        string $mode = 'driving'
    ): ?array {
        $cacheKey = "directions:{$originLat}:{$originLng}:{$destLat}:{$destLng}:{$mode}";

        return Cache::remember($cacheKey, 3600, function () use ($originLat, $originLng, $destLat, $destLng, $mode) {
            try {
                $response = $this->client->get($this->directionsUrl, [
                    'query' => [
                        'origin' => "{$originLat},{$originLng}",
                        'destination' => "{$destLat},{$destLng}",
                        'mode' => $mode,
                        'key' => $this->apiKey,
                        'language' => 'pt-BR',
                    ],
                ]);

                $data = json_decode($response->getBody()->getContents(), true);

                if ($data['status'] !== 'OK' || empty($data['routes'])) {
                    Log::warning('Google Directions API error', ['status' => $data['status']]);
                    return null;
                }

                $route = $data['routes'][0];
                $leg = $route['legs'][0];

                return [
                    'distance' => [
                        'value' => $leg['distance']['value'], // meters
                        'text' => $leg['distance']['text'],
                    ],
                    'duration' => [
                        'value' => $leg['duration']['value'], // seconds
                        'text' => $leg['duration']['text'],
                    ],
                    'polyline' => $route['overview_polyline']['points'],
                    'start_address' => $leg['start_address'],
                    'end_address' => $leg['end_address'],
                    'steps' => array_map(function ($step) {
                        return [
                            'distance' => $step['distance'],
                            'duration' => $step['duration'],
                            'instruction' => $step['html_instructions'],
                            'polyline' => $step['polyline']['points'],
                        ];
                    }, $leg['steps']),
                ];
            } catch (GuzzleException $e) {
                Log::error('Google Directions API request failed', [
                    'error' => $e->getMessage(),
                ]);
                return null;
            }
        });
    }

    /**
     * Get distance matrix between origins and destinations
     */
    public function getDistanceMatrix(
        array $origins,
        array $destinations,
        string $mode = 'driving'
    ): ?array {
        try {
            $originsStr = implode('|', array_map(fn($o) => "{$o[0]},{$o[1]}", $origins));
            $destinationsStr = implode('|', array_map(fn($d) => "{$d[0]},{$d[1]}", $destinations));

            $response = $this->client->get($this->distanceMatrixUrl, [
                'query' => [
                    'origins' => $originsStr,
                    'destinations' => $destinationsStr,
                    'mode' => $mode,
                    'key' => $this->apiKey,
                    'language' => 'pt-BR',
                ],
            ]);

            $data = json_decode($response->getBody()->getContents(), true);

            if ($data['status'] !== 'OK') {
                Log::warning('Google Distance Matrix API error', ['status' => $data['status']]);
                return null;
            }

            return $data;
        } catch (GuzzleException $e) {
            Log::error('Google Distance Matrix API request failed', [
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Geocode an address
     */
    public function geocode(string $address): ?array
    {
        $cacheKey = "geocode:" . md5($address);

        return Cache::remember($cacheKey, 86400, function () use ($address) {
            try {
                $response = $this->client->get($this->geocodingUrl, [
                    'query' => [
                        'address' => $address,
                        'key' => $this->apiKey,
                        'language' => 'pt-BR',
                    ],
                ]);

                $data = json_decode($response->getBody()->getContents(), true);

                if ($data['status'] !== 'OK' || empty($data['results'])) {
                    Log::warning('Google Geocoding API error', ['status' => $data['status']]);
                    return null;
                }

                $result = $data['results'][0];

                return [
                    'latitude' => $result['geometry']['location']['lat'],
                    'longitude' => $result['geometry']['location']['lng'],
                    'formatted_address' => $result['formatted_address'],
                    'place_id' => $result['place_id'],
                    'address_components' => $result['address_components'],
                ];
            } catch (GuzzleException $e) {
                Log::error('Google Geocoding API request failed', [
                    'error' => $e->getMessage(),
                ]);
                return null;
            }
        });
    }

    /**
     * Reverse geocode coordinates
     */
    public function reverseGeocode(float $latitude, float $longitude): ?array
    {
        $cacheKey = "reverse_geocode:{$latitude}:{$longitude}";

        return Cache::remember($cacheKey, 86400, function () use ($latitude, $longitude) {
            try {
                $response = $this->client->get($this->geocodingUrl, [
                    'query' => [
                        'latlng' => "{$latitude},{$longitude}",
                        'key' => $this->apiKey,
                        'language' => 'pt-BR',
                    ],
                ]);

                $data = json_decode($response->getBody()->getContents(), true);

                if ($data['status'] !== 'OK' || empty($data['results'])) {
                    Log::warning('Google Reverse Geocoding API error', ['status' => $data['status']]);
                    return null;
                }

                $result = $data['results'][0];

                return [
                    'formatted_address' => $result['formatted_address'],
                    'place_id' => $result['place_id'],
                    'address_components' => $result['address_components'],
                ];
            } catch (GuzzleException $e) {
                Log::error('Google Reverse Geocoding API request failed', [
                    'error' => $e->getMessage(),
                ]);
                return null;
            }
        });
    }

    /**
     * Calculate distance between two points using Haversine formula (fallback)
     */
    public function calculateDistance(
        float $lat1,
        float $lon1,
        float $lat2,
        float $lon2
    ): float {
        $earthRadius = 6371000; // meters

        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius; // meters
    }
}
