# https://mrchypark.github.io/kisa_finR/#(7)

library(rvest)
library(httr)

# 1. Yes24 R 프로그래밍 순위 데이터
url = "http://www.yes24.com/searchcorner/Search?keywordAd=&keyword=&domain=ALL&qdomain=%C0%FC%EC%B2%3F&query=R+%C7%C1%B7%CE%B1%D7%B7%A1%B9%D6"
data = GET(url)

x = read_html(data)
html_node(x, ".goodsList.goodsList_list") %>%
  html_nodes(".goods_infogrp") %>%
  html_nodes(".goods_name.goods_icon") %>%
  html_nodes("a") %>%
  html_text()

# 2. 상장종목현황
url = "http://kind.krx.co.kr/corpgeneral/listedIssueStatus.do?method=loadInitPage"
data = POST(url, 
            query=list(
              method = 'readListedIssueStatus',
              selDate = '2017-12-28')
)

data_table = read_html(data) %>% 
  html_table()

             



