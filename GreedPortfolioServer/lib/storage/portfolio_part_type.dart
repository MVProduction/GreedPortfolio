/// Тип части портфеля
enum PortfolioPartType {
  /// Акции
  Stocks,

  /// Облигации
  Bonds,

  /// Золото
  Gold,

  /// Валюта
  Currency
}

/// Утилита для работы с PortfolioPartType
extension PortfolioPartTypeHelper on PortfolioPartType {
  /// Возвращает строковое значение
  String getStringValue() {
    switch (this) {
      case PortfolioPartType.Stocks:
        return 'stocks';
      case PortfolioPartType.Bonds:
        return 'bonds';
      case PortfolioPartType.Gold:
        return 'gold';
      case PortfolioPartType.Currency:
        return 'currency';
    }

    return null;
  }
}
