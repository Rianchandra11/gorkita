import 'package:intl/intl.dart';

class NumberFormatter {
  static String currency(num number, {String symbol = "Rp. "}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(number);
  }
}
