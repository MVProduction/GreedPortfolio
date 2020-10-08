import 'package:greed_portfolio_server/storage/storage_portfolio.dart';

/// Хранилище данных
class Storage {
  /// Сохраняет данные по портфелю
  Future savePortfolio(DateTime time, StoragePortfolio portfolio) {}

  /// Загружает данные по портфелю с [from] до [to]
  Future<StoragePortfolio> loadPortfolio(DateTime from, DateTime to) {}

  /// Загружает последние данные по портфелю
  Future<StoragePortfolio> loadLastPortfolio() {}
}
