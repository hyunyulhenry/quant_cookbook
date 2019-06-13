library(quantmod)
library(PerformanceAnalytics)

symbols = c("SPY","SHY")
# SPY: S&P 500 
# SHY: 1-3 Year Treasury Bond
getSymbols(symbols, src="yahoo", from = "2003-01-01", to = "2017-12-31")

prices = do.call(cbind, lapply(symbols, function(x) Ad(get(x))))
rets = Return.calculate(prices)[-1,]

ep = endpoints(rets, on = "months")
# index(rets)[ep]
wts = list()
lookback = 10

for (i in (lookback+1) : length(ep)) {
  sub.price = prices[ep[i-lookback] : ep[i] , 1]
  sma = mean(sub.price)
  wt = rep(0, 2)
  wt[1] = ifelse(last(sub.price) > sma, 1, 0)
  wt[2] = 1 - wt[1]
  
  wts[[i]] = xts(t(wt), order.by = index(rets[ep[i]]))
}

wts = do.call(rbind, wts)
Tactical = Return.portfolio(rets, wts)
Compare = na.omit(cbind(rets[,1], Tactical))
charts.PerformanceSummary(Compare, main = "Buy & Hold vs Tactical")
