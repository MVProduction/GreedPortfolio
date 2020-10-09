/// Интервал за который считается доходность
enum YieldInterval { Day, Month, SixMonth, Year, All, Custom }

/// Утилита для строки
extension YieldIntervalStringHelper on String {
  /// Преобразует в YieldInterval
  YieldInterval toYieldInterval() {
    switch (this) {
      case 'day':
        return YieldInterval.Day;
      case 'month':
        return YieldInterval.Month;
      case 'sixMonth':
        return YieldInterval.SixMonth;
      case 'year':
        return YieldInterval.Year;
      case 'all':
        return YieldInterval.All;
      case 'custom':
        return YieldInterval.Custom;
    }

    return null;
  }
}

/// Утилита для работы с YieldInterval
extension YieldIntervalHelper on YieldInterval {}
