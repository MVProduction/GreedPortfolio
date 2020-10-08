require "json"
require "invest_api"

API_TOKEN   = "t.doZaNd1KKt9gphFGYZ4XlEhignGZQNAalYSMZG2Wq48MwK9CNuqB5Y1z41J7ccT4ISXRu8-evh4QXDCZ4XVh8Q"
DOLLAR_FIGI = "BBG0013HGFT4"

# Собирает данные по портфелю
class PortfolioCollector  
  @@instance = PortfolioCollector.new

  private def self.instance : PortfolioCollector
    @@instance
  end

  # Признак что находится в работе
  @working = false

  # Считает сумму по позициям в рублях
  private def calcPositionSumInRub(positions : Array(TinkoffPortfolioPosition), dollarInRub : Float64) : Float64
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
  private def calcPositionSumInRub(positions : Array(TinkoffPortfolioCurrencyPosition), dollarInRub : Float64) : Float64
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
  private def getLastPrice(figi : String) : Float64
    to = Time.local
    from = to - Time::Span.new(days: 7)
    candles = TinkoffRestApi.getMarketCandles(API_TOKEN, figi, from, to, TinkoffCandleInterval::Day)
    return candles.last.close
  end

  # Собирает данные по портфелю
  private def collect
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

    p goldDeviation
  end

  # Запускает выполнение
  def start
    @working = true

    spawn do
      while @working        
        now = Time.local
        # Ждёт начала часа
        if !(now.minute == 5 && now.second == 0)
            sleep 10
            next
        end
        
        p now
      end
    end
  end

  # Останавливает работу
  def stop
    @working = false
  end
end
