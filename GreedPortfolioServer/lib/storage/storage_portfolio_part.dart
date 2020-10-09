import 'package:greed_portfolio_server/storage/portfolio_part_type.dart';
import 'package:invest_api_dart/invest_api_dart.dart';

/// Часть от портфеля
class StoragePortfolioPart {
  /// Тип части портфеля
  final PortfolioPartType type;

  /// Полная цена части
  final ValueWithCurrency price;

  /// Процент в портфеле
  final num ratio;

  /// Отклонение
  final ValueWithCurrency deviation;

  /// Отклонение в процентах
  final num deviationPercent;

  /// Создаёт из json
  static StoragePortfolioPart fromJson(Map<String, dynamic> data) {
    final price = ValueWithCurrency.fromJson(data['price']);
    final deviation = ValueWithCurrency.fromJson(data['deviation']);
    return StoragePortfolioPart(data['type'].toString().toPortfolioPartType(),
        price, data['ratio'], deviation, data['deviationPercent']);
  }

  /// Конструктор
  StoragePortfolioPart(this.type, this.price,
      [this.ratio, this.deviation, this.deviationPercent]);

  /// Преобразует json
  Map<String, dynamic> toJson() {
    final deviationJson = deviation != null ? deviation.toJson() : null;
    return {
      'type': type.getStringValue(),
      'price': price.toJson(),
      'ratio': ratio,
      'deviation': deviationJson,
      'deviationPercent': deviationPercent
    };
  }
}
