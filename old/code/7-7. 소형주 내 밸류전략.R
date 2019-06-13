library(magrittr)

ticker = read.csv("KOR_ticker.csv", row.names = 1)
value = read.csv("KOR_value.csv", row.names = 1)

cut.size = quantile(ticker$시가총액, 0.5)
size.small = which(ticker$시가총액 < cut.size)
size.big = which(ticker$시가총액 >= cut.size)

apply(value[size.small, ], 2, median, na.rm = TRUE)
apply(value[size.big, ], 2, median, na.rm = TRUE)

max(ticker[size.small, '시가총액비중...'])

value.reshape = cbind(value[,1:4], 1/value[,5])
value.reshape[size.big, ] = NA
value.reshape[value.reshape < 0] = NA
rank.value = apply(value.reshape, 2, rank)
rank.value = rowSums(rank.value) %>% rank %>% data.frame()

invest.value = which(rank.value <= 30)
ticker[invest.value, 2]
value[invest.value, ]
apply(value[invest.value, ], 2, median, na.rm = TRUE)

