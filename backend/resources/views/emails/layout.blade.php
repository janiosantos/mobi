<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $subject ?? 'MOBI' }}</title>
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
            line-height: 1.6;
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
            color: #333;
        }
        .greeting {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
        }
        .message {
            color: #666;
            margin-bottom: 20px;
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
    </style>
</head>
<body>
    <div class="email-container">
        <!-- Header -->
        <div class="header">
            <div class="logo">MOBI</div>
            @if(isset($header_subtitle))
                <div class="header-subtitle">{{ $header_subtitle }}</div>
            @endif
        </div>

        <!-- Content -->
        <div class="content">
            @yield('content')
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

            <div class="footer-text" style="margin-top: 15px; font-size: 11px;">
                Este é um e-mail automático, por favor não responda.<br>
                Para suporte, entre em contato em <a href="mailto:contato@mobi.com.br" style="color: #6366f1;">contato@mobi.com.br</a>
            </div>
        </div>
    </div>
</body>
</html>
