/// Утилита для работы с датой
extension DateHelper on DateTime {
  String _intTwo(int value) {
    return value < 10 ? "0$value" : value.toString();
  }

  /// Возвращает локализованную строку даты времени для России
  String toRuString() {
    final day = _intTwo(this.day);
    final month = _intTwo(this.month);
    final year = this.year;

    final hour = _intTwo(this.hour);
    final minute = _intTwo(this.minute);
    final second = _intTwo(this.second);

    return "$day.$month.$year $hour:$minute:$second";
  }
}
