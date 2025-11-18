<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Ride Configuration
    |--------------------------------------------------------------------------
    */
    'ride' => [
        'search_radius' => env('RIDE_SEARCH_RADIUS', 5000), // meters
        'acceptance_timeout' => env('RIDE_ACCEPTANCE_TIMEOUT', 60), // seconds
        'waiting_timeout' => env('RIDE_WAITING_TIMEOUT', 300), // seconds
        'cancel_penalty' => env('RIDE_CANCEL_PENALTY', 5.00), // BRL
        'location_update_interval' => env('DRIVER_LOCATION_UPDATE_INTERVAL', 5), // seconds
    ],

    /*
    |--------------------------------------------------------------------------
    | Pricing Configuration
    |--------------------------------------------------------------------------
    */
    'pricing' => [
        'base_fare' => env('BASE_FARE', 5.00), // BRL
        'price_per_km' => env('PRICE_PER_KM', 2.50), // BRL
        'price_per_minute' => env('PRICE_PER_MINUTE', 0.50), // BRL
        'minimum_fare' => env('MINIMUM_FARE', 8.00), // BRL
        'surge_pricing_enabled' => env('SURGE_PRICING_ENABLED', true),
        'surge_max_multiplier' => env('SURGE_MAX_MULTIPLIER', 3.0),
    ],

    /*
    |--------------------------------------------------------------------------
    | Commission Configuration
    |--------------------------------------------------------------------------
    */
    'commission' => [
        'platform_percentage' => env('PLATFORM_COMMISSION_PERCENTAGE', 25), // %
        'driver_payout_frequency' => env('DRIVER_PAYOUT_FREQUENCY', 'weekly'), // daily, weekly, monthly
    ],

    /*
    |--------------------------------------------------------------------------
    | Driver Configuration
    |--------------------------------------------------------------------------
    */
    'driver' => [
        'approval_required' => env('DRIVER_APPROVAL_REQUIRED', true),
        'document_verification_provider' => env('DOCUMENT_VERIFICATION_PROVIDER', 'manual'), // manual, aws_rekognition
        'minimum_rating' => 3.0,
        'documents_required' => [
            'cnh', // CNH (Carteira Nacional de Habilitação)
            'crlv', // CRLV (Certificado de Registro e Licenciamento de Veículo)
            'profile_photo',
            'vehicle_photo',
            'criminal_record', // Antecedentes Criminais
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Payment Configuration
    |--------------------------------------------------------------------------
    */
    'payment' => [
        'methods' => [
            'pix' => true,
            'credit_card' => true,
            'debit_card' => true,
            'cash' => false,
        ],
        'default_method' => 'pix',
    ],

    /*
    |--------------------------------------------------------------------------
    | Notification Configuration
    |--------------------------------------------------------------------------
    */
    'notifications' => [
        'channels' => [
            'push' => true,
            'sms' => false,
            'email' => true,
        ],
        'events' => [
            'ride_requested' => ['push', 'email'],
            'ride_accepted' => ['push'],
            'ride_started' => ['push'],
            'ride_completed' => ['push', 'email'],
            'ride_cancelled' => ['push', 'email'],
            'payment_received' => ['push', 'email'],
            'driver_approved' => ['push', 'email'],
            'driver_rejected' => ['email'],
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Rating Configuration
    |--------------------------------------------------------------------------
    */
    'rating' => [
        'min_value' => 1,
        'max_value' => 5,
        'required_for_completion' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Rate Limiting
    |--------------------------------------------------------------------------
    */
    'rate_limit' => [
        'api' => env('API_RATE_LIMIT', 60),
        'driver_location' => env('API_RATE_LIMIT_DRIVER', 120),
    ],

    /*
    |--------------------------------------------------------------------------
    | Vehicle Categories
    |--------------------------------------------------------------------------
    */
    'vehicle_categories' => [
        'economy' => [
            'name' => 'Econômico',
            'base_multiplier' => 1.0,
            'icon' => 'car',
        ],
        'comfort' => [
            'name' => 'Conforto',
            'base_multiplier' => 1.3,
            'icon' => 'car-luxury',
        ],
        'premium' => [
            'name' => 'Premium',
            'base_multiplier' => 1.8,
            'icon' => 'car-sports',
        ],
        'xl' => [
            'name' => 'XL (6 lugares)',
            'base_multiplier' => 1.5,
            'icon' => 'van',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Application URLs
    |--------------------------------------------------------------------------
    */
    'urls' => [
        'frontend' => env('FRONTEND_URL', 'http://localhost:3000'),
        'passenger_app' => env('PASSENGER_APP_URL', 'mobi://passenger'),
        'driver_app' => env('DRIVER_APP_URL', 'mobi://driver'),
    ],

];
