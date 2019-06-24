Sys.setenv(TZ = "UTC")

library(magrittr)
library(RiskPortfolios)
library(tidyr)
library(ggplot2)

rets = read.csv('data/data_global.csv', stringsAsFactors = FALSE, row.names = 1) %>% xts::as.xts()

ep = endpoints(rets, on = 'months')
wts = list()
lookback = 12
fee = 0.0030
wt_zero = rep(0, 10) %>% setNames(colnames(rets))

for (i in (lookback+1) : length(ep)) {
  sub_ret = rets[ep[i-lookback] : ep[i] , ]
  cum = Return.cumulative(sub_ret)
  
  K = which(rank(-cum) <= 5)
  covmat = cov(sub_ret[, K])
  
  wt = wt_zero
  wt[K] = optimalPortfolio(covmat, control = list(type = 'minvol', constraint = 'user',
                                                  LB = rep(0.10, 5), UB = rep(0.30, 5)))
  
  wts[[i]] = xts(t(wt), order.by = index(rets[ep[i]]))
}

wts = do.call(rbind, wts)

GDAA = Return.portfolio(rets, wts, verbose = TRUE)
charts.PerformanceSummary(GDAA$returns)

wts %>% fortify.zoo() %>%
  gather(key, value, -Index) %>%
  mutate(Index = as.Date(Index)) %>%
  mutate(key = factor(key, levels = unique(key))) %>%
  ggplot(aes(x = Index, y = value)) +
  geom_area(aes(color = key, fill = key), position = 'stack') +
  xlab(NULL) + ylab(NULL) +  theme_bw() +
  scale_x_date(date_breaks="years", date_labels="%Y",
               expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  theme(plot.title = element_text(hjust = 0.5,
                                  size = 12),
        legend.position = 'bottom',
        legend.title = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        panel.grid.minor.x = element_blank()) +
  guides(color = guide_legend(byrow = TRUE))

GDAA$turnover = xts(rowSums(abs(GDAA$BOP.Weight - timeSeries::lag(GDAA$EOP.Weight)), na.rm = TRUE),
               order.by = index(GDAA$BOP.Weight))
chart.TimeSeries(GDAA$turnover)

GDAA$net = GDAA$returns - GDAA$turnover*fee

cbind(GDAA$returns, GDAA$net) %>%
  setNames(c('No Fee', 'After Fee')) %>%
  charts.PerformanceSummary(main = 'Global Dynamic Asset Allocation')

