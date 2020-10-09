extension DateTimeHelper on DateTime {
  /// Переводит время в utc и возвращает количество секунд с 01.01.1970
  num get utcSecondsFromEpoch {
    return (toUtc().millisecondsSinceEpoch / 1000).round();
  }
}
