import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String format, DateTime date) {
    return DateFormat(format, "id_ID").format(date);
  }
}
