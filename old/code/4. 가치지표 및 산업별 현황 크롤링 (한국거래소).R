# 거래소 데이터 크롤링
# 개별종목 가치지표(http://marketdata.krx.co.kr/mdi#document=13020401, 30009)
# 산업별 현황(http://marketdata.krx.co.kr/mdi#document=03030103, 20005)

library(rvest)
library(httr)
library(readr)

date = '20181228'

# 개별종목 가치지표 다운로드 
# http://marketdata.krx.co.kr/mdi#document=13020401
gen_otp_data = list(name = 'fileDown', filetype = 'csv',
                    url = 'MKD/13/1302/13020401/mkd13020401', market_gubun = 'ALL',
                    gubun = '1', schdate = date,
                    pagePath = '/contents/MKD/13/1302/13020401/MKD13020401.jsp')

otp = POST('http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx',
           query = gen_otp_data) %>%
  read_html() %>% html_text()

down = POST('http://file.krx.co.kr/download.jspx', query = list(code = otp),
            add_headers(
              referer = 'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'))

# down
# down을 확인해보면 Status가 200이며, Binary Body임이 확인됨

down = read_html(down) %>% html_text() %>% read_csv()
write.csv(down, 'data_value_krx.csv')


# 산업별 현황 다운로드
# http://marketdata.krx.co.kr/mdi#document=03030103
gen_otp_data = list(name = 'fileDown', filetype = 'csv',
                    url = 'MKD/03/0303/03030103/mkd03030103', tp_cd = 'ALL',
                    date = date, lang = 'ko',
                    pagePath = '/contents/MKD/03/0303/03030103/MKD03030103.jsp')

otp = POST('http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx',
           query = gen_otp_data) %>%
  read_html() %>% html_text()

down = POST('http://file.krx.co.kr/download.jspx', query = list(code = otp),
            add_headers(
              referer = 'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'))

down = read_html(down) %>% html_text() %>% read_csv()
write.csv(down, 'data_sector_krx.csv')
