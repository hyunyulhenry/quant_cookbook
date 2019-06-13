# From Quandl
# 참조: https://docs.quandl.com/
  
# AAPL 
url.aapl = "https://www.quandl.com/api/v3/datasets/WIKI/AAPL/data.csv?api_key=xw3NU3xLUZ7vZgrz5QnG"
data.aapl = read.csv(url.aapl)

head(data.aapl)

# NETFLIX
url.nflx = "https://www.quandl.com/api/v3/datasets/WIKI/NFLX/data.csv?api_key=xw3NU3xLUZ7vZgrz5QnG"
data.nflx = read.csv(url.nflx)

head(data.nflx)


# From Yahoo Finance, Using quantmod
# install.packages('quantmod')
library(quantmod)

# US Data
getSymbols("AAPL")
head(AAPL)
chart_Series(Ad(AAPL))

getSymbols("AAPL", from = "2000-01-01", to = "2017-12-31")
head(AAPL)
tail(AAPL)

data = getSymbols("AAPL", from = "2000-01-01", to = "2017-12-31", auto.assign = FALSE)
head(data)
tail(data)

ticker = c("FB", "NVDA")
getSymbols(ticker)
head(FB)
head(NVDA)


# KOREA Data
# 삼성전자
getSymbols("005930.KS", from = "2000-01-01", to = "2017-12-31")
tail(Ad(`005930.KS`))
tail(Cl(`005930.KS`))

# 셀트리온제약
getSymbols("068760.KQ", from = "2000-01-01", to = "2017-12-31")
tail(Cl(`068760.KQ`))

# From FRED, Using quantmod
# https://fred.stlouisfed.org/
getSymbols("DGS10", src="FRED")
chart_Series(DGS10)

getSymbols("DEXKOUS", src="FRED")
tail(DEXKOUS)
chart_Series(DEXKOUS)

