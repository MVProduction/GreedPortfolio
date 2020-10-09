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
  FutureOr<dynamic> _getPortfolio2(Context ctx) async {
    // const bondPercent = 10;
    // const goldPercent = 10;
    // const stockPercent = 100 - bondPercent - goldPercent;

    // final dollarInRub = await _getLastPrice(DOLLAR_FIGI);
    // final positions = await tinkoffApi.getPortfolio();
    // final currencyPositions = await tinkoffApi.getPortfolioCurrencies();
    // final currencySumm =
    //     _calcCurrencyPositionSumInRub(currencyPositions, dollarInRub);

    // final bondPositions =
    //     positions.where((x) => x.instrumentType == 'Bond').toList();
    // final bondSumm = await calcPositionSumInRub(bondPositions, dollarInRub);
    // final goldPositions = positions.where((x) => x.ticker == 'TGLD').toList();
    // final goldSumm = await calcPositionSumInRub(goldPositions, dollarInRub);
    // final stocksPositions = positions
    //     .where((x) => x.ticker == 'AKNX' || x.ticker == 'FXIT')
    //     .toList();
    // final stocksSumm = await calcPositionSumInRub(stocksPositions, dollarInRub);
    // final totalSumm = bondSumm + goldSumm + stocksSumm + currencySumm;

    // final stockRatio = (stocksSumm / totalSumm) * 100;
    // final bondRatio = (bondSumm / totalSumm) * 100;
    // final goldRatio = (goldSumm / totalSumm) * 100;

    // final stockDeviationPercent = stockRatio - stockPercent;
    // final stockDeviation = (totalSumm / 100) * stockDeviationPercent;

    // final bondDeviationPercent = bondRatio - bondPercent;
    // final bondDeviation = (totalSumm / 100) * bondDeviationPercent;

    // final goldDeviationPercent = goldRatio - goldPercent;
    // final goldDeviation = (totalSumm / 100) * goldDeviationPercent;

    // return <String, dynamic>{
    //   'strategyRatios': {
    //     'stocks': stockPercent,
    //     'bonds': bondPercent,
    //     'gold': stockPercent
    //   },
    //   'dollar': {'value': dollarInRub, 'currency': 'RUB'},
    //   'stocks': {
    //     'price': {'value': stocksSumm, 'currency': 'RUB'},
    //     'ratio': stockRatio,
    //     'deviation': {'value': stockDeviation, 'currency': 'RUB'},
    //     'deviationPercent': stockDeviationPercent
    //   },
    //   'bonds': {
    //     'price': {'value': bondSumm, 'currency': 'RUB'},
    //     'ratio': bondRatio,
    //     'deviation': {'value': bondDeviation, 'currency': 'RUB'},
    //     'deviationPercent': bondDeviationPercent
    //   },
    //   'gold': {
    //     'price': {'value': goldSumm, 'currency': 'RUB'},
    //     'ratio': goldRatio,
    //     'deviation': {'value': goldDeviation, 'currency': 'RUB'},
    //     'deviationPercent': goldDeviationPercent
    //   },
    //   'currency': {
    //     'price': {'value': currencySumm, 'currency': 'RUB'},
    //     'ratio': ((currencySumm / totalSumm) * 100),
    //   }
    // };
  }

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
