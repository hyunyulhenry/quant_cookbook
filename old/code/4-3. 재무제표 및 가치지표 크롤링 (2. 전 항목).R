library(httr)
library(rvest)
library(tibble)

ticker = read.csv("KOR_ticker.csv", row.names = 1, stringsAsFactors = FALSE)
ticker$종목코드 = stringr::str_pad(ticker$종목코드, width = 6,
                      side = 'left', pad = 0)

# setwd("./fs_all")

# Company Guide 재무제표 항목
# http://comp.fnguide.com/SVO2/asp/SVD_Finance.asp?pGB=1&gicode=A005930&cID=&MenuYn=Y&ReportGB=&NewMenuID=103&stkGb=701

for (i in 1:nrow(ticker)) {
  
  # i = 1
  name = ticker[i, '종목코드'] %>% as.character()
  data_fs = c()
  data_value = c()
  
  tryCatch({
    
    url = paste0('http://comp.fnguide.com/SVO2/asp/SVD_Finance.asp?pGB=1&gicode=A',name,
                 '&cID=&MenuYn=Y&ReportGB=&NewMenuID=103&stkGb=701')
    
    data = GET(url)
    
    Sys.setlocale("LC_ALL", "English")
    
    # 포괄손익계산서
    data_IS = data %>%
      read_html() %>%
      html_node(xpath = '//*[@id="divSonikY"]/table') %>%
      html_table()
    # 마지막 열 2개는 삭제
    data_IS = data_IS[, 1:(ncol(data_IS)-2)]
    
    # 재무상태표
    data_BS = data %>%
      read_html() %>%
      html_node(xpath = '//*[@id="divDaechaY"]/table') %>%
      html_table()
    
    # 현금흐름표
    data_CF = data %>%
      read_html() %>%
      html_node(xpath = '//*[@id="divCashY"]/table') %>%
      html_table()
    
    Sys.setlocale("LC_ALL", "Korean")
    
    data_fs = rbind(data_IS, data_BS, data_CF)
    
    # 홈페이지 테이블의 (+) 부분에 해당하는 텍스트 삭제 해주기
    # head(data_fs[,1])
    data_fs[,1] = gsub('계산에 참여한 계정 펼치기',
                       '', data_fs[,1])
    
    # data_fs[duplicated(data_fs[,1]), 1]
    # 일부 계정명은 중복으로 들어가 있음
    # 대부분 중요하지 않은 항목이므로 중복 데이터를 삭제
    data_fs = data_fs[!duplicated(data_fs[,1]), ]
    rownames(data_fs) = NULL
    data_fs = column_to_rownames(data_fs, var = 'IFRS(연결)')
    
    # 연말(12월) 데이터만 뽑기
    data_fs = data_fs[, substr(colnames(data_fs), 6,7) == "12"]
    
    # ',' 부분을 모두 숫자로 변경
    for (j in 1 : ncol(data_fs)) {
      data_fs[,j] = readr::parse_number(data_fs[,j])
    }
    
    value.type = c("지배주주순이익", # Earnings
                   "자본", # Book Value
                   "영업활동으로인한현금흐름", # Operating Cash Flow
                   "매출액")
    
    # 가치지표에 해당하는 데이터의 최근연도 데이터만 선택
    # match(value.type, rownames(data_fs))
    value_index = data_fs[match(value.type, rownames(data_fs)), ncol(data_fs)]
    
    # 메인 페이지 크롤링
    main_url = paste0('http://comp.fnguide.com/SVO2/asp/SVD_Main.asp?pGB=1&gicode=A',
                      name,'&cID=&MenuYn=Y&ReportGB=&NewMenuID=101&stkGb=701')
    main_data = GET(main_url)
    
    # 가격 데이터 추출하기
    price = main_data %>%
      read_html() %>%
      html_node(xpath = '//*[@id="svdMainChartTxt11"]') %>%
      html_text() %>%
      readr::parse_number()
    
    # 발행주식수 (보통주) 추출하기
    share = main_data %>%
      read_html() %>%
      html_node(xpath = '//*[@id="svdMainGrid1"]/table/tbody/tr[7]/td[1]') %>%
      html_text() %>%
      strsplit('/') %>%
      unlist() %>%
      .[1] %>%
      readr::parse_number()
    
    # 재무제표 값이 '억' 단위 이므로, 단위를 통일함
    data_value = price / (value_index * 100000000/ share)
    names(data_value) = c('PER', 'PBR', 'PCR', 'PSR')
    
    # 이상치 데이터 보정
    data_value[is.infinite(data_value)] = NA
    data_value[data_value < 0] = NA
    
  }, error = function(e) {
    data_fs <<- NA
    data_value <<- NA
    print(paste0("Error in Ticker: ", name))}
  )
  
  write.csv(data_fs, paste0(name, "_fs.csv"))
  write.csv(data_value, paste0(name, "_value.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(3)
  
}
