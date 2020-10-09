/// Утилита для num
extension NumHelper on num {
  /// Преобразует число (количество секунд с 01.01.1970) в дату
  DateTime toDateTimeFromEpochSeconds() {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: true);
  }
}
