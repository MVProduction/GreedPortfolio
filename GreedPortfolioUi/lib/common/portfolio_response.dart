class PortfolioResponse {
  StrategyRatios strategyRatios;
  Price dollar;
  Stocks stocks;
  Stocks bonds;
  Stocks gold;
  Currency currency;

  PortfolioResponse(
      {this.strategyRatios,
      this.dollar,
      this.stocks,
      this.bonds,
      this.gold,
      this.currency});

  PortfolioResponse.fromJson(Map<String, dynamic> json) {
    strategyRatios = json['strategyRatios'] != null
        ? new StrategyRatios.fromJson(json['strategyRatios'])
        : null;
    dollar = json['dollar'] != null ? new Price.fromJson(json['dollar']) : null;
    stocks =
        json['stocks'] != null ? new Stocks.fromJson(json['stocks']) : null;
    bonds = json['bonds'] != null ? new Stocks.fromJson(json['bonds']) : null;
    gold = json['gold'] != null ? new Stocks.fromJson(json['gold']) : null;
    currency = json['currency'] != null
        ? new Currency.fromJson(json['currency'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.strategyRatios != null) {
      data['strategyRatios'] = this.strategyRatios.toJson();
    }
    if (this.dollar != null) {
      data['dollar'] = this.dollar.toJson();
    }
    if (this.stocks != null) {
      data['stocks'] = this.stocks.toJson();
    }
    if (this.bonds != null) {
      data['bonds'] = this.bonds.toJson();
    }
    if (this.gold != null) {
      data['gold'] = this.gold.toJson();
    }
    if (this.currency != null) {
      data['currency'] = this.currency.toJson();
    }
    return data;
  }
}

class StrategyRatios {
  int stocks;
  int bonds;
  int gold;

  StrategyRatios({this.stocks, this.bonds, this.gold});

  StrategyRatios.fromJson(Map<String, dynamic> json) {
    stocks = json['stocks'];
    bonds = json['bonds'];
    gold = json['gold'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stocks'] = this.stocks;
    data['bonds'] = this.bonds;
    data['gold'] = this.gold;
    return data;
  }
}

class Price {
  double value;
  String currency;

  Price({this.value, this.currency});

  Price.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['currency'] = this.currency;
    return data;
  }
}

class Stocks {
  Price price;
  double ratio;
  Price deviation;
  double deviationPercent;

  Stocks({this.price, this.ratio, this.deviation, this.deviationPercent});

  Stocks.fromJson(Map<String, dynamic> json) {
    price = json['price'] != null ? new Price.fromJson(json['price']) : null;
    ratio = json['ratio'];
    deviation = json['deviation'] != null
        ? new Price.fromJson(json['deviation'])
        : null;
    deviationPercent = json['deviationPercent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.price != null) {
      data['price'] = this.price.toJson();
    }
    data['ratio'] = this.ratio;
    if (this.deviation != null) {
      data['deviation'] = this.deviation.toJson();
    }
    data['deviationPercent'] = this.deviationPercent;
    return data;
  }
}

class Currency {
  Price price;
  double ratio;

  Currency({this.price, this.ratio});

  Currency.fromJson(Map<String, dynamic> json) {
    price = json['price'] != null ? new Price.fromJson(json['price']) : null;
    ratio = json['ratio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.price != null) {
      data['price'] = this.price.toJson();
    }
    data['ratio'] = this.ratio;
    return data;
  }
}
