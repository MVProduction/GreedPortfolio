/// Тип части портфеля
enum PortfolioPartType {
  /// Акции
  Stocks,

  /// Облигации
  Bonds,

  /// Золото
  Gold,

  /// Фонды недвижимости
  Reit,

  /// Валюта
  Currency
}

/// Утилита для строки
extension PortfolioPartTypeStringHelper on String {
  /// Возвращает перечисление для строки
  PortfolioPartType toPortfolioPartType() {
    switch (this) {
      case 'stocks':
        return PortfolioPartType.Stocks;
      case 'bonds':
        return PortfolioPartType.Bonds;
      case 'gold':
        return PortfolioPartType.Gold;
      case 'reit':
        return PortfolioPartType.Reit;
      case 'currency':
        return PortfolioPartType.Currency;
    }

    return null;
  }
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
      case PortfolioPartType.Reit:
        return 'reit';
      case PortfolioPartType.Currency:
        return 'currency';
    }

    return null;
  }
}
