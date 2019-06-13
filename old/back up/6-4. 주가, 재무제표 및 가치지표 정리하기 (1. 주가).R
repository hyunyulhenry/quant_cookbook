ticker = read.csv("US_ticker.csv", row.names = 1)
setwd("./price_US")

library(quantmod)
library(magrittr)

price_list = list()
for (i in 1 : nrow(ticker)) {
  
  name = ticker[i, 'Symbol'] %>% as.character()
  price_list[[i]] = read.csv(paste0(name, "_price.csv"), row.names = 1) %>%
    as.xts()
  
}

price_list = do.call(cbind, price_list)
price_list = na.locf(price_list)
colnames(price_list) = ticker$Symbol
write.csv(data.frame(price_list), "US_price.csv")


