import 'package:greed_portfolio_server/storage/storage_portfolio_part.dart';
import 'package:invest_api_dart/invest_api_dart.dart';

/// Данные портфеля в хранилище
class StoragePortfolio {
  /// Цена доллара
  final ValueWithCurrency dollar;

  /// Части портфеля
  final List<StoragePortfolioPart> parts;

  /// Создаёт из json
  static StoragePortfolio fromJson(Map<String, dynamic> data) {
    final dollar = ValueWithCurrency.fromJson(data['dollar']);
    final jsonParts = data['parts'] as List<dynamic>;
    final parts =
        jsonParts.map((x) => StoragePortfolioPart.fromJson(x)).toList();
    return StoragePortfolio(dollar, parts);
  }

  /// Конструктор
  StoragePortfolio(this.dollar, this.parts);

  /// Преобразует в json
  Map<String, dynamic> toJson() {
    final jsonParts = parts.map((x) => x.toJson()).toList();
    return {'dollar': dollar.toJson(), 'parts': jsonParts};
  }
}
