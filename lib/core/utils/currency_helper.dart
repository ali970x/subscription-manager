import 'package:intl/intl.dart';

class CurrencyHelper {
  static const currencies = ['USD', 'EUR', 'LBP', 'SAR', 'EGP', 'MAD', 'AED'];

  // Offline reference rates: value of one unit in USD. Editable in future versions.
  static const usdRates = <String, double>{
    'USD': 1,
    'EUR': 1.08,
    'LBP': 0.00001117,
    'SAR': 0.2667,
    'EGP': 0.0202,
    'MAD': 0.101,
    'AED': 0.2723,
  };

  static double convert(double value, String from, String to) {
    final usd = value * (usdRates[from] ?? 1);
    return usd / (usdRates[to] ?? 1);
  }

  static String format(double value, String currency, {String locale = 'en'}) {
    try {
      return NumberFormat.simpleCurrency(
        name: currency,
        locale: locale,
      ).format(value);
    } catch (_) {
      return '${value.toStringAsFixed(2)} $currency';
    }
  }
}
