import 'package:greed_portfolio_server/storage/storage_portfolio_part.dart';
import 'package:invest_api_dart/invest_api_dart.dart';

/// Данные портфеля в хранилище
class StoragePortfolio {
  /// Цена доллара
  final ValueWithCurrency dollar;

  /// Части портфеля
  final List<StoragePortfolioPart> parts;

  /// Конструктор
  StoragePortfolio(this.dollar, this.parts);

  /// Преобразует в json
  Map<String, dynamic> toJson() {
    final jsonParts = parts.map((x) => x.toJson());
    return {'dollar': dollar.toJson(), 'parts': jsonParts};
  }
}
