require "http"
require "crest"
require "json"

begin  
    res = Crest.get(
        "http://localhost:8090/portfolio"
    )

    response = JSON.parse(res.body)

    dollarInRub = response["dollar"]["value"].to_s.to_f64

    stockPercent = response["strategyRatios"]["stocks"].to_s.to_i
    bondPercent = response["strategyRatios"]["bonds"].to_s.to_i
    goldPercent = response["strategyRatios"]["gold"].to_s.to_i

    currencySumm = response["currency"]["price"]["value"].to_s.to_f64
    stocksSumm = response["stocks"]["price"]["value"].to_s.to_f64
    bondSumm = response["bonds"]["price"]["value"].to_s.to_f64
    goldSumm = response["gold"]["price"]["value"].to_s.to_f64

    totalSumm = bondSumm + goldSumm + stocksSumm + currencySumm

    puts "Стратегия жадный лежебока:"
    puts "Акции #{stockPercent}% Облигации #{bondPercent}% Золото #{goldPercent}%"
    puts "Курс доллара: #{dollarInRub.round(3)} руб"
    puts ""

    puts "Валюты:"    
    puts "Цена: #{currencySumm.round(2)} руб"
    puts "Доля: #{((currencySumm/totalSumm)*100).round(2)}%"
    puts ""

    stockRatio = (stocksSumm/totalSumm)*100
    puts "Акции:"
    puts "Цена: #{stocksSumm.round(2)} руб"
    puts "Доля: #{stockRatio.round(2)}%"
    stockDeviationPercent = stockRatio - stockPercent
    stockDeviation = (totalSumm / 100) * stockDeviationPercent
    puts "Отклонение: #{stockDeviationPercent.round(2)}% #{stockDeviation.round(2)} руб"
    puts ""

    bondRatio = (bondSumm/totalSumm)*100
    puts "Облигации:"
    puts "Цена: #{bondSumm.round(2)} руб"
    puts "Доля: #{bondRatio.round(2)}%"
    bondDeviationPercent = bondRatio - bondPercent
    bondDeviation = (totalSumm / 100) * bondDeviationPercent
    puts "Отклонение: #{bondDeviationPercent.round(2)}% #{bondDeviation.round(2)} руб"
    puts ""

    goldRatio = (goldSumm/totalSumm)*100
    puts "Золото:"
    puts "Цена: #{goldSumm.round(2)} руб"
    puts "Доля: #{goldRatio.round(2)}%"
    goldDeviationPercent = goldRatio - goldPercent
    goldDeviation = (totalSumm / 100) * goldDeviationPercent
    puts "Отклонение: #{goldDeviationPercent.round(2)}% #{goldDeviation.round(2)} руб"
    puts ""

    puts "Всего: #{totalSumm.round(2)} руб, #{(totalSumm/dollarInRub).round(2)} $ "    
rescue e
    p e
end