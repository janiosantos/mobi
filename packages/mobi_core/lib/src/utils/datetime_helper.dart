import 'package:intl/intl.dart';

/// Helper class for date and time manipulation
class DateTimeHelper {
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Check if date is within a specific range
  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end) ||
        date.isAtSameMomentAs(start) ||
        date.isAtSameMomentAs(end);
  }

  /// Format date relative to now (e.g., "Hoje", "Ontem", "2 dias atrás")
  static String formatRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Hoje';
    } else if (isYesterday(date)) {
      return 'Ontem';
    } else if (isTomorrow(date)) {
      return 'Amanhã';
    }

    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0 && difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 0 && difference.inDays > -7) {
      return 'Em ${difference.inDays.abs()} dias';
    } else if (difference.inDays >= 7 && difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < -7 && difference.inDays > -30) {
      final weeks = (difference.inDays.abs() / 7).floor();
      return 'Em $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Format date time relative to now with time (e.g., "Hoje às 14:30", "Ontem às 09:15")
  static String formatRelativeDateTime(DateTime dateTime) {
    final timeStr = DateFormat('HH:mm').format(dateTime);
    final dateStr = formatRelativeDate(dateTime);

    if (dateStr == 'Hoje' || dateStr == 'Ontem' || dateStr == 'Amanhã') {
      return '$dateStr às $timeStr';
    }

    return '$dateStr às $timeStr';
  }

  /// Format time ago (e.g., "2 minutos atrás", "1 hora atrás")
  static String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'} atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'} atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'} atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  /// Format duration in human-readable format (e.g., "2h 30min", "45min")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format duration in short format (e.g., "2:30", "0:45")
  static String formatDurationShort(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get weekday name in Portuguese
  static String getWeekdayName(DateTime date, {bool short = false}) {
    const fullNames = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];

    const shortNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    final weekday = date.weekday - 1;
    return short ? shortNames[weekday] : fullNames[weekday];
  }

  /// Get month name in Portuguese
  static String getMonthName(int month, {bool short = false}) {
    const fullNames = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    const shortNames = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    return short ? shortNames[month - 1] : fullNames[month - 1];
  }

  /// Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Check if is business day (Monday-Friday)
  static bool isBusinessDay(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  /// Check if is weekend (Saturday-Sunday)
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Add business days (skipping weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (isBusinessDay(result)) {
        addedDays++;
      }
    }

    return result;
  }

  /// Format time remaining (e.g., "5 min", "2 horas")
  static String formatTimeRemaining(Duration remaining) {
    if (remaining.isNegative) {
      return 'Expirado';
    }

    if (remaining.inDays > 0) {
      return '${remaining.inDays} ${remaining.inDays == 1 ? 'dia' : 'dias'}';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} ${remaining.inHours == 1 ? 'hora' : 'horas'}';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} min';
    } else {
      return '${remaining.inSeconds} seg';
    }
  }

  /// Parse date string with multiple formats support
  static DateTime? parseFlexible(String dateStr) {
    // Try ISO 8601
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      // Ignore
    }

    // Try Brazilian format (dd/MM/yyyy)
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      // Ignore
    }

    // Try US format (MM/dd/yyyy)
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Ignore
    }

    return null;
  }

  /// Check if datetime is within business hours (8am-6pm)
  static bool isBusinessHours(DateTime dateTime) {
    return dateTime.hour >= 8 && dateTime.hour < 18 && isBusinessDay(dateTime);
  }

  /// Round datetime to nearest minute
  static DateTime roundToMinute(DateTime dateTime) {
    if (dateTime.second >= 30) {
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute + 1,
      );
    } else {
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
      );
    }
  }

  /// Round datetime to nearest 5 minutes
  static DateTime roundToNearestFiveMinutes(DateTime dateTime) {
    final minutes = (dateTime.minute / 5).round() * 5;
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      minutes,
    );
  }

  /// Format date for API (YYYY-MM-DD)
  static String formatForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format datetime for API (ISO 8601)
  static String formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
