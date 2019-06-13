# Financial Statement
ticker = read.csv("US_ticker.csv", row.names = 1)
setwd("./fs_us")

library(rvest)
library(httr)

for (i in 1 : nrow(ticker)) {

  name = ticker[i, 'Symbol'] %>% as.character
  data_fs = c()
  
  tryCatch({
    Sys.setlocale("LC_ALL", "English")
    yahoo.finance.xpath = '//*[@id="Col1-1-Financials-Proxy"]/section/div[3]/table'
    
    IS = paste0("https://finance.yahoo.com/quote/",name,"/financials?p=",name) %>%
      GET() %>% read_html() %>% html_nodes(xpath = yahoo.finance.xpath) %>%
      html_table() %>% data.frame()
    Sys.sleep(0.5)

    BS = paste0("https://finance.yahoo.com/quote/",name,"/balance-sheet?p=",name) %>%
      GET() %>% read_html() %>% html_nodes(xpath = yahoo.finance.xpath) %>%
      html_table() %>% data.frame()
    Sys.sleep(0.5)
    
    CF = paste0("https://finance.yahoo.com/quote/",name,"/cash-flow?p=",name) %>%
      GET() %>% read_html() %>% html_nodes(xpath = yahoo.finance.xpath) %>%
      html_table() %>% data.frame()
    
    data_fs = rbind(IS, BS, CF)
    data_fs = data_fs[!duplicated(data_fs[, 1]), ]

    colnames(data_fs) = data_fs[1,]
    data_fs = data_fs[-1, ]

    rownames(data_fs) = data_fs[,1]
    data_fs = data_fs[,-1]

    for (j in 1:ncol(data_fs)) {
      data_fs[, j] = gsub(",", "", data_fs[, j]) %>% as.numeric
    }

    colnames(data_fs) = sapply(colnames(data_fs), function(x) {
      substring(x,nchar(x)-3, nchar(x))
      })

  }, error = function(e) {
    data_fs <<- NA
    print(paste0("Error in Ticker: ", name))}
  )

  write.csv(data_fs, paste0(name, "_fs.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(3)

}


# Valuation
ticker = read.csv("US_ticker.csv", row.names = 1)
setwd("./value_us")

library(quantmod)
library(magrittr)

for (i in 1 : nrow(ticker)) {

  name = ticker[i, 'Symbol'] %>% as.character
  data_value = c()

  tryCatch({
    Ratios = yahooQF(c("P/E Ratio", "Price/Book", "Dividend Yield"))
    data_value = getQuote(name, what = Ratios)[-1]

  }, error = function(e) {
    data_value <<- NA
    print(paste0("Error in Ticker: ", name))}
  )

  write.csv(data_value, paste0(name, "_value.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(3)

}
