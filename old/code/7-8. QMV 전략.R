library(magrittr)
library(PerformanceAnalytics)

ticker = read.csv("KOR_ticker.csv", row.names = 1)
price = read.csv("KOR_price.csv", row.names = 1)
fs = readRDS("KOR_fs.Rds")
value = read.csv("KOR_value.csv", row.names = 1)


# Winsorizing & Truncation #
sort(value$PBR) %>% head(., 10)
sort(value$PBR) %>% tail(., 10)

quantile(value$PBR, 0.01)


# Z-Score vs Ranking & Z-Score
par(mfrow = c(1,2))
scale(value) %>% rowSums() %>% hist(., main = "단순 Z-Score 합계", breaks = 50, col = 4)
rank(value) %>% scale() %>% rowSums() %>% hist(., main = "랭킹 후 Z-Score의 합계", breaks = 50, col = 4)




# Quality #
fs.gpa = (fs$매출총이익 / fs$자산총계)[,5] %>% data.frame()
fs.gp.growth = (fs$매출총이익[,5] -  fs$매출총이익[,1]) / fs$자산총계[,1] %>% data.frame()
fs.leverage = (fs$부채총계 / fs$자산총계)[,5] %>% data.frame()

scale.quality = cbind(rank(-fs.gpa), rank(-fs.gp.growth), rank(fs.leverage)) %>% scale() %>%
  rowSums() %>% data.frame()

# Momentum
ret = Return.calculate(price)
ret.6m.cum = last(ret, "6 months") %>% Return.cumulative() %>% t()
ret.12m.cum = last(ret, "12 months") %>% Return.cumulative() %>% t()

scale.momentum = cbind(rank(-ret.6m.cum), rank(-ret.12m.cum)) %>% scale() %>% 
  rowSums() %>% data.frame()

# value
scale.value = rank(value) %>% scale() rowSums() %>% data.frame()


# QMV
scale.quality + 


      
