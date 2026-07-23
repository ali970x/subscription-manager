extension DateTimeExtensions on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
  int get daysFromNow => dateOnly.difference(DateTime.now().dateOnly).inDays;
  bool get isWithinNextWeek => daysFromNow >= 0 && daysFromNow <= 7;
}
