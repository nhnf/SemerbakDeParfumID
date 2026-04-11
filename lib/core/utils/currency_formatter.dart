import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(int amount) {
    return NumberFormat.decimalPattern('id').format(amount);
  }

  static String formatWithSymbol(int amount) {
    return 'Rp ${NumberFormat.decimalPattern('id').format(amount)}';
  }
}
