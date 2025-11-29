<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recibo de Corrida #{{ $ride->ride_number }}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Helvetica', 'Arial', sans-serif;
            font-size: 12px;
            color: #333;
            line-height: 1.6;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #6366f1;
        }
        .logo {
            font-size: 32px;
            font-weight: bold;
            color: #6366f1;
            margin-bottom: 5px;
        }
        .subtitle {
            color: #666;
            font-size: 14px;
        }
        .ride-number {
            font-size: 18px;
            font-weight: bold;
            margin: 20px 0 10px;
            color: #333;
        }
        .info-section {
            margin-bottom: 25px;
        }
        .section-title {
            font-size: 14px;
            font-weight: bold;
            color: #6366f1;
            margin-bottom: 10px;
            padding-bottom: 5px;
            border-bottom: 1px solid #e5e7eb;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #f3f4f6;
        }
        .info-label {
            font-weight: 600;
            color: #666;
        }
        .info-value {
            color: #333;
            text-align: right;
        }
        .location-item {
            padding: 10px;
            background: #f9fafb;
            border-radius: 6px;
            margin-bottom: 10px;
        }
        .location-label {
            font-weight: 600;
            color: #6366f1;
            font-size: 11px;
            text-transform: uppercase;
            margin-bottom: 3px;
        }
        .location-address {
            color: #333;
        }
        .price-section {
            background: #f9fafb;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
        }
        .price-row.total {
            font-size: 18px;
            font-weight: bold;
            border-top: 2px solid #6366f1;
            margin-top: 10px;
            padding-top: 15px;
            color: #6366f1;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
            text-align: center;
            color: #666;
            font-size: 11px;
        }
        .driver-info {
            background: #eef2ff;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .driver-name {
            font-weight: bold;
            color: #333;
            font-size: 14px;
        }
        .vehicle-info {
            color: #666;
            font-size: 11px;
            margin-top: 5px;
        }
        .rating {
            display: inline-block;
            background: #fbbf24;
            color: #fff;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <div class="logo">MOBI</div>
            <div class="subtitle">Recibo de Corrida</div>
            <div class="ride-number">Corrida #{{ $ride->ride_number }}</div>
        </div>

        <!-- Ride Info -->
        <div class="info-section">
            <div class="section-title">Informações da Corrida</div>
            <div class="info-row">
                <span class="info-label">Data</span>
                <span class="info-value">{{ $ride->created_at->format('d/m/Y H:i') }}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Categoria</span>
                <span class="info-value">{{ $ride->category->name }}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Distância</span>
                <span class="info-value">{{ number_format($ride->distance_km, 2) }} km</span>
            </div>
            <div class="info-row">
                <span class="info-label">Duração</span>
                <span class="info-value">{{ $ride->duration_minutes }} min</span>
            </div>
            @if($ride->payment_method)
            <div class="info-row">
                <span class="info-label">Forma de Pagamento</span>
                <span class="info-value">{{ ucfirst(str_replace('_', ' ', $ride->payment_method)) }}</span>
            </div>
            @endif
        </div>

        <!-- Driver Info -->
        @if($ride->driver)
        <div class="info-section">
            <div class="section-title">Motorista</div>
            <div class="driver-info">
                <div class="driver-name">
                    {{ $ride->driver->name }}
                    @if($ride->driver->average_rating)
                        <span class="rating">⭐ {{ number_format($ride->driver->average_rating, 1) }}</span>
                    @endif
                </div>
                @if($ride->vehicle)
                <div class="vehicle-info">
                    {{ $ride->vehicle->make }} {{ $ride->vehicle->model }} • {{ $ride->vehicle->color }} • {{ $ride->vehicle->license_plate }}
                </div>
                @endif
            </div>
        </div>
        @endif

        <!-- Locations -->
        <div class="info-section">
            <div class="section-title">Trajeto</div>
            <div class="location-item">
                <div class="location-label">📍 Origem</div>
                <div class="location-address">{{ $ride->pickup_address }}</div>
            </div>
            @if($ride->stops && count($ride->stops) > 0)
                @foreach($ride->stops as $index => $stop)
                <div class="location-item">
                    <div class="location-label">🚩 Parada {{ $index + 1 }}</div>
                    <div class="location-address">{{ $stop['address'] ?? 'Endereço não disponível' }}</div>
                </div>
                @endforeach
            @endif
            <div class="location-item">
                <div class="location-label">🏁 Destino</div>
                <div class="location-address">{{ $ride->dropoff_address }}</div>
            </div>
        </div>

        <!-- Price Breakdown -->
        <div class="price-section">
            <div class="section-title">Detalhamento do Valor</div>
            <div class="price-row">
                <span>Tarifa base</span>
                <span>R$ {{ number_format($ride->base_price, 2, ',', '.') }}</span>
            </div>
            <div class="price-row">
                <span>Distância ({{ number_format($ride->distance_km, 2) }} km)</span>
                <span>R$ {{ number_format($ride->distance_price, 2, ',', '.') }}</span>
            </div>
            <div class="price-row">
                <span>Tempo ({{ $ride->duration_minutes }} min)</span>
                <span>R$ {{ number_format($ride->time_price, 2, ',', '.') }}</span>
            </div>
            @if($ride->surge_multiplier && $ride->surge_multiplier > 1.0)
            <div class="price-row">
                <span>Tarifa dinâmica ({{ number_format($ride->surge_multiplier, 1) }}x)</span>
                <span>R$ {{ number_format(($ride->base_price + $ride->distance_price + $ride->time_price) * ($ride->surge_multiplier - 1), 2, ',', '.') }}</span>
            </div>
            @endif
            @if($ride->discount_amount && $ride->discount_amount > 0)
            <div class="price-row" style="color: #10b981;">
                <span>Desconto</span>
                <span>- R$ {{ number_format($ride->discount_amount, 2, ',', '.') }}</span>
            </div>
            @endif
            @if($ride->tip_amount && $ride->tip_amount > 0)
            <div class="price-row">
                <span>Gorjeta</span>
                <span>R$ {{ number_format($ride->tip_amount, 2, ',', '.') }}</span>
            </div>
            @endif
            <div class="price-row total">
                <span>Total</span>
                <span>R$ {{ number_format($ride->final_price, 2, ',', '.') }}</span>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p><strong>MOBI - Mobilidade Urbana</strong></p>
            <p>www.mobi.com.br | contato@mobi.com.br</p>
            <p>Este é um documento fiscal simplificado</p>
            <p style="margin-top: 10px; font-size: 10px;">Emitido em {{ now()->format('d/m/Y H:i:s') }}</p>
        </div>
    </div>
</body>
</html>
