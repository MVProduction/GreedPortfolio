require "./storage_portfolio"

# Хранилище данных
class DataStorage
    # Сохраняет данные по портфелю за дату
    def savePortfolio(date : Time, portfolio : PortfolioStorageData)
        
    end

    # Возвращает данные по портфелю за дату
    def getPortfolio(date : Time) : PortfolioStorageData
    end
end