import 'dart:async';

import 'package:cron/cron.dart';
import 'package:greed_portfolio_server/common/strategy_settings.dart';
import 'package:greed_portfolio_server/storage/portfolio_part_type.dart';
import 'package:greed_portfolio_server/storage/storage.dart';
import 'package:greed_portfolio_server/storage/storage_portfolio.dart';
import 'package:greed_portfolio_server/storage/storage_portfolio_part.dart';
import 'package:greed_portfolio_server/token.dart';
import 'package:invest_api_dart/invest_api_dart.dart';

/// Собирает данные по портфелю
class Collector {
  /// Экземпляр
  static final Collector _instance = Collector._();

  /// Признак работы
  bool isWorking = false;

  static final DOLLAR_FIGI = 'BBG0013HGFT4';

  /// API для tinkoff
  final tinkoffApi = TinkoffRestApi(TINKOFF_API_TOKEN);

  /// Проверяет что инструмент входит в акции
  bool _isStock(TinkoffPortfolioPosition x) =>
      x.ticker == 'AKNX' || x.ticker == 'FXIT' || x.ticker == 'TECH';

  /// Проверяет что инструмент входит в облигации
  bool _isBond(TinkoffPortfolioPosition x) =>
      x.instrumentType == 'Bond' || x.ticker == 'AKMB';

  /// Проверяет что инструмент входит в золото
  bool _isGold(TinkoffPortfolioPosition x) => x.ticker == 'TGLD';

  /// Проверяет что инструмент входит в недвижимость
  bool _isReit(TinkoffPortfolioPosition x) => x.ticker == 'O';

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

  /// Собирает данные
  Future _collect() async {
    print('start to collect');
    final stockPercent = StrategySettings.stockPercent;
    final bondPercent = StrategySettings.stockPercent;
    final goldPercent = StrategySettings.stockPercent;
    final reitPercent = StrategySettings.stockPercent;

    final dollarInRub = await _getLastPrice(DOLLAR_FIGI);
    final positions = await tinkoffApi.getPortfolio();
    final currencyPositions = await tinkoffApi.getPortfolioCurrencies();
    final currencySumm =
        _calcCurrencyPositionSumInRub(currencyPositions, dollarInRub);

    final bondPositions = positions.where((x) => _isBond(x)).toList();
    final bondSumm = await calcPositionSumInRub(bondPositions, dollarInRub);
    final goldPositions = positions.where((x) => _isGold(x)).toList();
    final goldSumm = await calcPositionSumInRub(goldPositions, dollarInRub);
    final reitPositions = positions.where((x) => _isReit(x)).toList();
    final reitSumm = await calcPositionSumInRub(reitPositions, dollarInRub);

    final stocksPositions = positions.where((x) => _isStock(x)).toList();
    final stocksSumm = await calcPositionSumInRub(stocksPositions, dollarInRub);

    final totalSumm = bondSumm + goldSumm + stocksSumm + currencySumm;

    final stockRatio = (stocksSumm / totalSumm) * 100;
    final bondRatio = (bondSumm / totalSumm) * 100;
    final goldRatio = (goldSumm / totalSumm) * 100;
    final reitRatio = (reitSumm / totalSumm) * 100;

    final stockDeviationPercent = stockRatio - stockPercent;
    final stockDeviation = (totalSumm / 100) * stockDeviationPercent;

    final bondDeviationPercent = bondRatio - bondPercent;
    final bondDeviation = (totalSumm / 100) * bondDeviationPercent;

    final goldDeviationPercent = goldRatio - goldPercent;
    final goldDeviation = (totalSumm / 100) * goldDeviationPercent;

    final reitDeviationPercent = reitRatio - reitPercent;
    final reitDeviation = (totalSumm / 100) * reitDeviationPercent;

    final currencyRatio = (currencySumm / totalSumm) * 100;

    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, now.hour);

    final parts = <StoragePortfolioPart>[
      StoragePortfolioPart(PortfolioPartType.Stocks, stocksSumm, stockRatio,
          stockDeviation, stockDeviationPercent),
      StoragePortfolioPart(PortfolioPartType.Bonds, bondSumm, bondRatio,
          bondDeviation, bondDeviationPercent),
      StoragePortfolioPart(PortfolioPartType.Gold, goldSumm, goldRatio,
          goldDeviation, goldDeviationPercent),
      StoragePortfolioPart(PortfolioPartType.Reit, reitSumm, reitRatio,
          reitDeviation, reitDeviationPercent),
      StoragePortfolioPart(
          PortfolioPartType.Currency, currencySumm, currencyRatio)
    ];

    final portfolio =
        StoragePortfolio(ValueWithCurrency('RUB', dollarInRub), parts);

    final storage = Storage();
    await storage.savePortfolio(date, portfolio);
    print('collected: $date');
  }

  /// Возвращает экземпляр
  factory Collector() {
    return _instance;
  }

  /// Приватный конструктор
  Collector._();

  /// Запускает
  void start() {
    if (isWorking) return;
    isWorking = true;

    print('collector started');
    var cron = Cron();
    var isCollecting = false;
    cron.schedule(Schedule.parse('0 */1 * * *'), () async {
      if (!isCollecting) {
        isCollecting = true;
        await _collect();
        isCollecting = false;
      }
    });
  }

  /// Останавливает
  void stop() {
    isWorking = false;
  }
}
