import 'package:flutter/material.dart';
import 'package:greed_portfolio_ui/pages/main_page.dart';

void main() {
  runApp(GreedPortfolioUi());
}

class GreedPortfolioUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreedPortfolio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: 'Учёт портфеля'),
    );
  }
}
