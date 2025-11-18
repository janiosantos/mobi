<?php

return [

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'google' => [
        'maps' => [
            'api_key' => env('GOOGLE_MAPS_API_KEY'),
        ],
        'geocoding' => [
            'api_key' => env('GOOGLE_GEOCODING_API_KEY', env('GOOGLE_MAPS_API_KEY')),
        ],
        'directions' => [
            'api_key' => env('GOOGLE_DIRECTIONS_API_KEY', env('GOOGLE_MAPS_API_KEY')),
        ],
        'distance_matrix' => [
            'api_key' => env('GOOGLE_DISTANCE_MATRIX_API_KEY', env('GOOGLE_MAPS_API_KEY')),
        ],
        'places' => [
            'api_key' => env('GOOGLE_PLACES_API_KEY', env('GOOGLE_MAPS_API_KEY')),
        ],
    ],

    'mercadopago' => [
        'public_key' => env('MERCADOPAGO_PUBLIC_KEY'),
        'access_token' => env('MERCADOPAGO_ACCESS_TOKEN'),
        'webhook_secret' => env('MERCADOPAGO_WEBHOOK_SECRET'),
        'sandbox' => env('MERCADOPAGO_SANDBOX', true),
    ],

    'fcm' => [
        'server_key' => env('FCM_SERVER_KEY'),
        'sender_id' => env('FCM_SENDER_ID'),
    ],

    'twilio' => [
        'sid' => env('TWILIO_SID'),
        'auth_token' => env('TWILIO_AUTH_TOKEN'),
        'from' => env('TWILIO_FROM'),
    ],

];
