import 'dart:async';

import 'package:greed_portfolio_ui/common/date_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greed_portfolio_ui/common/portfolio_response.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Информация о позиции в портфеле
class PortfolioStockInfo {
  /// Название
  final String name;

  /// Процент в портфеле
  final double ratio;

  /// Цена
  final double price;

  /// Отклонение
  final double deviation;

  /// Процент
  final double deviationPercent;

  PortfolioStockInfo.fromStocks(String name, Parts stocks)
      : this.name = name,
        this.ratio = stocks.ratio,
        this.price = stocks.price,
        this.deviation = stocks.deviation,
        this.deviationPercent = stocks.deviationPercent;

  PortfolioStockInfo(
      this.name, this.ratio, this.price, this.deviation, this.deviationPercent);
}

/// Данные для графика
class ChartData {
  /// Название
  final String name;

  /// Значение
  final double value;

  /// Цвет графика
  final Color color;

  /// Конструктор
  ChartData(this.name, this.value, this.color);
}

// Состояние ожидания
class MainPageWaitState {}

// Состояние работы
class MainPageWorkState {
  /// Время обновления
  final DateTime refreshTime;

  /// Данные по портфелю
  final PortfolioResponse data;

  /// Конструктор
  MainPageWorkState(this.refreshTime, this.data);
}

/// Основная страница
class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

// Состояние главной страницы
class _MainPageState extends State<MainPage> {
  /// Контроллер событий
  final _eventStream = StreamController();

  /// Возвращает Widget ожидания
  Widget _getWaitWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text("Загружаются данные..."),
          ),
          CircularProgressIndicator()
        ],
      ),
    );
  }

  /// Возвращает Widget общего размера портфеля
  Widget _getTotalInfo(double total) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          "Всего: ${total.round()} руб",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      )
    ]);
  }

  /// Возвращает Widget с инфорацией о цене доллара
  Widget _getDollarInfo(double dollar) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          "Доллар: ${dollar.toStringAsFixed(3)} руб",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      )
    ]);
  }

  /// Возвращает Widget описания стратегии
  Widget _getStrategyInfoWidget(StrategyRatios ratios) {
    Widget _getStrategyItem(String name, int value, Color color) {
      return Padding(
        padding: EdgeInsets.only(right: 16),
        child: Row(
          children: [
            Container(
                width: 36,
                height: 36,
                child: CircleAvatar(
                  backgroundColor: color,
                  child: Text("$value%",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                )),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(name),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Text(
            "Стратегия",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
            padding: EdgeInsets.only(top: 16, bottom: 16, right: 32, left: 32),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getStrategyItem('Акции', ratios.stocks, Colors.blue),
                        _getStrategyItem('Облигации', ratios.bonds, Colors.red),
                        _getStrategyItem('Золото', ratios.gold, Colors.amber),
                        _getStrategyItem(
                            'Недвижимость', ratios.reit, Colors.green),
                      ],
                    )),
                Container(
                  height: 30,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (ratios.stocks / 10).round(),
                        child: Container(color: Colors.blue),
                      ),
                      Expanded(
                        flex: (ratios.bonds / 10).round(),
                        child: Container(
                          color: Colors.red,
                        ),
                      ),
                      Expanded(
                        flex: (ratios.gold / 10).round(),
                        child: Container(
                          color: Colors.amber,
                        ),
                      ),
                      Expanded(
                        flex: (ratios.reit / 10).round(),
                        child: Container(
                          color: Colors.green,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ))
      ],
    );
  }

  /// Возвращает Widget с графиком портфеля
  Widget _getPortfolioChartWidget(
      double stocks, double bonds, double gold, double reit) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(top: 32, bottom: 0),
        child: Text(
          "Портфель график, %",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 400,
        child: SfCircularChart(
          legend: Legend(
              position: LegendPosition.bottom,
              isVisible: true,
              toggleSeriesVisibility: false,
              overflowMode: LegendItemOverflowMode.wrap),
          series: <DoughnutSeries<ChartData, String>>[
            DoughnutSeries<ChartData, String>(
                dataSource: <ChartData>[
                  ChartData("Акции", stocks, Colors.blue),
                  ChartData("Облигации", bonds, Colors.red),
                  ChartData("Золото", gold, Colors.amber),
                  ChartData("Недвижимость", reit, Colors.green),
                ],
                pointColorMapper: (ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.name,
                yValueMapper: (ChartData data, _) =>
                    double.parse(data.value.toStringAsFixed(2)),
                startAngle: 90,
                endAngle: 90,
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside)),
          ],
          tooltipBehavior: TooltipBehavior(enable: true),
        ),
      )
    ]);
  }

  /// Возвращает Widget с таблицей портфеля
  Widget _getPortfolioTableWidget(
      List<PortfolioStockInfo> stocks, double currency) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 32, bottom: 32),
          child: Text(
            "Портфель таблица",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        for (final stock in stocks)
          Padding(
            padding: EdgeInsets.only(left: 32, right: 32, bottom: 16),
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(stock.name,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text("Цена"),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(stock.price.toStringAsFixed(2)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text("руб"),
                        )
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text("Отклонение"),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(stock.deviation.toStringAsFixed(2)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text("руб"),
                        )
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text("Отклонение, %"),
                        ),
                        Expanded(
                          flex: 2,
                          child:
                              Text(stock.deviationPercent.toStringAsFixed(2)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text("%"),
                        )
                      ],
                    ))
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.only(left: 32, right: 32, bottom: 32),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text("Валюты",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text("Цена"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(currency.toStringAsFixed(2)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text("руб"),
                      )
                    ],
                  ))
            ],
          ),
        )
      ],
    );
  }

  /// Возвращает Widget рабочего приложения
  Widget _getWorkWidget(PortfolioResponse data) {
    final stocksPart = data.parts.firstWhere((x) => x.type == 'stocks');
    final bondsPart = data.parts.firstWhere((x) => x.type == 'bonds');
    final goldPart = data.parts.firstWhere((x) => x.type == 'gold');
    final reitPart = data.parts.firstWhere((x) => x.type == 'reit');
    final currencyPart = data.parts.firstWhere((x) => x.type == 'currency');

    final total = stocksPart.price +
        bondsPart.price +
        goldPart.price +
        reitPart.price +
        currencyPart.price;

    final dollar = data.dollar.value;

    final stocksRatio = stocksPart.ratio;
    final bondsRatio = bondsPart.ratio;
    final goldRatio = goldPart.ratio;
    final reitRatio = reitPart.ratio;

    final stocks = <PortfolioStockInfo>[
      PortfolioStockInfo.fromStocks('Акции', stocksPart),
      PortfolioStockInfo.fromStocks('Облигации', bondsPart),
      PortfolioStockInfo.fromStocks('Золото', goldPart),
      PortfolioStockInfo.fromStocks('Недвижимость', reitPart)
    ];

    return ListView(
      children: [
        _getStrategyInfoWidget(data.strategyRatios),
        _getTotalInfo(total),
        _getDollarInfo(dollar),
        _getPortfolioChartWidget(stocksRatio, bondsRatio, goldRatio, reitRatio),
        _getPortfolioTableWidget(stocks, currencyPart.price)
      ],
    );
  }

  /// Обновляет данные
  Future _reloadData() {
    _eventStream.add(MainPageWaitState());
    return Dio()
        .get("http://192.168.1.93:8090/portfolio/current")
        .then((value) {
      final resp = PortfolioResponse.fromJson(value.data);
      final date = DateTime.parse(resp.dataDate).toLocal();
      _eventStream.add(MainPageWorkState(date, resp));
    }).catchError((e) {
      print(e);
    });
  }

  /// Возвращает приложение с индикатором ожидания
  Widget _getWaitAppWidget() {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)), body: _getWaitWidget());
  }

  /// Возвращает рабочее приложение
  Widget _getWorkAppWidget(MainPageWorkState data) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          Center(
            child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(data.refreshTime.toRuString())),
          )
        ]),
        body: _getWorkWidget(data.data));
  }

  /// Инициализирует состояние
  @override
  void initState() {
    super.initState();

    _reloadData().then((value) {
      Timer.periodic(Duration(minutes: 10), (timer) {
        _reloadData();
      });
    });
  }

  // Освобождает ресурсы
  @override
  void dispose() {
    _eventStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _eventStream.stream,
        initialData: MainPageWaitState(),
        builder: (context, snapshot) {
          if (snapshot.data is MainPageWaitState) {
            return _getWaitAppWidget();
          } else if (snapshot.data is MainPageWorkState) {
            return _getWorkAppWidget((snapshot.data as MainPageWorkState));
          }

          throw Exception();
        });
  }
}
