import 'dart:async';

import 'package:greed_portfolio_server/collector/collector.dart';
import 'package:greed_portfolio_server/common/strategy_settings.dart';
import 'package:greed_portfolio_server/storage/storage.dart';
import 'package:greed_portfolio_server/common/yield_interval.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_cors/jaguar_cors.dart';

/// Сервер приложения
class GreedPortfolioServer {
  final options = CorsOptions(
      maxAge: 86400,
      allowAllOrigins: true,
      allowAllMethods: true,
      allowAllHeaders: true);

  /// Возвращает текущую информацию по портфелю
  FutureOr<dynamic> _getCurrentPortfolio(Context ctx) async {
    final storage = Storage();

    const bondPercent = StrategySettings.bondPercent;
    const goldPercent = StrategySettings.goldPercent;
    const reitPercent = StrategySettings.reitPercent;
    const stockPercent = 100 - bondPercent - goldPercent - reitPercent;

    final portfolio = await storage.loadLastPortfolio();
    if (portfolio == null) return <String, dynamic>{};

    return <String, dynamic>{
      'strategyRatios': {
        'stocks': stockPercent,
        'bonds': bondPercent,
        'gold': goldPercent,
        'reit': reitPercent
      },
      'dataDate': portfolio.dataDate.toIso8601String(),
      'dollar': portfolio.portfolio.dollar.toJson(),
      'parts': portfolio.portfolio.parts.map((x) => x.toJson()).toList()
    };
  }

  /// Возвращает доходность по портфелю
  FutureOr<dynamic> _getPortfolioYield(Context ctx) async {
    final interval = ctx.query.get('interval').toYieldInterval();
    final to = DateTime.now();

    DateTime from;

    switch (interval) {
      case YieldInterval.Day:
        from = DateTime(to.year, to.month, to.day);
        break;
      case YieldInterval.Month:
        from = DateTime(to.year, to.month, 1);
        break;
      case YieldInterval.SixMonth:
        // TODO: Доработать
        break;
      case YieldInterval.Year:
        from = DateTime(to.year, 1, 1);
        break;
      case YieldInterval.All:
        from = DateTime(2020, 1, 1);
        break;
      case YieldInterval.Custom:
        // TODO: Доработать
        break;
    }

    final storage = Storage();
    final portfolios = await storage.loadPortfolio(from, to);
    final first = portfolios.first;
    final last = portfolios.last;

    final firstPrice = first.portfolio.getSummInRub();
    final lastPrice = last.portfolio.getSummInRub();

    final yieldInRub = lastPrice - firstPrice;
    final yieldPercent = (yieldInRub / firstPrice) * 100;

    return <String, dynamic>{
      'yieldPrice': yieldInRub,
      'yieldPercent': yieldPercent
    };
  }

  /// Создаёт API сервера
  void start(int port) {
    /// Запускает сбор
    Collector().start();

    Jaguar(port: port)
      ..getJson('/portfolio/current', _getCurrentPortfolio,
          before: [cors(options)])
      ..getJson('/portfolio/yield', _getPortfolioYield, before: [cors(options)])
      ..serve();

    print('API started on port $port');
  }
}
