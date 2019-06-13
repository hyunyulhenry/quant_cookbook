library(xts)
library(magrittr)
library(PerformanceAnalytics)

ticker = read.csv("KOR_ticker.csv", row.names = 1)
price = read.csv("KOR_price.csv", row.names = 1) %>% as.xts()
ret = Return.calculate(price)

ret.last.12m = last(ret, "12 month")
ret.cum.12m = Return.cumulative(ret.last.12m) %>% t()
invest.mom = which(rank(-ret.cum.12m) <= 30)
ticker[invest.mom, 2]
ret.cum.12m[invest.mom, ]

par(mfrow = c(6,5))
sapply(price[,invest.mom], function(x) {
  x = last(x, "12 months")
  plot(as.xts(x), main = "")
  })

# Sharpe Ratio #
std.last.12m.daily = apply(ret.last.12m, 2, sd) %>% data.frame()

sharpe.12m = ret.cum.12m / std.last.12m.daily
invest.mom.sharpe = which(rank(-sharpe.12m) <= 30)
ticker[invest.mom.sharpe, 2]
ret.cum.12m[invest.mom.sharpe, ]

par(mfrow = c(6,5))
sapply(price[,invest.mom.sharpe], function(x) {
  x = last(x, "12 months")
  plot(as.xts(x), main = "")
  })

intersect(invest.mom, invest.mom.sharpe)

# K Ratio #
K.ratio = sapply(ret.last.12m, function(R) {
  if (sum(!is.na(R)) >= 200) {
    R = na.omit(R)
    R = cumprod(1+R) - 1
    reg = lm( R ~ c(1:length(R)) )
    ratio = coef(summary(reg))[2, 1]/coef(summary(reg))[2, 2]
    return(ratio)
  } else {
    NA
  }
})

K.ratio = data.frame(K.ratio)
invest.K.ratio = which(rank(-K.ratio) <= 30)
ticker[invest.K.ratio, 2]
ret.cum.12m[invest.K.ratio, ]

par(mfrow = c(6,5))
sapply(price[,invest.K.ratio], function(x) {
  x = last(x, "12 months")
  plot(as.xts(x), main = "")
  })
