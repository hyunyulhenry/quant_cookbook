library(HenryQuant)
library(quantmod)
library(PerformanceAnalytics)

getSymbols("SPY")
prices = Ad(get("SPY"))
rets = Return.calculate(prices)[-1, ]

summary(rets)

chart.CumReturns(rets) 
chart.Bar(rets)
chart.Drawdown(rets)
charts.PerformanceSummary(rets)
chart.Histogram(rets, breaks = 50)
chart.Histogram(rets, breaks = 50, show.outliers = FALSE)

Return.cumulative(rets)
Return.annualized(rets, geometric = FALSE)

Return.annualized(rets, geometric = TRUE)
StdDev.annualized(rets)
SharpeRatio.annualized(rets)
table.AnnualizedReturns(rets)

maxDrawdown(rets)
table.Drawdowns(rets)


port_eval = function(R) {
  table = rbind(
    Return.cumulative(R),
    table.AnnualizedReturns(R),
    maxDrawdown(R)
  )
  return(table)
}
port_eval(rets)
