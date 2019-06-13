library(httr)
library(rvest)
library(tibble)

ticker = read.csv("KOR_ticker.csv", row.names = 1, stringsAsFactors = FALSE)
ticker$종목코드 = stringr::str_pad(ticker$종목코드, width = 6,
                      side = 'left', pad = 0)

# Company Guide
# http://comp.fnguide.com/SVO2/asp/SVD_Main.asp?pGB=1&gicode=A005930&cID=&MenuYn=Y&ReportGB=&NewMenuID=101&stkGb=701

for (i in 1:nrow(ticker)) {
  
  # i = 1
  name = ticker[i, '종목코드']
  data_fs = c()
  
  tryCatch({
    
    url = paste0('http://comp.fnguide.com/SVO2/asp/SVD_Main.asp?pGB=1&gicode=A',
                 name,'&cID=&MenuYn=Y&ReportGB=&NewMenuID=101&stkGb=701')
    
    data = GET(url) 
    
    # 하단 Financial Highlight의 연간에 해당하는 부분 Xpath 추출
    data_fs = read_html(data) %>%
      html_node(xpath = '//*[@id="highlight_D_Y"]/table') %>%
      html_table(fill = TRUE) 
    
    # 첫번째 행에 'E'가 들어간 열은 삭제
    data_fs = data_fs[, !grepl('E', data_fs[1, ])]
    
    # 첫번째 열은 행이름으로, 첫번째 행은 열이름으로 변경
    data_fs = column_to_rownames(data_fs, var = 'IFRS(연결)')
    
    colnames(data_fs) = data_fs[1, ]
    data_fs = data_fs[-1, ]
    
    # ',' 부분을 모두 숫자로 변경
    for (j in 1 : ncol(data_fs)) {
      data_fs[,j] = readr::parse_number(data_fs[,j])
    }
    
  }, error = function(e) {
    data_fs <<- NA
    print(paste0("Error in Ticker: ", name))}
  )
  
  write.csv(data_fs, paste0(name, "_fs_simple.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(2)
}