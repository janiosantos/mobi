<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recibo da sua corrida - MOBI</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Helvetica', 'Arial', sans-serif;
            background-color: #f3f4f6;
            padding: 20px;
        }
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            color: #ffffff;
            padding: 30px 20px;
            text-align: center;
        }
        .logo {
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .header-subtitle {
            font-size: 16px;
            opacity: 0.9;
        }
        .content {
            padding: 30px 20px;
        }
        .greeting {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
        }
        .message {
            color: #666;
            line-height: 1.6;
            margin-bottom: 25px;
        }
        .ride-summary {
            background: #f9fafb;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .ride-number {
            font-size: 14px;
            color: #6366f1;
            font-weight: 600;
            margin-bottom: 15px;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        .summary-row:last-child {
            border-bottom: none;
        }
        .summary-label {
            color: #666;
            font-size: 14px;
        }
        .summary-value {
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }
        .total-row {
            background: #eef2ff;
            padding: 15px;
            border-radius: 6px;
            margin-top: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .total-label {
            font-size: 16px;
            font-weight: 600;
            color: #333;
        }
        .total-value {
            font-size: 24px;
            font-weight: bold;
            color: #6366f1;
        }
        .button {
            display: inline-block;
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            color: #ffffff;
            padding: 14px 30px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            margin: 20px 0;
            text-align: center;
        }
        .button:hover {
            opacity: 0.9;
        }
        .locations {
            margin: 25px 0;
        }
        .location-item {
            padding: 12px;
            background: #f9fafb;
            border-left: 4px solid #6366f1;
            margin-bottom: 10px;
            border-radius: 4px;
        }
        .location-label {
            font-size: 12px;
            color: #6366f1;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .location-address {
            color: #333;
            font-size: 14px;
        }
        .footer {
            background: #f9fafb;
            padding: 25px 20px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
        }
        .footer-text {
            color: #666;
            font-size: 12px;
            line-height: 1.6;
        }
        .footer-links {
            margin-top: 15px;
        }
        .footer-link {
            color: #6366f1;
            text-decoration: none;
            margin: 0 10px;
            font-size: 12px;
        }
        .social-links {
            margin-top: 15px;
        }
        .social-link {
            display: inline-block;
            margin: 0 5px;
            color: #666;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <!-- Header -->
        <div class="header">
            <div class="logo">MOBI</div>
            <div class="header-subtitle">Recibo da sua corrida</div>
        </div>

        <!-- Content -->
        <div class="content">
            <div class="greeting">Olá, {{ $ride->passenger->name }}!</div>

            <div class="message">
                Obrigado por escolher a MOBI! Sua corrida foi concluída com sucesso.
                Segue abaixo o resumo e o recibo detalhado da sua viagem.
            </div>

            <!-- Ride Summary -->
            <div class="ride-summary">
                <div class="ride-number">Corrida #{{ $ride->ride_number }}</div>

                <div class="summary-row">
                    <span class="summary-label">Data</span>
                    <span class="summary-value">{{ $ride->created_at->format('d/m/Y H:i') }}</span>
                </div>

                <div class="summary-row">
                    <span class="summary-label">Categoria</span>
                    <span class="summary-value">{{ $ride->category->name }}</span>
                </div>

                @if($ride->driver)
                <div class="summary-row">
                    <span class="summary-label">Motorista</span>
                    <span class="summary-value">{{ $ride->driver->name }}</span>
                </div>
                @endif

                <div class="summary-row">
                    <span class="summary-label">Distância</span>
                    <span class="summary-value">{{ number_format($ride->distance_km, 2) }} km</span>
                </div>

                <div class="summary-row">
                    <span class="summary-label">Duração</span>
                    <span class="summary-value">{{ $ride->duration_minutes }} min</span>
                </div>
            </div>

            <!-- Locations -->
            <div class="locations">
                <div class="location-item">
                    <div class="location-label">📍 Origem</div>
                    <div class="location-address">{{ $ride->pickup_address }}</div>
                </div>
                <div class="location-item">
                    <div class="location-label">🏁 Destino</div>
                    <div class="location-address">{{ $ride->dropoff_address }}</div>
                </div>
            </div>

            <!-- Total -->
            <div class="total-row">
                <span class="total-label">Valor Total</span>
                <span class="total-value">R$ {{ number_format($ride->final_price, 2, ',', '.') }}</span>
            </div>

            @if($ride->payment_method)
            <div class="message" style="margin-top: 15px; font-size: 13px; color: #666;">
                Forma de pagamento: <strong>{{ ucfirst(str_replace('_', ' ', $ride->payment_method)) }}</strong>
            </div>
            @endif

            <!-- Download Button -->
            <div style="text-align: center;">
                <a href="{{ $receipt_url ?? '#' }}" class="button">
                    📄 Baixar Recibo Completo
                </a>
            </div>

            <div class="message" style="margin-top: 25px;">
                Esperamos que tenha tido uma ótima experiência! Sua opinião é muito importante para nós.
            </div>

            @if(!$ride->ratings()->where('rater_id', $ride->passenger_id)->exists())
            <div style="text-align: center;">
                <a href="{{ config('app.url') }}/rides/{{ $ride->id }}/rate" class="button" style="background: #10b981;">
                    ⭐ Avaliar Motorista
                </a>
            </div>
            @endif
        </div>

        <!-- Footer -->
        <div class="footer">
            <div class="footer-text">
                <strong>MOBI - Mobilidade Urbana</strong><br>
                Conectando pessoas de forma rápida, segura e acessível.
            </div>

            <div class="footer-links">
                <a href="{{ config('app.url') }}" class="footer-link">Site</a>
                <a href="{{ config('app.url') }}/help" class="footer-link">Central de Ajuda</a>
                <a href="{{ config('app.url') }}/privacy" class="footer-link">Privacidade</a>
            </div>

            <div class="social-links">
                <a href="#" class="social-link">Facebook</a> •
                <a href="#" class="social-link">Instagram</a> •
                <a href="#" class="social-link">Twitter</a>
            </div>

            <div class="footer-text" style="margin-top: 15px; font-size: 11px;">
                Este é um e-mail automático, por favor não responda.<br>
                Para suporte, entre em contato em <a href="mailto:contato@mobi.com.br" style="color: #6366f1;">contato@mobi.com.br</a>
            </div>
        </div>
    </div>
</body>
</html>
