library(httr)
library(rvest)
library(lubridate)
library(xts)
library(tibble)

ticker = read.csv("KOR_ticker.csv", row.names = 1, stringsAsFactors = FALSE)
ticker$종목코드 = str_pad(ticker$종목코드, width = 6,
                      side = 'left', pad = 0)


# 차트: https://finance.naver.com/item/fchart.nhn?code=005930

for (i in 1:nrow(ticker)) {

  # i = 1
  name = ticker[i, '종목코드']
  price = xts(NA, order.by = Sys.Date())

  tryCatch({

    url = paste0('https://fchart.stock.naver.com/sise.nhn?symbol=',name,
                 '&timeframe=day&count=500&requestType=0')

    data = GET(url)

    # |를 기준으로 데이터를 나누어 리스트 형태로 저장
    data_table = data %>%
      read_html() %>%
      html_nodes("item") %>%
      html_attr("data") %>%
      strsplit("\\|")

    # 하나의 데이터 프레임으로 결합
    price = do.call(rbind, data_table) %>% data.frame()
    price = price[c(1,5)] # 첫번째 열은 날짜, 다섯번째 열은 종가

    price[,1] = ymd(price[,1])
    price = column_to_rownames(price, var = 'X1')

    # str(price)
    # 종가 부분이 팩터 형태로 되어있어서, 숫자 형태로 바꾸어주어야 함

    # as.numeric(price[,1])
    # as.numeric() 함수를 쓸 경우 팩터의 레이블로 숫자가 바뀌는 문제가 발생
    # as.character() 를 통해 문자열로 변경 후, as.numeric() 을 이용하여 숫자로 변경

    price[,1] = as.character(price[,1]) %>% as.numeric()
    price = as.xts(price)
    price = price[!duplicated(index(price))]

  }, error = function(e) {
    print(paste0("Error in Ticker: ", name))}
  )

  write.csv(data.frame(price), paste0(name, "_price.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(2)
}
