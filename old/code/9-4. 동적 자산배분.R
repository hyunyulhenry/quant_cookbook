library(HenryQuant)
library(quantmod)
library(PerformanceAnalytics)

symbols = c("SPY","IEV","EWJ","EEM","TLT","IEF","IYR","RWX","GLD","DBC")
getSymbols(symbols, src='yahoo', from = "2007-01-01", to = "2017-12-31")

# SPY: S&P 500
# IEV: iShares S&P EURO 350
# EWJ: iShares MSCI Japan ETF
# EEM: iShares MSCI Emerging Markets ETF
# TLT: iShares Barclays 20+ Yr Trasry Bond ETF
# IEF: iShares Barclays 7-10 Year Trasry Bond ETF
# IYR: iShares Dow Jones US Real Estate
# RWX: SPDR Dow Jones Interntnl Real Estate ETF
# GLD: SPDR Gold Trust (ETF)
# DBC: PowerShares DB Commodity  Index Trckng Fund(ETF)

prices = do.call(merge, lapply(symbols, function(x) Ad(get(x))))
rets = Return.calculate(prices)[-1,]

ep = endpoints(rets, on = "months")
wts = list()
lookback = 12
fee = 0.0030

for (i in (lookback+1) : length(ep)) {
  subret = rets[ep[i-lookback] : ep[i] , ]
  cum = Return.cumulative(subret)
  
  K = which(rank(-cum) <= 5)
  covmat = cov(subret[, K])
  
  wt = rep(0, 10)
  wt[K] = wt_RiskBudget(covmat)
  wts[[i]] = xts(t(wt), order.by = index(rets[ep[i]]))
}

wts = do.call(rbind, wts)
DAA = Return.portfolio(rets, wts, verbose = TRUE)
charts.PerformanceSummary(DAA$returns)

DAA$turnover = xts(rowSums(abs(DAA$BOP.Weight - lag(DAA$EOP.Weight)), na.rm = TRUE),
                   order.by = index(DAA$BOP.Weight))
DAA$net = DAA$returns - DAA$turnover*fee

charts.PerformanceSummary(cbind(DAA$returns, DAA$net))
