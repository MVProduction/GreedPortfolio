import 'dart:async';
import 'dart:convert';

import 'package:greed_portfolio_server/common/num_helper.dart';
import 'package:greed_portfolio_server/common/datetime_helper.dart';
import 'package:greed_portfolio_server/storage/storage_portfolio.dart';
import 'package:greed_portfolio_server/storage/storage_portfolio_with_date.dart';
import 'package:sqlite3/sqlite3.dart';

/// Хранилище данных
class Storage {
  /// Экземпляр
  static final Storage _instance = Storage._();

  /// База данных
  final Database _db;

  /// Инициализирует базу данных
  static Database _initDatabase() {
    final db = sqlite3.open('storage.db');
    db.execute('''
      CREATE TABLE IF NOT EXISTS portfolio (
        id INTEGER NOT NULL PRIMARY KEY,
        data_date INTEGER NOT NULL,
        data TEXT NOT NULL
      );
    ''');
    return db;
  }

  /// Возвращает экземпляр
  factory Storage() {
    return _instance;
  }

  /// Создаёт портфель из строки базы данных
  StoragePortfolioWithDate rowToPortfolioWithDate(Row row) {
    final dataDate = row['data_date'] as num;
    final data = json.decode(row['data']);
    final date = dataDate.toDateTimeFromEpochSeconds();
    final portfolio = StoragePortfolio.fromJson(data);
    return StoragePortfolioWithDate(date, portfolio);
  }

  /// Приватный конструктор
  Storage._() : _db = _initDatabase();

  /// Сохраняет данные по портфелю
  Future savePortfolio(DateTime time, StoragePortfolio portfolio) {
    final data = portfolio.toJson();
    final dataDate = time.utcSecondsFromEpoch;
    final stmt =
        _db.prepare('INSERT INTO portfolio (data_date,data) VALUES (?,?)');

    stmt.execute([dataDate, json.encode(data)]);
    stmt.dispose();
    return Future.value();
  }

  /// Загружает данные по портфелю с [from] до [to]
  Future<List<StoragePortfolioWithDate>> loadPortfolio(
      DateTime from, DateTime to) {
    final fromSeconds = from.utcSecondsFromEpoch;
    final toSeconds = to.utcSecondsFromEpoch;

    final resultSet = _db.select(
        'SELECT data_date,data FROM portfolio WHERE data_date>=? and data_date<=? ORDER BY data_date DESC',
        [fromSeconds, toSeconds]);

    final res = <StoragePortfolioWithDate>[];
    for (final row in resultSet) {
      final portfolio = rowToPortfolioWithDate(row);
      res.add(portfolio);
    }

    return Future.value(res);
  }

  /// Загружает последние данные по портфелю
  Future<StoragePortfolioWithDate> loadLastPortfolio() {
    final resultSet = _db.select(
        'SELECT data_date,data FROM portfolio ORDER BY data_date DESC LIMIT 1');

    if (resultSet.isEmpty) return null;

    final row = resultSet.first;
    final portfolio = rowToPortfolioWithDate(row);

    return Future.value(portfolio);
  }
}
