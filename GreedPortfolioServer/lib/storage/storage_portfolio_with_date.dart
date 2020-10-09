import 'package:greed_portfolio_server/storage/storage_portfolio.dart';

/// Портфель с датой данных
class StoragePortfolioWithDate {
  /// Дата данных
  final DateTime dataDate;

  /// Портфель
  final StoragePortfolio portfolio;

  /// Конструктор
  StoragePortfolioWithDate(this.dataDate, this.portfolio);
}
