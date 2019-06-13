ticker = read.csv("US_ticker.csv", row.names = 1)
setwd("./price_US")

library(quantmod)
library(magrittr)

for (i in 1 : nrow(ticker)) {
  name = ticker[i, 'Symbol'] %>% as.character
  price = xts(NA, order.by = Sys.Date())
  
  tryCatch({
    price = Ad(getSymbols(name, auto.assign = FALSE))
  }, error = function(e) {
    print(paste0("Error in Ticker: ", name))
  })
  
  price = price[!duplicated(index(price))]
  
  write.csv(data.frame(price), paste0(name, "_price.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(3)
}


