import 'package:greed_portfolio_server/storage/portfolio_part_type.dart';

/// Часть от портфеля, для удобства цены всех частей расчитываются в рублях
class StoragePortfolioPart {
  /// Тип части портфеля
  final PortfolioPartType type;

  /// Полная цена части в рублях
  final num price;

  /// Процент в портфеле
  final num ratio;

  /// Отклонение в рублях
  final num deviation;

  /// Отклонение в процентах
  final num deviationPercent;

  /// Создаёт из json
  static StoragePortfolioPart fromJson(Map<String, dynamic> data) {
    final price = data['price'];
    final deviation = data['deviation'];
    return StoragePortfolioPart(data['type'].toString().toPortfolioPartType(),
        price, data['ratio'], deviation, data['deviationPercent']);
  }

  /// Конструктор
  StoragePortfolioPart(this.type, this.price,
      [this.ratio, this.deviation, this.deviationPercent]);

  /// Преобразует json
  Map<String, dynamic> toJson() {
    return {
      'type': type.getStringValue(),
      'price': price,
      'ratio': ratio,
      'deviation': deviation,
      'deviationPercent': deviationPercent
    };
  }
}
