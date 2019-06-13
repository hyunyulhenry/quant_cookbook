url_NYSE =
  "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download"
url_NASDAQ =
  "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download"
url_AMEX =
  "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amexe&render=download"

download.file(url_NYSE, destfile = "./url_NYSE.csv")
download.file(url_NASDAQ, destfile = "./url_NASDAQ.csv")
download.file(url_AMEX, destfile = "./url_AMEX.csv")

NYSE = read.csv("./url_NYSE.csv", stringsAsFactors = F)
NASDAQ = read.csv("./url_NASDAQ.csv", stringsAsFactors = F)
AMEX = read.csv("./url_AMEX.csv", stringsAsFactors = F)

us.ticker = rbind(NYSE, NASDAQ, AMEX)

us.ticker = us.ticker[us.ticker$MarketCap != "n/a", ]
us.ticker = us.ticker[us.ticker$Sector != "n/a", ]
us.ticker = us.ticker[!duplicated(us.ticker$Name), ]

us.ticker$Symbol = gsub(" ", "", us.ticker$Symbol)
rownames(us.ticker) = NULL
write.csv(us.ticker, "US_ticker.csv")

file.remove("./url_NYSE.csv")
file.remove("./url_NASDAQ.csv")
file.remove("./url_AMEX.csv")
  