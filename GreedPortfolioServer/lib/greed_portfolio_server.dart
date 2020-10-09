import 'dart:async';

import 'package:greed_portfolio_server/collector/collector.dart';
import 'package:greed_portfolio_server/storage/storage.dart';
import 'package:greed_portfolio_server/token.dart';
import 'package:invest_api_dart/invest_api_dart.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_cors/jaguar_cors.dart';

/// Сервер приложения
class GreedPortfolioServer {
  final options = CorsOptions(
      maxAge: 86400,
      allowAllOrigins: true,
      allowAllMethods: true,
      allowAllHeaders: true);

  /// Возвращает информацию по портфелю
  FutureOr<dynamic> _getPortfolio(Context ctx) async {
    final storage = Storage();

    // TODO: вынести настройки куда то
    const bondPercent = 10;
    const goldPercent = 10;
    const stockPercent = 100 - bondPercent - goldPercent;

    final portfolio = await storage.loadLastPortfolio();
    if (portfolio == null) return <String, dynamic>{};

    return <String, dynamic>{
      'strategyRatios': {
        'stocks': stockPercent,
        'bonds': bondPercent,
        'gold': stockPercent
      },
      'dataDate': portfolio.dataDate.toIso8601String(),
      'dollar': portfolio.portfolio.dollar.toJson(),
      'parts': portfolio.portfolio.parts.map((x) => x.toJson()).toList()
    };
  }

  /// Создаёт API сервера
  void start(int port) {
    /// Запускает сбор
    Collector().start();

    Jaguar(port: port)
      ..getJson('/portfolio', _getPortfolio, before: [cors(options)])
      ..serve();

    print('API started on port $port');
  }
}
