import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    final emailRegex = RegExp(AppConstants.emailRegex);
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Senha deve ter no mínimo ${AppConstants.minPasswordLength} caracteres';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Senha deve ter no máximo ${AppConstants.maxPasswordLength} caracteres';
    }

    // Must contain at least one uppercase, one lowercase, and one number
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }

    // Remove non-numeric characters
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length < 10 || numbers.length > 11) {
      return 'Telefone inválido';
    }

    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    // Remove non-numeric characters
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Check if all digits are the same
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
      return 'CPF inválido';
    }

    // Validate CPF algorithm
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(numbers[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;

    if (int.parse(numbers[9]) != firstDigit) {
      return 'CPF inválido';
    }

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(numbers[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;

    if (int.parse(numbers[10]) != secondDigit) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }

    if (value.length < 3) {
      return 'Nome deve ter no mínimo 3 caracteres';
    }

    if (!value.contains(' ')) {
      return 'Digite o nome completo';
    }

    return null;
  }

  static String? validateRequired(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? validateRating(int? value) {
    if (value == null) {
      return 'Avaliação é obrigatória';
    }

    if (value < AppConstants.minRideRating ||
        value > AppConstants.maxRideRating) {
      return 'Avaliação deve estar entre ${AppConstants.minRideRating} e ${AppConstants.maxRideRating}';
    }

    return null;
  }

  /// Validate RENAVAM (vehicle registration number)
  static String? validateRENAVAM(String? value) {
    if (value == null || value.isEmpty) {
      return 'RENAVAM é obrigatório';
    }

    // Remove non-numeric characters
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length != 11) {
      return 'RENAVAM deve ter 11 dígitos';
    }

    // Validate RENAVAM algorithm
    const sequence = '3298765432';
    int sum = 0;

    for (int i = 0; i < 10; i++) {
      sum += int.parse(numbers[i]) * int.parse(sequence[i]);
    }

    final digit = sum % 11;
    final expectedDigit = digit >= 10 ? 0 : digit;

    if (int.parse(numbers[10]) != expectedDigit) {
      return 'RENAVAM inválido';
    }

    return null;
  }

  /// Validate credit card expiry date (MM/YY format)
  static String? validateCardExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de validade é obrigatória';
    }

    // Remove non-numeric characters except /
    final cleaned = value.replaceAll(RegExp(r'[^0-9/]'), '');

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(cleaned)) {
      return 'Formato inválido (use MM/AA)';
    }

    final parts = cleaned.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return 'Data inválida';
    }

    if (month < 1 || month > 12) {
      return 'Mês inválido';
    }

    // Check if expired
    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last 2 digits
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Cartão expirado';
    }

    return null;
  }

  /// Validate credit card CVV
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV é obrigatório';
    }

    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length < 3 || numbers.length > 4) {
      return 'CVV deve ter 3 ou 4 dígitos';
    }

    return null;
  }

  /// Validate credit card number
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número do cartão é obrigatório';
    }

    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length < 13 || numbers.length > 19) {
      return 'Número do cartão inválido';
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;

    for (int i = numbers.length - 1; i >= 0; i--) {
      int digit = int.parse(numbers[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      return 'Número do cartão inválido';
    }

    return null;
  }

  /// Validate referral code format
  static String? validateReferralCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Código de referência é obrigatório';
    }

    // Referral codes are 8-10 characters alphanumeric
    if (value.length < 8 || value.length > 10) {
      return 'Código deve ter entre 8 e 10 caracteres';
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.toUpperCase())) {
      return 'Código deve conter apenas letras e números';
    }

    return null;
  }

  /// Validate scheduled ride datetime (not in the past, within limits)
  static String? validateScheduledDateTime(DateTime? value) {
    if (value == null) {
      return 'Data e hora são obrigatórias';
    }

    final now = DateTime.now();

    // Must be at least 30 minutes in the future
    final minTime = now.add(const Duration(minutes: 30));
    if (value.isBefore(minTime)) {
      return 'Agendamento deve ser com pelo menos 30 minutos de antecedência';
    }

    // Must be within 30 days
    final maxTime = now.add(const Duration(days: 30));
    if (value.isAfter(maxTime)) {
      return 'Agendamento não pode ser superior a 30 dias';
    }

    return null;
  }

  /// Validate coordinates (latitude/longitude)
  static String? validateLatitude(double? value) {
    if (value == null) {
      return 'Latitude é obrigatória';
    }

    if (value < -90 || value > 90) {
      return 'Latitude inválida';
    }

    return null;
  }

  static String? validateLongitude(double? value) {
    if (value == null) {
      return 'Longitude é obrigatória';
    }

    if (value < -180 || value > 180) {
      return 'Longitude inválida';
    }

    return null;
  }

  /// Validate payment amount
  static String? validatePaymentAmount(double? value) {
    if (value == null) {
      return 'Valor é obrigatório';
    }

    if (value <= 0) {
      return 'Valor deve ser maior que zero';
    }

    if (value > 999999.99) {
      return 'Valor muito alto';
    }

    return null;
  }

  /// Validate distance in kilometers
  static String? validateDistance(double? value) {
    if (value == null) {
      return 'Distância é obrigatória';
    }

    if (value <= 0) {
      return 'Distância deve ser maior que zero';
    }

    // Maximum reasonable distance for a ride: 500km
    if (value > 500) {
      return 'Distância muito grande (máximo 500km)';
    }

    return null;
  }

  /// Validate vehicle plate (Brazilian format)
  static String? validateVehiclePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Placa é obrigatória';
    }

    // Remove non-alphanumeric characters
    final cleaned = value.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();

    // Old format: ABC1234 or Mercosul format: ABC1D23
    if (!RegExp(r'^[A-Z]{3}\d{1}[A-Z0-9]{1}\d{2}$').hasMatch(cleaned) &&
        !RegExp(r'^[A-Z]{3}\d{4}$').hasMatch(cleaned)) {
      return 'Placa inválida';
    }

    return null;
  }

  /// Validate CNH (driver's license)
  static String? validateCNH(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNH é obrigatória';
    }

    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length != 11) {
      return 'CNH deve ter 11 dígitos';
    }

    // Check if all digits are the same
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
      return 'CNH inválida';
    }

    // Validate CNH algorithm
    int sum = 0;
    int factor = 9;

    for (int i = 0; i < 9; i++) {
      sum += int.parse(numbers[i]) * factor;
      factor--;
    }

    int firstDigit = sum % 11;
    if (firstDigit >= 10) firstDigit = 0;

    if (int.parse(numbers[9]) != firstDigit) {
      return 'CNH inválida';
    }

    sum = 0;
    factor = 1;

    for (int i = 0; i < 9; i++) {
      sum += int.parse(numbers[i]) * factor;
      factor++;
    }

    int secondDigit = sum % 11;
    if (secondDigit >= 10) secondDigit = 0;

    if (int.parse(numbers[10]) != secondDigit) {
      return 'CNH inválida';
    }

    return null;
  }

  /// Validate URL
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'URL inválida';
    }

    return null;
  }

  /// Validate price range
  static String? validatePriceRange(double? min, double? max) {
    if (min != null && max != null && min > max) {
      return 'Preço mínimo não pode ser maior que o máximo';
    }

    return null;
  }

  /// Validate age (for driver minimum age, etc)
  static String? validateAge(DateTime? birthDate, {int minAge = 18}) {
    if (birthDate == null) {
      return 'Data de nascimento é obrigatória';
    }

    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < minAge) {
      return 'Idade mínima: $minAge anos';
    }

    if (age > 120) {
      return 'Data de nascimento inválida';
    }

    return null;
  }

  /// Validate percentage (0-100)
  static String? validatePercentage(double? value) {
    if (value == null) {
      return 'Porcentagem é obrigatória';
    }

    if (value < 0 || value > 100) {
      return 'Porcentagem deve estar entre 0 e 100';
    }

    return null;
  }
}
