import 'package:invest_api_dart/invest_api_dart.dart';

/// Часть от портфеля
class StoragePortfolioPart {
  /// Полная цена части
  final ValueWithCurrency price;

  /// Процент в портфеле
  final num ratio;

  /// Отклонение
  final ValueWithCurrency deviation;

  /// Отклонение в процентах
  final num deviationPercent;

  /// Конструктор
  StoragePortfolioPart(
      this.price, this.ratio, this.deviation, this.deviationPercent);

  /// Преобразует json
  Map<String, dynamic> toJson() {
    return {
      'price': price.toJson(),
      'ratio': ratio,
      'deviation': deviation.toJson(),
      'deviationPercent': deviationPercent
    };
  }
}
