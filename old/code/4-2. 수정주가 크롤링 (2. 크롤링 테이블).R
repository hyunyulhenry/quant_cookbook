library(rvest)
library(httr)
library(lubridate)
library(xts)
library(tibble)

ticker = read.csv("KOR_ticker.csv", row.names = 1, stringsAsFactors = FALSE)
# setwd("./price_crawl")

# 티커 앞의 0이 삭제되는 현상 발생
# 6자리 만큼 앞에 0을 채워주도록 함

ticker$종목코드 = str_pad(ticker$종목코드, width = 6,
                      side = 'left', pad = 0)


# 일별시세: https://finance.naver.com/item/sise.nhn?code=005930

for (i in 1:nrow(ticker)) {

  # i = 1
  name = ticker[i, '종목코드']
  price = list(xts(NA, order.by = Sys.Date()))
  
  test.url = paste0('https://finance.naver.com/item/sise_day.nhn?code=',
                    name,'&page=1')
  
  test.data = GET(test.url) 
  
  # 해당 종목의 페이지가 몇페이지 까지 있는지 확인
  navi.final = test.data %>%
    read_html() %>%
    html_nodes('.pgRR') %>%
    html_nodes('a') %>%
    html_attr('href') %>%
    str_split('=') %>%
    unlist() %>%
    last(1) %>% 
    as.numeric()
  
  # 최종 페이지와 크롤링 한계 페이지(10) 중 작은 값을 선택
  # 상장된 일자가 오래된 종목: 10번째 페이지 까지만 크롤링
  # 상장된 일자가 얼마되지 않은 종목: 존재하는 페이지만 크롤링
  iter.page = min(navi.final, 10)
  
  tryCatch({
    
    # 각 페이지 별로 크롤링
    for (j in 1:iter.page) {
      # j = 1
      url = paste0('https://finance.naver.com/item/sise_day.nhn?code=',
                   name,'&page=',j)

      Sys.setlocale("LC_ALL", "English")
      data = GET(url)
      data_table = read_html(data) %>%
        html_table()
      Sys.setlocale("LC_ALL", "Korean")
      
      # 주가 표에서 날짜와 종가 부분만을 선택
      data_table = data_table[[1]][c('날짜', '종가')]
      # data_table
      
      # 빈 행은 삭제
      data_table[data_table == ""] = NA
      data_table = na.omit(data_table)
      # data_table

      data_table$날짜 = ymd(data_table$날짜)
      data_table$종가 = readr::parse_number(data_table$종가)
      # data_table
      
      rownames(data_table) = NULL
      data_table = column_to_rownames(data_table, var = '날짜')
      # data_table

      data_table = as.xts(data_table)

      price[[j]] = data_table
      Sys.sleep(0.5)
    }

  }, error = function(e) {
    print(paste0("Error in Ticker: ", name))}
  )

  price = do.call(rbind, price)
  price = price[!duplicated(index(price))]

  write.csv(data.frame(price), paste0(name, "_price.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(2)
}
