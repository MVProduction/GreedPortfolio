import 'package:greed_portfolio_server/storage/storage_portfolio.dart';

/// Хранилище данных
class Storage {
  /// Экземпляр
  static final Storage _instance = Storage._();

  /// Возвращает экземпляр
  factory Storage() {
    return _instance;
  }

  /// Приватный конструктор
  Storage._();

  /// Сохраняет данные по портфелю
  Future savePortfolio(DateTime time, StoragePortfolio portfolio) {
    final data = portfolio.toJson();
  }

  /// Загружает данные по портфелю с [from] до [to]
  Future<StoragePortfolio> loadPortfolio(DateTime from, DateTime to) {}

  /// Загружает последние данные по портфелю
  Future<StoragePortfolio> loadLastPortfolio() {}
}
