import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  static String formatCPF(String cpf) {
    if (cpf.length != 11) return cpf;

    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  static String formatPhone(String phone) {
    // Remove non-numeric characters
    final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length == 10) {
      // Format: (11) 1234-5678
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    } else if (numbers.length == 11) {
      // Format: (11) 91234-5678
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    }

    return phone;
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(date);
  }

  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm', 'pt_BR');
    return formatter.format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return formatter.format(dateTime);
  }

  static String formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);

    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes}min';
    } else {
      return '${duration.inMinutes} min';
    }
  }

  static String formatRideStatus(String status) {
    switch (status) {
      case 'searching':
        return 'Procurando motorista';
      case 'accepted':
        return 'Motorista a caminho';
      case 'arrived':
        return 'Motorista chegou';
      case 'in_progress':
        return 'Em andamento';
      case 'completed':
        return 'Concluída';
      case 'cancelled':
        return 'Cancelada';
      case 'no_driver_found':
        return 'Sem motorista disponível';
      default:
        return status;
    }
  }

  static String formatPaymentType(String type) {
    switch (type) {
      case 'pix':
        return 'PIX';
      case 'credit_card':
        return 'Cartão de Crédito';
      case 'debit_card':
        return 'Cartão de Débito';
      case 'cash':
        return 'Dinheiro';
      default:
        return type;
    }
  }

  static String formatPaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'processing':
        return 'Processando';
      case 'completed':
        return 'Concluído';
      case 'failed':
        return 'Falhou';
      case 'refunded':
        return 'Reembolsado';
      default:
        return status;
    }
  }

  static String formatCardNumber(String cardNumber) {
    // Mask card number: **** **** **** 1234
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 1) {
      return 'Há ${difference.inDays} dias';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inHours > 1) {
      return 'Há ${difference.inHours} horas';
    } else if (difference.inHours == 1) {
      return 'Há 1 hora';
    } else if (difference.inMinutes > 1) {
      return 'Há ${difference.inMinutes} minutos';
    } else {
      return 'Agora';
    }
  }

  // Alias for formatRideStatus
  static String formatStatus(String status) => formatRideStatus(status);
}
