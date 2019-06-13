# 변동성

example = c(85,76,73,80,72)
sd(example)


# 각 종목들의 변동성 계산
library(xts)
library(PerformanceAnalytics)
library(magrittr)

ticker = read.csv("KOR_ticker.csv", row.names = 1)
price = read.csv("KOR_price.csv", row.names = 1) %>% as.xts()
# indexClass(price) = "Date"

head(index(price))
tail(index(price))

ret = Return.calculate(price)
ret.last.12m = last(ret, '12 month')
head(index(ret.last.12m))
tail(index(ret.last.12m))

std.12m.daily = apply(ret.last.12m, 2, sd) %>% data.frame()
std.12m.daily[std.12m.daily == 0] = NA
std.12m.weekly =  apply.weekly(ret.last.12m, Return.cumulative) %>%
  apply(., 2, sd) %>% data.frame()

std.rank = cbind(std.12m.daily, std.12m.weekly) %>% na.omit() %>%
  apply(., 2, rank)

plot(std.rank,
     xlab = "Daily Std Rank", ylab = "Weekly Std Rank", pch = 4)
abline(a=0, b=1, col = 2)
cor(std.rank[,1], std.rank[,2])

# 저변동성 상위 30 종목 #
invest.vol = rank(std.12m.daily) <= 30
ticker[invest.vol, 2]
std.12m.daily[invest.vol, ]

# 극단치 제거 후 상위 30 종목 #
low.point = quantile(std.12m.daily, 0.01, na.rm = TRUE)
std.12m.daily[std.12m.daily < low.point] = NA

invest.vol = rank(std.12m.daily) <= 30
ticker[invest.vol, 2]
std.12m.daily[invest.vol, ]
