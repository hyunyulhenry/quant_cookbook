ticker = read.csv("KOR_ticker.csv", row.names = 1)

library(quantmod)
library(magrittr)

# (1) Yahoo API 이용시
price_list = list()
for (i in 1 : nrow(ticker)) {
  
  name = paste0(ticker[i, '종목코드'], ".", ticker[i, 'market'])
  price_list[[i]] = read.csv(paste0(name, "_price.csv"), row.names = 1) %>%
    as.xts()

}

price_list = do.call(cbind, price_list)
price_list = na.locf(price_list)
colnames(price_list) = ticker$종목코드
write.csv(data.frame(price_list), "KOR_price.csv")



# (2) 다음 금융 크롤링 이용시
price_list = list()
for (i in 1 : nrow(ticker)) {
  
  name = ticker[i, '종목코드'] %>% as.character()
  price_list[[i]] = read.csv(paste0(name, "_price.csv"), row.names = 1) %>%
    as.xts()
  
}

price_list = do.call(cbind, price_list)
price_list = na.locf(price_list)
colnames(price_list) = ticker$종목코드
write.csv(data.frame(price_list), "KOR_price.csv")

