/// Настройки стратегии
abstract class StrategySettings {
  /// Доля облигаций
  static const bondPercent = 10;

  /// Доля золота
  static const goldPercent = 10;

  /// Доля недвижимости
  static const reitPercent = 10;

  /// Доля акций всё остальное
  static const stockPercent = 100 - bondPercent - goldPercent - reitPercent;
}
