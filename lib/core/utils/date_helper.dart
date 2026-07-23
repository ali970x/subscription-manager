class DateHelper {
  static DateTime addMonths(DateTime date, int months) {
    final targetMonth = date.month - 1 + months;
    final year = date.year + targetMonth ~/ 12;
    final month = targetMonth % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, date.day.clamp(1, lastDay));
  }

  static DateTime nextRenewal(DateTime start, String cycle, {DateTime? now}) {
    final today = DateTime(
      now?.year ?? DateTime.now().year,
      now?.month ?? DateTime.now().month,
      now?.day ?? DateTime.now().day,
    );
    var next = DateTime(start.year, start.month, start.day);
    while (!next.isAfter(today)) {
      next = switch (cycle) {
        'weekly' => next.add(const Duration(days: 7)),
        'yearly' => DateTime(
          next.year + 1,
          next.month,
          next.day.clamp(1, DateTime(next.year + 1, next.month + 1, 0).day),
        ),
        _ => addMonths(next, 1),
      };
    }
    return next;
  }
}
