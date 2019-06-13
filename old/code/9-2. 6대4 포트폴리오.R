library(quantmod)
library(PerformanceAnalytics)

ticker = c("SPY","TLT")
# SPY: S&P 500 ####################
# TLT: iShares 20+ Year T-Bond ####
getSymbols(ticker, from = "2003-01-01", to = "2017-12-31")

prices = do.call(cbind, lapply(ticker, function(x) Ad(get(x))))
rets = Return.calculate(prices)[-1,]
cor(rets)

# 60:40 Portfolio
portfolio = Return.portfolio(R = rets,
                             weights = c(0.6, 0.4),
                             rebalance_on = "years")
portfolios = cbind(rets, portfolio)


charts.PerformanceSummary(portfolios, main = "Portfolios")
