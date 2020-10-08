import 'dart:async';

/// Собирает данные по портфелю
class Collector {
  /// Экземпляр
  static final Collector _instance = Collector._();

  /// Признак работы
  bool isWorking = false;

  /// Возвращает экземпляр
  factory Collector() {
    return _instance;
  }

  /// Приватный конструктор
  Collector._();

  /// Запускает
  void start() {
    if (isWorking) return;

    Timer.periodic(Duration(seconds: 10), (timer) {
      if (!isWorking) timer.cancel();
    });
  }

  /// Останавливает
  void stop() {
    isWorking = false;
  }
}
