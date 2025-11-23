extension DateTimeExtension on DateTime {
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  bool get isWeekday => !isWeekend;
}
