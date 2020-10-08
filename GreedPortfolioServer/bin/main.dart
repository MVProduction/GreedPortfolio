import 'package:greed_portfolio_server/greed_portfolio_server.dart';

void main(List<String> args) {
  final server = GreedPortfolioServer();
  server.start(8090);
}
