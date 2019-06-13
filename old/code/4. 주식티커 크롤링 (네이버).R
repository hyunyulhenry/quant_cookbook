# 네이버에서 주식티커 크롤링 
# 코스피: https://finance.naver.com/sise/sise_market_sum.nhn?sosok=0
# 코스닥: https://finance.naver.com/sise/sise_market_sum.nhn?sosok=1

library(httr)
library(rvest)

data = list()

for (i in 0:1) {
  
  # 0일 경우 코스피, 1일 경우 코스닥
  mkt = ifelse(i == 0, '코스피', '코스닥')
  
  ticker = list()
  url = paste0("https://finance.naver.com/sise/sise_market_sum.nhn?sosok=",i,"&page=1")
  down_table = GET(url)
  
  # 맨뒤에 해당하는 페이지 네비게이션을 찾음
  navi.final = read_html(down_table, encoding = "EUC-KR") %>%
    html_nodes(".pgRR") %>%
    html_nodes("a") %>%
    html_attr("href")
  
  # 숫자 부분만을 추출
  navi.final = strsplit(navi.final, "=") %>%
    unlist() %>%
    tail(1) %>%
    as.numeric()
  
  # 네비게이션 항목까지 url 생성 후 데이터 다운로드
  for (j in 1:navi.final) {
    
    url = paste0("https://finance.naver.com/sise/sise_market_sum.nhn?sosok=",i,"&page=",j)
    down_table = GET(url)
    
    Sys.setlocale("LC_ALL", "English")
    
    table = read_html(down_table, encoding = "EUC-KR") %>% html_table(fill = TRUE) %>%
      .[[2]]
    
    Sys.setlocale("LC_ALL", "Korean")
    
    table[, ncol(table)] = NULL
    table = na.omit(table)
    
    symbol = read_html(down_table, encoding = "EUC-KR") %>%
      html_nodes("tbody") %>%
      html_nodes("td") %>%
      html_nodes("a") %>%
      html_attr("href")
    
    # url 이용하여 마지막 6자리의 종목코드 추출
    symbol = sapply(symbol, function(x) {
      strsplit(x, "=") %>%
        unlist() %>%
        tail(1)
      }) %>% unique()
    
    table$N = symbol
    colnames(table)[1] = "종목코드"
    
    rownames(table) = NULL
    ticker[[j]] = table

    Sys.sleep(0.5)
  }
  
  ticker = do.call(rbind, ticker)
  ticker$market = mkt
  
  # 1번째 리스트에는 코스피, 2번째 리스트에는 코스닥 입력
  data[[i + 1]] = ticker

}

data = do.call(rbind, data)

# data[data$액면가 == '0', '종목명'] %>% head(10)
# data[data$액면가 == '0', '종목명'] %>% tail(10)
# 액면가가 0인 종목은 ETF, ETN, 해외주식 등이므로 유니버스에서 삭제

data = data[data$액면가 != "0", ]
write.csv(data, 'KOR_ticker_naver.csv')

