# KIND 오늘의공시
# http://kind.krx.co.kr/disclosure/todaydisclosure.do?method=searchTodayDisclosureMain

library(httr)
library(rvest)
library(readxl)

url = 'http://kind.krx.co.kr/disclosure/todaydisclosure.do'
down = POST(url, query = list(
  method = 'searchTodayDisclosureSub',
  currentPageSize = '3000',
  pageIndex = '1',
  orderMode = '0',
  orderStat = 'D',
  forward = 'todaydisclosure_down',
  chose = 'S',
  todayFlag = 'Y',
  selDate = '2019-03-27'
))

down
writeBin()

down_html = read_html(content(down, as = "text"))

down_table = html_nodes(down_html, "table") %>% 
  html_table(fill=TRUE) %>%
  .[[1]]
Sys.setlocale("LC_ALL", "Korean")
