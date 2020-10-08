require "kemal"

require "json"
require "invest_api"

API_TOKEN = "t.doZaNd1KKt9gphFGYZ4XlEhignGZQNAalYSMZG2Wq48MwK9CNuqB5Y1z41J7ccT4ISXRu8-evh4QXDCZ4XVh8Q"
DOLLAR_FIGI = "BBG0013HGFT4"

enum PositionType
    Bond;
    Stocks;
    Gold;
end

class PositionInfo
    getter name : String
    getter value : Float64

    def initialize(@name, @value)        
    end
end

# Считает сумму по позициям в рублях
def calcPositionSumInRub(positions : Array(TinkoffPortfolioPosition), dollarInRub : Float64) : Float64
    summ : Float64 = 0
    
    positions.each do |x|        
        lastPrice = getLastPrice(x.figi)        
        
        posTotalPrice = 0
        case x.averagePositionPrice.currency
        when "RUB"
            posTotalPrice = lastPrice * x.lots
        when "USD"
            posTotalPrice = (lastPrice * x.lots) * dollarInRub
        else
        end        
        summ += posTotalPrice
    end

    return summ
end

# Считает сумму по позициям в рублях по валютам
def calcPositionSumInRub(positions : Array(TinkoffPortfolioCurrencyPosition), dollarInRub : Float64) : Float64
    summ : Float64 = 0
        
    positions.each do |x|    
        posTotalPrice = 0
        case x.currency
        when "RUB"
            posTotalPrice = x.balance
        when "USD"
            posTotalPrice = x.balance * dollarInRub
        else
        end        
        summ += posTotalPrice
    end

    return summ
end

# Возвращает последнюю цену для инструмента
def getLastPrice(figi : String) : Float64
    to = Time.local
    from = to - Time::Span.new(days: 7)
    candles = TinkoffRestApi.getMarketCandles(API_TOKEN, figi, from, to, TinkoffCandleInterval::Day)
    return candles.last.close
end


before_all do |env|
    env.response.headers["Access-Control-Allow-Origin"] = "*"
    env.response.headers["Access-Control-Allow-Methods"] = "GET, HEAD, POST, PUT"
    env.response.headers["Access-Control-Allow-Headers"] = "Content-Type, Accept, Origin, Authorization"
    env.response.headers["Access-Control-Max-Age"] = "86400"
end

options "/portfolio" do |env|
end

# Возвращает информацию по портфелю инвестиционных инструментов
# В формате стратегии ЖАДНЫЙ ЛЕЖЕБОКА
get "/portfolio" do |env|
    env.response.content_type = "application/json"

    bondPercent = 10
    goldPercent = 10    
    stockPercent = 100 - bondPercent - goldPercent
        
    dollarInRub = getLastPrice(DOLLAR_FIGI)

    positions = TinkoffRestApi.getPortfolio(API_TOKEN)

    currencyPositions = TinkoffRestApi.getPortfolioCurrencies(API_TOKEN)
    currencySumm = calcPositionSumInRub(currencyPositions, dollarInRub)

    bondPositions = positions.select { |x| x.instrumentType == "Bond" }        
    bondSumm = calcPositionSumInRub(bondPositions, dollarInRub)
        
    goldPositions = positions.select { |x| x.ticker == "TGLD" }
    goldSumm = calcPositionSumInRub(goldPositions, dollarInRub)
    
    stocksPositions = positions.select { |x| x.ticker == "AKNX" || x.ticker == "FXIT" }
    stocksSumm = calcPositionSumInRub(stocksPositions, dollarInRub)
    
    totalSumm = bondSumm + goldSumm + stocksSumm + currencySumm

    stockRatio = (stocksSumm/totalSumm)*100
    bondRatio = (bondSumm/totalSumm)*100
    goldRatio = (goldSumm/totalSumm)*100

    stockDeviationPercent = stockRatio - stockPercent
    stockDeviation = (totalSumm / 100) * stockDeviationPercent

    bondDeviationPercent = bondRatio - bondPercent
    bondDeviation = (totalSumm / 100) * bondDeviationPercent

    goldDeviationPercent = goldRatio - goldPercent
    goldDeviation = (totalSumm / 100) * goldDeviationPercent

    next {
        strategyRatios: {
            stocks: stockPercent,
            bonds: bondPercent,
            gold: goldPercent
        },
        dollar: {
            value: dollarInRub.round(3),
            currency: "RUB"
        },                
        stocks: {
            price: {
                value: stocksSumm.round(2),
                currency: "RUB"
            },
            ratio: stockRatio.round(2),
            deviation: {
                value: stockDeviation.round(2),
                currency: "RUB"
            },            
            deviationPercent: stockDeviationPercent.round(2)
        },
        bonds: {
            price: {
                value: bondSumm.round(2),
                currency: "RUB"
            },
            ratio: bondRatio.round(2),
            deviation: {
                value: bondDeviation.round(2),
                currency: "RUB"
            },            
            deviationPercent: bondDeviationPercent.round(2)
        },
        gold: {
            price: {
                value: goldSumm.round(2),
                currency: "RUB"
            },
            ratio: goldRatio.round(2),
            deviation: {
                value: goldDeviation.round(2),
                currency: "RUB"
            },            
            deviationPercent: goldDeviationPercent.round(2)
        },
        currency: {
            price: {
                value: currencySumm.round(2),
                currency: "RUB"
            },
            ratio: ((currencySumm/totalSumm)*100).round(2),
        }
    }.to_json       
end
  
Kemal.run 8090