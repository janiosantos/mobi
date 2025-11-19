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
}
