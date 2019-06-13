library(magrittr)
library(xts)

ticker = read.csv("KOR_ticker.csv", row.names = 1)
value = read.csv("KOR_value.csv", row.names = 1)
price = read.csv("KOR_price.csv", row.names = 1) %>% as.xts()

apply(value, 2, median, na.rm = TRUE)
summary(value)

value.reshape = cbind(value[,1:4], 1/value[,5])
value.reshape[value.reshape < 0] = NA
rank.value = apply(value.reshape, 2, rank)
rank.value = rowSums(rank.value) %>% rank %>% data.frame()

invest.value = which(rank.value <= 30)
value[invest.value, ]
apply(value[invest.value, ], 2, median, na.rm = TRUE)

# Correlation with Momentum #
ret = Return.calculate(price)
ret.last.12m = last(ret, "12 month")
ret.cum.12m = Return.cumulative(ret.last.12m) %>% t()
rank.mom = rank(-ret.cum.12m) %>% data.frame()
cor(rank.value, rank.mom)
