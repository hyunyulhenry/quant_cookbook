ticker = read.csv("KOR_ticker.csv", row.names = 1)
setwd("./price_yahoo")

# (1) yahoo API 이용

library(quantmod)

for (i in 1 : nrow(ticker)) {
  name = paste0(ticker[i, '종목코드'], ".", ticker[i, 'market'])
  price = xts(NA, order.by = Sys.Date())
  
  price = Cl(getSymbols(name, auto.assign = FALSE))
  
  write.csv(data.frame(price), paste0(name, "_price.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(2)
}

# (2) yahoo API 이용 (Error 스킵)

for (i in 1 : nrow(ticker)) {
  name = paste0(ticker[i, '종목코드'], ".", ticker[i, 'market'])
  price = xts(NA, order.by = Sys.Date())
  
  tryCatch({
    price = Cl(getSymbols(name, auto.assign = FALSE))
  }, error = function(e) {
    print(paste0("Error in Ticker: ", name))
  })
  
  price = price[!duplicated(index(price))]
  
  write.csv(data.frame(price), paste0(name, "_price.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(3)
}
