import 'dart:async';

import 'package:greed_portfolio_server/token.dart';
import 'package:invest_api_dart/invest_api_dart.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_cors/jaguar_cors.dart';

/// Сервер приложения
class GreedPortfolioServer {
  static final DOLLAR_FIGI = 'BBG0013HGFT4';

  final tinkoffApi = TinkoffRestApi(TINKOFF_API_TOKEN);

  final options = CorsOptions(
      maxAge: 86400,
      allowAllOrigins: true,
      allowAllMethods: true,
      allowAllHeaders: true);

  /// Возвращает последнюю цену для инструмента
  Future<num> _getLastPrice(String figi) async {
    final to = DateTime.now();
    final from = to.add(Duration(days: -7));
    final candles = await tinkoffApi.getMarketCandles(
        figi, from, to, TinkoffCandleInterval.Day);
    return candles.last.close;
  }

  /// Считает сумму по позициям в рублях
  Future<num> calcPositionSumInRub(
      List<TinkoffPortfolioPosition> positions, num dollarInRub) async {
    num summ = 0;

    for (final position in positions) {
      final lastPrice = await _getLastPrice(position.figi);

      num posTotalPrice = 0;
      switch (position.averagePositionPrice.currency) {
        case 'RUB':
          posTotalPrice = lastPrice * position.lots;
          break;
        case 'USD':
          posTotalPrice = (lastPrice * position.lots) * dollarInRub;
          break;
      }
      summ += posTotalPrice;
    }

    return summ;
  }

  /// Считает сумму по позициям в рублях по валютам
  num _calcCurrencyPositionSumInRub(
      List<TinkoffPortfolioCurrencyPosition> positions, num dollarInRub) {
    num summ = 0;

    for (final position in positions) {
      num posTotalPrice = 0;
      switch (position.currency) {
        case 'RUB':
          posTotalPrice = position.balance;
          break;
        case 'USD':
          posTotalPrice = position.balance * dollarInRub;
          break;
      }
      summ += posTotalPrice;
    }

    return summ;
  }

  /// Возвращает информацию по портфелю
  FutureOr<dynamic> _getPortfolio(Context ctx) async {
    const bondPercent = 10;
    const goldPercent = 10;
    const stockPercent = 100 - bondPercent - goldPercent;

    final dollarInRub = await _getLastPrice(DOLLAR_FIGI);
    final positions = await tinkoffApi.getPortfolio();
    final currencyPositions = await tinkoffApi.getPortfolioCurrencies();
    final currencySumm =
        _calcCurrencyPositionSumInRub(currencyPositions, dollarInRub);

    final bondPositions =
        positions.where((x) => x.instrumentType == 'Bond').toList();
    final bondSumm = await calcPositionSumInRub(bondPositions, dollarInRub);
    final goldPositions = positions.where((x) => x.ticker == 'TGLD').toList();
    final goldSumm = await calcPositionSumInRub(goldPositions, dollarInRub);
    final stocksPositions = positions
        .where((x) => x.ticker == 'AKNX' || x.ticker == 'FXIT')
        .toList();
    final stocksSumm = await calcPositionSumInRub(stocksPositions, dollarInRub);
    final totalSumm = bondSumm + goldSumm + stocksSumm + currencySumm;

    final stockRatio = (stocksSumm / totalSumm) * 100;
    final bondRatio = (bondSumm / totalSumm) * 100;
    final goldRatio = (goldSumm / totalSumm) * 100;

    final stockDeviationPercent = stockRatio - stockPercent;
    final stockDeviation = (totalSumm / 100) * stockDeviationPercent;

    final bondDeviationPercent = bondRatio - bondPercent;
    final bondDeviation = (totalSumm / 100) * bondDeviationPercent;

    final goldDeviationPercent = goldRatio - goldPercent;
    final goldDeviation = (totalSumm / 100) * goldDeviationPercent;

    return <String, dynamic>{
      'strategyRatios': {
        'stocks': stockPercent,
        'bonds': bondPercent,
        'gold': stockPercent
      },
      'dollar': {'value': dollarInRub, 'currency': 'RUB'},
      'stocks': {
        'price': {'value': stocksSumm, 'currency': 'RUB'},
        'ratio': stockRatio,
        'deviation': {'value': stockDeviation, 'currency': 'RUB'},
        'deviationPercent': stockDeviationPercent
      },
      'bonds': {
        'price': {'value': bondSumm, 'currency': 'RUB'},
        'ratio': bondRatio,
        'deviation': {'value': bondDeviation, 'currency': 'RUB'},
        'deviationPercent': bondDeviationPercent
      },
      'gold': {
        'price': {'value': goldSumm, 'currency': 'RUB'},
        'ratio': goldRatio,
        'deviation': {'value': goldDeviation, 'currency': 'RUB'},
        'deviationPercent': goldDeviationPercent
      },
      'currency': {
        'price': {'value': currencySumm, 'currency': 'RUB'},
        'ratio': ((currencySumm / totalSumm) * 100),
      }
    };
  }

  /// Создаёт API сервера
  void start(int port) {
    Jaguar(port: port)
      ..getJson('/portfolio', _getPortfolio, before: [cors(options)])
      ..serve();

    print('started on port $port');
  }
}
