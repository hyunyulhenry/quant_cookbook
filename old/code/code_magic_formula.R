ticker = read.csv("KOR_ticker.csv", row.names = 1)
fs = readRDS("KOR_fs.RDS")
value = read.csv("KOR_value.csv", row.names = 1)

## 1. 자본수익률
## 이자및법인세차감전이익(EBIT) / 투하자본(IC)
## ( 당기순이익 + 법인세 + 이자비용 ) / ( (유동자산 - 유동부채) + (비유동자산 - 감가상각비) )

## 2. 이익수익률
## 이자및법인세차감전이익(EBIT) / (시가총액+ 순차입금)
## ( 당기순이익 + 법인세 + 이자비용 ) / ( 시가총액 + Total Debt - Excess Cash )
## Excess Cash: 현금 - max(0, 유동부채 - 유동자산 + 현금)


## 1. 자본수익률
magic = list()
magic$EBIT = fs$지배주주순이익 + fs$법인세비용 + fs$이자비용
magic$IC = (fs$유동자산 - fs$유동부채) + (fs$비유동자산 - fs$감가상각비)
magic$ROC = magic$EBIT / magic$IC

## 2. 이익수익률
magic$cap = value$PER * fs$지배주주순이익

magic$excess.cash = fs$유동부채 - fs$유동자산 + fs$현금및현금성자산
magic$excess.cash[magic$excess.cash < 0] = 0
magic$excess.cash = fs$현금및현금성자산 - magic$excess.cash
magic$net.debt = fs$부채 - magic$excess.cash
magic$ev = magic$cap + magic$net.debtmagi
magic$EY = magic$EBIT / magic$ev

ROE = fs$지배주주순이익 / fs$자산
cor(rank(ROE[,3]), rank(magic$ROC[,3]))
cor(rank(value$PER), rank(1/magic$EY[,3]))

# Portfolio
rank.magic = rank(-magic$ROC[,3]) +  rank(-magic$EY[,3])
rank.magic = data.frame(rank(rank.magic))

invest.magic = which(rank.magic <= 30)

magic$ROC[invest.magic, 3]
magic$EY[invest.magic, 3]

ROE[invest.magic, 3]
value$PER[invest.magic]

ticker[invest.magic, 2]

