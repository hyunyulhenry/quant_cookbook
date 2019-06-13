library(magrittr)

ticker = read.csv("KOR_ticker.csv", row.names = 1)
fs = readRDS("KOR_fs.Rds")

# Gross Profit #
fs.gross.profit = fs$매출총이익
fs.asset = fs$자산
fs.gpa = fs.gross.profit / fs.asset

rank.gpa = apply(-fs.gpa[,3,drop = FALSE], 2, rank)
invest.gpa = rank.gpa <= 30

fs.gpa[invest.gpa , 3, drop = FALSE]

fs$`ROE(%)`[invest.gpa, 5]
fs$`ROA(%)`[invest.gpa, 5]


# F-Score #
ROA = data.fs$'당기순이익' / data.fs$'자산총계'
CFO = data.fs$'영업활동으로인한현금흐름' / data.fs$'자산총계'
ACCURUAL = CFO - ROA

LEV = data.fs$'....장기차입금' / data.fs$'자산총계'
LIQ = data.fs$'유동자산' / data.fs$'유동부채'
OFFER = data.fs$'발행주식수'
MARGIN = data.fs$'매출총이익' / data.fs$'매출액(수익)'
TURN = data.fs$'매출액(수익)' / data.fs$'자산총계'

F.1 = as.integer(ROA[,5] > 0)
F.2 = as.integer(CFO[,5] > 0)
F.3 = as.integer(ROA[,5] - ROA[,4] > 0)
F.4 = as.integer(ACCURUAL[,5] > 0)
F.5 = as.integer(LEV[,5] - LEV[,4] <= 0)
F.6 = as.integer(LIQ[,5] - LIQ[,4] > 0)
F.7 = as.integer(OFFER[,5] - OFFER[,4] <= 0)
F.8 = as.integer(MARGIN[,5] - MARGIN[,4] > 0)
F.9 = as.integer(TURN[,5] - TURN[,4] > 0)

F.Table = cbind(F.1, F.2, F.3, F.4, F.5, F.6, F.7, F.8, F.9) %>%
  data.frame()

colnames(F.Table) = c("ROA", "CFO", "D ROA",
                      "Accrual", "D Leverage", "D Liquidity",
                      "Offer", "D Margin", "D Turnover")
rownames(F.Table) = data.fs[[1]] %>% rownames()

F.score = apply(F.Table, 1, sum, na.rm = TRUE) %>% data.frame()

rownames(F.score)[which(F.score >= 9 )]

# Quality Multi #
fs.gpa = (fs$매출총이익 / fs$자산총계)[,5] %>% data.frame()
fs.gp.growth = (fs$매출총이익[,5] -  fs$매출총이익[,1]) / fs$자산총계[,1] %>% data.frame()
fs.leverage = (fs$부채총계 / fs$자산총계)[,5] %>% data.frame()

rank.quality = ( rank(-fs.gpa) + rank(-fs.gp.growth) + rank(fs.leverage) ) %>% rank()
invest.quality = which(rank.quality <= 30)
rank(-fs.gpa)[invest.quality] 
rank(-fs.gp.growth)[invest.quality]
rank(fs.leverage)[invest.quality]

ticker[invest.quality, 2]


      
