import 'package:intl/intl.dart';

/// Helper class for money calculations and formatting
/// Uses integers internally to avoid floating point precision issues
class MoneyHelper {
  /// Convert double to cents (integer)
  static int toCents(double value) {
    return (value * 100).round();
  }

  /// Convert cents (integer) to double
  static double fromCents(int cents) {
    return cents / 100.0;
  }

  /// Add two monetary values
  static double add(double a, double b) {
    final centsA = toCents(a);
    final centsB = toCents(b);
    return fromCents(centsA + centsB);
  }

  /// Subtract two monetary values
  static double subtract(double a, double b) {
    final centsA = toCents(a);
    final centsB = toCents(b);
    return fromCents(centsA - centsB);
  }

  /// Multiply monetary value by a factor
  static double multiply(double value, double factor) {
    final cents = toCents(value);
    final result = (cents * factor).round();
    return fromCents(result);
  }

  /// Divide monetary value by a factor
  static double divide(double value, double divisor) {
    if (divisor == 0) return 0;
    final cents = toCents(value);
    final result = (cents / divisor).round();
    return fromCents(result);
  }

  /// Calculate percentage of a value
  static double percentage(double value, double percent) {
    return multiply(value, percent / 100);
  }

  /// Calculate value after discount
  static double applyDiscount(double value, double discountPercent) {
    final discount = percentage(value, discountPercent);
    return subtract(value, discount);
  }

  /// Calculate value after adding percentage
  static double addPercentage(double value, double percent) {
    final addition = percentage(value, percent);
    return add(value, addition);
  }

  /// Round to 2 decimal places
  static double roundTo2Decimals(double value) {
    return fromCents(toCents(value));
  }

  /// Format as Brazilian Real (R$ 1.234,56)
  static String formatBRL(double value, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: showSymbol ? 'R\$' : '',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Format as compact BRL (R$ 1,2 mil ou R$ 1,2 M)
  static String formatCompactBRL(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)} mil';
    } else {
      return formatBRL(value);
    }
  }

  /// Parse Brazilian currency string to double
  /// Examples: "R$ 1.234,56" -> 1234.56, "1.234,56" -> 1234.56
  static double? parseBRL(String value) {
    try {
      // Remove currency symbol and spaces
      String cleaned = value
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .trim();

      // Replace comma with dot (Brazilian format uses comma as decimal separator)
      // Remove thousand separators (dots)
      if (cleaned.contains(',')) {
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      }

      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Split amount equally among participants
  /// Returns list of amounts (may have slight variations due to rounding)
  static List<double> splitEqually(double total, int participants) {
    if (participants <= 0) return [];

    final totalCents = toCents(total);
    final baseAmountCents = totalCents ~/ participants;
    final remainder = totalCents % participants;

    final amounts = List<double>.filled(participants, fromCents(baseAmountCents));

    // Distribute remainder (1 cent to first N participants)
    for (int i = 0; i < remainder; i++) {
      amounts[i] = add(amounts[i], 0.01);
    }

    return amounts;
  }

  /// Split amount by percentages
  /// Example: splitByPercentages(100, [30, 40, 30]) -> [30.00, 40.00, 30.00]
  static List<double> splitByPercentages(
    double total,
    List<double> percentages,
  ) {
    if (percentages.isEmpty) return [];

    // Validate percentages sum to 100
    final sum = percentages.reduce((a, b) => a + b);
    if ((sum - 100).abs() > 0.01) {
      throw ArgumentError('Percentages must sum to 100');
    }

    final totalCents = toCents(total);
    final amounts = <double>[];
    int allocatedCents = 0;

    // Calculate all except last
    for (int i = 0; i < percentages.length - 1; i++) {
      final amountCents = (totalCents * percentages[i] / 100).round();
      amounts.add(fromCents(amountCents));
      allocatedCents += amountCents;
    }

    // Last amount gets the remainder to avoid rounding errors
    final lastAmountCents = totalCents - allocatedCents;
    amounts.add(fromCents(lastAmountCents));

    return amounts;
  }

  /// Split amount by custom values
  /// Validates that sum equals total
  static bool validateCustomSplit(double total, List<double> amounts) {
    if (amounts.isEmpty) return false;

    final totalCents = toCents(total);
    final sumCents = amounts.map(toCents).reduce((a, b) => a + b);

    return totalCents == sumCents;
  }

  /// Calculate tip amount based on percentage
  static double calculateTip(double billAmount, double tipPercent) {
    return percentage(billAmount, tipPercent);
  }

  /// Calculate total with tip
  static double totalWithTip(double billAmount, double tipPercent) {
    return add(billAmount, calculateTip(billAmount, tipPercent));
  }

  /// Calculate service fee based on percentage
  static double calculateServiceFee(double amount, double feePercent) {
    return percentage(amount, feePercent);
  }

  /// Calculate net amount after service fee
  static double netAfterServiceFee(double amount, double feePercent) {
    final fee = calculateServiceFee(amount, feePercent);
    return subtract(amount, fee);
  }

  /// Compare two monetary values with tolerance
  static bool isEqual(double a, double b, {double tolerance = 0.01}) {
    return (a - b).abs() <= tolerance;
  }

  /// Check if value is greater than another
  static bool isGreaterThan(double a, double b) {
    return toCents(a) > toCents(b);
  }

  /// Check if value is less than another
  static bool isLessThan(double a, double b) {
    return toCents(a) < toCents(b);
  }

  /// Check if value is greater than or equal to another
  static bool isGreaterThanOrEqual(double a, double b) {
    return toCents(a) >= toCents(b);
  }

  /// Check if value is less than or equal to another
  static bool isLessThanOrEqual(double a, double b) {
    return toCents(a) <= toCents(b);
  }

  /// Get maximum of two values
  static double max(double a, double b) {
    return isGreaterThan(a, b) ? a : b;
  }

  /// Get minimum of two values
  static double min(double a, double b) {
    return isLessThan(a, b) ? a : b;
  }

  /// Calculate change to return
  static double calculateChange(double paid, double owed) {
    return max(0, subtract(paid, owed));
  }

  /// Check if amount is positive
  static bool isPositive(double value) {
    return toCents(value) > 0;
  }

  /// Check if amount is negative
  static bool isNegative(double value) {
    return toCents(value) < 0;
  }

  /// Check if amount is zero
  static bool isZero(double value, {double tolerance = 0.01}) {
    return value.abs() <= tolerance;
  }

  /// Clamp value between min and max
  static double clamp(double value, double min, double max) {
    if (isLessThan(value, min)) return min;
    if (isGreaterThan(value, max)) return max;
    return value;
  }

  /// Format with custom decimal places
  static String formatWithDecimals(double value, int decimals) {
    return value.toStringAsFixed(decimals);
  }

  /// Calculate average of amounts
  static double average(List<double> amounts) {
    if (amounts.isEmpty) return 0;

    final totalCents = amounts.map(toCents).reduce((a, b) => a + b);
    return fromCents(totalCents ~/ amounts.length);
  }

  /// Sum list of amounts
  static double sum(List<double> amounts) {
    if (amounts.isEmpty) return 0;

    final totalCents = amounts.map(toCents).reduce((a, b) => a + b);
    return fromCents(totalCents);
  }

  /// Calculate platform fee (commission)
  /// Example: amount = 100, platformPercent = 10, driverPercent = 90
  /// Returns {platform: 10.00, driver: 90.00}
  static Map<String, double> calculateCommissionSplit(
    double amount,
    double platformPercent,
  ) {
    final platformFee = percentage(amount, platformPercent);
    final driverAmount = subtract(amount, platformFee);

    return {
      'platform': platformFee,
      'driver': driverAmount,
    };
  }

  /// Format as input mask for currency (R$ 0,00)
  static String formatAsCurrencyInput(String input) {
    // Remove non-digits
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) return 'R\$ 0,00';

    // Convert to cents
    final cents = int.parse(digits);
    final value = fromCents(cents);

    return formatBRL(value);
  }

  /// Validate credit card amount (not negative, not too large)
  static bool isValidPaymentAmount(double amount, {double maxAmount = 999999.99}) {
    return isPositive(amount) && isLessThanOrEqual(amount, maxAmount);
  }

  /// Calculate discount amount
  static double calculateDiscountAmount(double original, double discounted) {
    return max(0, subtract(original, discounted));
  }

  /// Calculate discount percentage
  static double calculateDiscountPercent(double original, double discounted) {
    if (isZero(original)) return 0;
    final discount = calculateDiscountAmount(original, discounted);
    return (discount / original) * 100;
  }

  /// Format savings (e.g., "Você economizou R$ 10,00")
  static String formatSavings(double savings) {
    if (isZero(savings) || isNegative(savings)) {
      return '';
    }
    return 'Você economizou ${formatBRL(savings)}';
  }

  /// Calculate price per unit
  static double pricePerUnit(double totalPrice, double quantity) {
    if (quantity <= 0) return 0;
    return divide(totalPrice, quantity);
  }
}
