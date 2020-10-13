class PortfolioResponse {
  StrategyRatios strategyRatios;
  String dataDate;
  Currency dollar;
  List<Parts> parts;

  PortfolioResponse(
      {this.strategyRatios, this.dataDate, this.dollar, this.parts});

  PortfolioResponse.fromJson(Map<String, dynamic> json) {
    strategyRatios = json['strategyRatios'] != null
        ? new StrategyRatios.fromJson(json['strategyRatios'])
        : null;
    dataDate = json['dataDate'];
    dollar =
        json['dollar'] != null ? new Currency.fromJson(json['dollar']) : null;
    if (json['parts'] != null) {
      parts = new List<Parts>();
      json['parts'].forEach((v) {
        parts.add(new Parts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.strategyRatios != null) {
      data['strategyRatios'] = this.strategyRatios.toJson();
    }
    data['dataDate'] = this.dataDate;
    if (this.dollar != null) {
      data['dollar'] = this.dollar.toJson();
    }
    if (this.parts != null) {
      data['parts'] = this.parts.map((v) => v.toJson()).toList();
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

class Currency {
  String currency;
  double value;

  Currency({this.currency, this.value});

  Currency.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['value'] = this.value;
    return data;
  }
}

class Parts {
  String type;
  double price;
  double ratio;
  double deviation;
  double deviationPercent;

  Parts(
      {this.type,
      this.price,
      this.ratio,
      this.deviation,
      this.deviationPercent});

  Parts.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price'];
    ratio = json['ratio'];
    deviation = json['deviation'];
    deviationPercent = json['deviationPercent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['price'] = this.price;
    data['ratio'] = this.ratio;
    data['deviation'] = this.deviation;
    data['deviationPercent'] = this.deviationPercent;
    return data;
  }
}
