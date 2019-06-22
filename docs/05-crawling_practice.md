# 금융 데이터 수집하기 (기본)

API와 크롤링을 이용한다면 비용을 지불하지 않고 얼마든지 금융 데이터를 수집할 수 있습니다. 본 장에서는 금융 데이터를 받기 위해 필요한 주식티커를 구하는 법, 그리고 섹터별 구성종목을 크롤링하는 법에 대해 알아보도록 하겠습니다. 

## 한국거래소의 산업별 현황 및 개별지표 크롤링

앞 장의 예제를 통해 [네이버 금융에서 주식티커 크롤링]을 하는 방법에 대해 살펴보았습니다. 그러나 해당 방법은 지나치게 복잡하기도 하며 시간이 오래 걸리기도 합니다. 반면 한국거래소에서 제공하는 산업별 현황과 개별종목 지표 데이터를 이용할 경우 훨씬 간단하게 해당 데이터를 수집할 수 있습니다.

- 산업별 현황: http://marketdata.krx.co.kr/mdi#document=03030103
- 개별지표: http://marketdata.krx.co.kr/mdi#document=13020401

물론 해당 데이터들을 크롤링이 아닌  Excel 버튼을 눌러 엑셀로 받을수도 있습니다. 그러나 매번 엑셀을 다운받고 이를 R로 불러오는 작업은 상당히 비효율적이며, 크롤링을 이용한다면 해당 데이터를 효율적으로 불러올 수 있습니다.

### 산업별 현황 크롤링

먼저 산업별 현황에 해당하는 페이지에 접속한 후, 개발자도구 화면을 연 상태에서 Excel 버튼을 눌러줍니다. Network 탭에는 **GenerateOTP.jspx**와 **download.jspx** 총 두가지 항목이 존재합니다. 거래소에서 엑셀 데이터를 받는 과정은 다음과 같습니다.

1. **GenerateOTP.jspx**: **http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx**에 원하는 항목을 쿼리로 발송하면 해당 쿼리에 해당하는 OTP를 받게 됩니다.

2. **download.jspx**: 부여받은 OTP를 **http://file.krx.co.kr/download.jspx**에 제출하면 이에 해당하는 데이터를 다운로드 받게 됩니다.

먼저 1번 단계를 살펴보도록 하겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_krx_sector.png" alt="OTP 생성 부분" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-1)OTP 생성 부분</p>
</div>

General 항목의 Request URL의 앞부분이 원하는 항목을 제출할 주소이며, Query String Parameters에는 우리가 원하는 항목들이 적혀있습니다. 이를 통해 POST 방식으로 데이터를 요청함을 알 수 있습니다.

다음으로 2번 단계를 살펴보도록 하겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_krx_sector2.png" alt="OTP 제출 부분" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-2)OTP 제출 부분</p>
</div>

General 항목의 Request URL은 OTP를 제출할 주소이며, Form Data의 OTP는 1번 단계에서 부여받은 OTP에 해당합니다. 이 역시 POST 방식으로 데이터를 요청합니다. 

이러한 과정을 코드로 나타내면 다음과 같습니다.


```r
library(httr)
library(rvest)
library(readr)

gen_otp_url = 'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(name = 'fileDown',
                    filetype = 'csv',
                    url = 'MKD/03/0303/03030103/mkd03030103',
                    tp_cd = 'ALL',
                    date = '20190607',
                    lang = 'ko',
                    pagePath = '/contents/MKD/03/0303/03030103/MKD03030103.jsp')
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()
```

1. gen_otp_url에 원하는 항목을 제출할 url을 입력합니다.
2. 개발자도구 화면에 나타는 쿼리 내용들을 리스트 형태로 입력합니다. 단, filetype은 기존 xls이 아닌 csv로 변경하여 주며, 이는 csv 형태로 다운로드 받을 경우 데이터를 처리하기 훨씬 쉽기 때문입니다.
3. `POST()` 함수를 통해 해당 url에 쿼리를 전송하면 이에 해당하는 데이터를 받게 됩니다.
4. `read_html()`함수를 통해 html 내용을 읽어옵니다.
5. `html_text()` 함수는 html 내에서 텍스트에 해당하는 부분만을 추출하며, 이를 통해 otp 값만을 추출하게 됩니다. 

위의 과정을 거쳐 생성된 OTP는 다음과 같습니다.


```r
print(otp)
```

```
## [1] "onU/FrwFkurWr1qEGgPEhuY5ywZspM2189tQ6/K5IMpMX5BhIp7sITzoTi0fBalnOvK4Jy0JYLWxgn54oHhXAiH+Sc8jPwfLWDSyVkVMw1eWMzaCW6h9lDIWul8jNxMBjd2ZkA1EbQt6+iaiVpS7/7nFokJIbEYYVqiHoUGSyGTVgXRWJvUme94DvkDTB7Lmr6E8QjZmwimbq8T6CMSyPhu35T4xt/OilNqkeSo4Qm/OaowGZXkX21PxVKkDrbvAFWCD/WA4Qh72wK4C/DiiuqF17/PqjS/PjNRF4nEyaKo="
```

이제 생성된 OTP를 제출하면, 우리가 원하는 데이터를 다운로드 받을 수 있습니다.


```r
down_url = 'http://file.krx.co.kr/download.jspx'
down_sector = POST(down_url, query = list(code = otp),
            add_headers(referer = gen_otp_url)) %>%
  read_html() %>%
  html_text() %>%
  read_csv()
```

1. OTP를 제출할 url을 down_url에 입력합니다.
2. `POST()` 함수를 통해 해당 url에 위에서 부여받은 OTP 코드를 제출합니다. 
3. `add_headers()` 구문을 통해 referer를 추가해 주어야 합니다. 리퍼러란 링크를 통해서 각각의 사이트로 방문시 남는 흔적입니다. 데이터를 다운로드 받는 과정을 살펴보면 첫번째 url에서 OTP를 부여 받고, 이를 다시 두번째 url에 제출하였습니다. 그런데 이러한 과정의 흔적이 없이 OTP를 바로 두번째 url에 제출하면 서버는 이를 로봇으로 인식하여 데이터를 반환하지 않습니다. 따라서 add_headers()를 통해 우리가 거쳐온 과정을 흔적으로 남겨야 사람이 데이터를 다운로드 받는 과정과 동일하게 인식하여 데이터를 반환하게 되며, 첫번째 url을 리퍼러로 지정해 줍니다.
4. `read_html()`과 `html_text()` 함수를 통해 텍스트 데이터만 추출합니다.
5. `read_csv` 함수는 csv 형태의 데이터를 불러옵니다. 위의 요청 쿼리에서 filetype을 csv로 지정했기에, 손쉽게 데이터를 읽어올 수 있습니다.


```r
print(down_sector)
```

```
## # A tibble: 2,243 x 7
##    시장구분 종목코드 종목명 산업분류 `현재가(종가)` 전일대비 `시가총액(원)`
##    <chr>    <chr>    <chr>  <chr>             <dbl>    <dbl>          <dbl>
##  1 코스피   030720   동원수산~ 어업               8940      -20    41605016700
##  2 코스피   007160   사조산업~ 어업              54400      800   272000000000
##  3 코스피   006040   동원산업~ 어업             246500      500   829028800000
##  4 코스피   004970   신라교역~ 어업              14350      350   229600000000
##  5 코스피   012320   경동인베스~ 광업              40300     1350    95310426900
##  6 코스피   003580   넥스트사이~ 광업               5200      260   122099322800
##  7 코스피   017810   풀무원 음식료품          11300      200   430427735000
##  8 코스피   280360   롯데제과~ 음식료품         159500     -500  1023466361500
##  9 코스피   271560   오리온 음식료품          83300     1400  3293359795600
## 10 코스피   006090   사조오양~ 음식료품           8220       30    77454914580
## # ... with 2,233 more rows
```

위 과정을 통해 down_sector 변수에는 산업별 현황 데이터가 저장되었습니다. 이를 csv 파일로 다운로드 받도록 하겠습니다.


```r
ifelse(dir.exists('data'), FALSE, dir.create('data'))
```

```
## [1] FALSE
```

```r
write.csv(down_sector, 'data/KOR_sector.csv')
```

먼저 `ifelse()` 함수를 통해 data라는 이름의 폴더가 존재할 시에는 FALSE를 반환, 존재하지 않을 시 해당 이름으로 폴더를 생성하여 줍니다. 그 후, 위에서 다운로드 받은 데이터를 'KOR_sector.csv' 이름으로 저장하여 줍니다. 해당 폴더를 확인해보면, 데이터가 csv 형태로 저장되어 있음이 확인할 수 있습니다.

### 개별종목 지표 크롤링

개별종목 데이터를 크롤링 하는 방법은 위와 거의 동일하며, 요청하는 쿼리 값에만 차이가 있습니다. 위와 동일하게  개발자도구 화면을 연 상태에서 csv 버튼을 눌러주어 어떠한 쿼리를 요청하는지 확인하도록 합니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_krx_ind.png" alt="개별지표 OTP 생성 부분" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-8)개별지표 OTP 생성 부분</p>
</div>

이 중 isu_cdnm, isu_cd, isu_nm, isu_srt_cd, fromdate 항목은 종목구분의 개별탭에 해당하는 부분이므로 우리가 원하는 전체 데이터를 받을때에는 필요하지 않은 요청값입니다. 이를 제외한 요청값을 산업별 현황 예제에 적용하면 해당 데이터 역시 손쉽게 다운로드 받을 수 있습니다.


```r
library(httr)
library(rvest)
library(readr)

gen_otp_url = 'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(name = 'fileDown',
                    filetype = 'csv',
                    url = "MKD/13/1302/13020401/mkd13020401",
                    market_gubun = 'ALL',
                    gubun = '1',
                    schdate = '20190607',
                    pagePath = "/contents/MKD/13/1302/13020401/MKD13020401.jsp")

otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

down_url = 'http://file.krx.co.kr/download.jspx'
down_ind = POST(down_url, query = list(code = otp),
            add_headers(referer = gen_otp_url)) %>%
  read_html() %>%
  html_text() %>%
  read_csv()
```


```r
print(down_ind)
```

```
## # A tibble: 2,204 x 13
##    일자       종목코드 종목명 관리여부  종가 EPS   PER   BPS   PBR  
##    <date>     <chr>    <chr>  <chr>    <dbl> <chr> <chr> <chr> <chr>
##  1 2019-06-07 060300   레드로버~ -         1190 -     -     2,128 0.56 
##  2 2019-06-07 290650   엘앤씨바이~ -        22750 830   27.41 7,252 3.14 
##  3 2019-06-07 239340   미래에셋제~ -         5200 -     -     -     -    
##  4 2019-06-07 033430   디에스티~ -         1310 -     -     338   3.88 
##  5 2019-06-07 192390   윈하이텍~ -         4590 669   6.86  5,803 0.79 
##  6 2019-06-07 038680   에스넷 -         9600 300   32    4,302 2.23 
##  7 2019-06-07 214680   디알텍 -         2005 29    69.14 709   2.83 
##  8 2019-06-07 242040   나무기술~ -         3345 -     -     462   7.24 
##  9 2019-06-07 121890   에스디시스~ -         4980 -     -     1,912 2.6  
## 10 2019-06-07 088800   에이스테크~ -        11500 97    118.~ 2,291 5.02 
## # ... with 2,194 more rows, and 4 more variables: 주당배당금 <dbl>,
## #   배당수익률 <dbl>, `게시물 일련번호` <dbl>, 총카운트 <dbl>
```

위 과정을 통해 down_ind 변수에는 개별종목 지표 데이터가 저장되었습니다. 해당 데이터 역시 csv 파일로 다운로드 받도록 하겠습니다.


```r
write.csv(down_ind, 'data/KOR_ind.csv')
```

위 예제의 쿼리 항목 중 date와 schdate 부분만 원하는 일자로 입력할 경우(예: 20190104), 해당일의 데이터를 다운로드 받을 수 있습니다. 단, 휴장일을 입력할 경우 데이터를 받을 수 없습니다.

### 데이터 정리하기

위에서 다운받은 데이터는 중복된 열이 있으며, 불필요한 데이터 역시 존재합니다. 따라서 하나의 테이블로 합쳐준 후 정리를 할 필요가 있습니다. 먼저 다운로드 받은 csv 파일을 읽어오도록 합니다.


```r
down_sector = read.csv('data/KOR_sector.csv', row.names = 1, stringsAsFactors = FALSE)
down_ind = read.csv('data/KOR_ind.csv',  row.names = 1, stringsAsFactors = FALSE)
```

`read.csv()` 함수를 이용하여 데이터를 읽어오며, `row.names = 1`를 통해 첫번째 열을 행이름으로, `stringsAsFactors = FALSE`를 통해 캐릭터 데이터가 팩터 형태로 변형되지 않게 합니다.


```r
intersect(names(down_sector), names(down_ind))
```

```
## [1] "종목코드" "종목명"
```

먼저 `intersect()` 함수를 통해 두 데이터간 중복되는 열이름을 상펴보면, 종목코드와 종목명이 동일하게 위치합니다.


```r
setdiff(down_sector[, '종목명'], down_ind[ ,'종목명'])
```

```
##  [1] "엘브이엠씨홀딩스"   "한국패러랠"         "한국ANKOR유전"     
##  [4] "맵스리얼티1"        "맥쿼리인프라"       "하나니켈2호"       
##  [7] "하나니켈1호"        "베트남개발1"        "신한알파리츠"      
## [10] "이리츠코크렙"       "모두투어리츠"       "하이골드12호"      
## [13] "하이골드8호"        "바다로19호"         "하이골드3호"       
## [16] "케이탑리츠"         "에이리츠"           "동북아13호"        
## [19] "동북아12호"         "컬러레이"           "JTC"               
## [22] "뉴프라이드"         "윙입푸드"           "글로벌에스엠"      
## [25] "크리스탈신소재"     "씨케이에이치"       "차이나그레이트"    
## [28] "골든센츄리"         "오가닉티코스메틱"   "GRT"               
## [31] "로스웰"             "헝셩그룹"           "이스트아시아홀딩스"
## [34] "에스앤씨엔진그룹"   "SNK"                "SBI핀테크솔루션즈" 
## [37] "잉글우드랩"         "코오롱티슈진"       "엑세스바이오"
```

`setdiff()` 함수를 통해 두 데이터에 공통적으로 존재하지 않는 종목명, 즉 하나의 데이터에만 존재하는 종목을 살펴보면 위와 같습니다. 해당 종목들은 **선박펀드, 광물펀드, 해외종목** 등 일반적이지 않은 종목들이므로, 제외해주는 것이 좋습니다. 따라서 둘간에 공통적으로 존재하는 종목을 기준으로 데이터를 합쳐주도록 하겠습니다.


```r
KOR_ticker = merge(down_sector, down_ind,
                   by = intersect(names(down_sector), names(down_ind)),
                   all = FALSE
    )
```

```merge()``` 함수는 by를 기준으로 하여 두 데이터를 하나로 합치게 되며, 그 기준은 공통으로 존재하는 열이름으로 합니다. 또한 all 값을 TRUE로 설정할 경우는 합집합을, FALSE로 설정할 경우 교집합을 반환하며, 공통적으로 존재하는 항목을 원하므로 FALSE를 선택해 주도록 합니다.


```r
KOR_ticker = KOR_ticker[order(-KOR_ticker['시가총액.원.']), ]
print(head(KOR_ticker))
```

```
##      종목코드     종목명 시장구분 산업분류 현재가.종가. 전일대비
## 330    005930   삼성전자   코스피 전기전자        44200      300
## 45     000660 SK하이닉스   코스피 전기전자        65400      300
## 301    005380     현대차   코스피 운수장비       140000    -1000
## 331    005935 삼성전자우   코스피 전기전자        36250      200
## 1278   068270   셀트리온   코스피   의약품       196500      500
## 1082   051910     LG화학   코스피     화학       330500    -1000
##      시가총액.원.       일자 관리여부   종가    EPS   PER     BPS  PBR
## 330  2.638644e+14 2019-06-07        -  44200  6,461  6.84  35,342 1.25
## 45   4.761135e+13 2019-06-07        -  65400 22,255  2.94  64,348 1.02
## 301  2.991355e+13 2019-06-07        - 140000  5,632 24.86 245,447 0.57
## 331  2.982964e+13 2019-06-07        -  36250      -     -       -    -
## 1278 2.521666e+13 2019-06-07        - 196500  2,063 95.25  19,766 9.94
## 1082 2.333077e+13 2019-06-07        - 330500 19,217  17.2 218,227 1.51
##      주당배당금 배당수익률 게시물..일련번호 총카운트
## 330        1416       3.20             1456       NA
## 45         1500       2.29             1408       NA
## 301        4000       2.86             1450       NA
## 331        1417       3.91             2095       NA
## 1278          0       0.00             1595       NA
## 1082       6000       1.82             1536       NA
```

데이터를 시가총액 순으로 내림차순 해줄 필요도 있습니다. `order()` 함수를 통해 상대적인 순서를 구할 수 있으며, R은 기본적으로 오름차순으로 순서를 구하므로 앞에 마이너스(-)를 붙여 내림차순 형태로 바꾸어 주도록 합니다. 결과적으로 시가총액 기준 내림차순으로 해당 데이터가 정렬됩니다.

마지막으로 **스팩, 우선주** 종목 역시 제외해 주어야 합니다.


```r
KOR_ticker[grepl('스팩', KOR_ticker[, '종목명']), '종목명']  # 스팩
```

```
##  [1] "미래에셋제5호스팩"   "한화에스비아이스팩"  "엔에이치스팩14호"   
##  [4] "엔에이치스팩10호"    "엔에이치스팩12호"    "삼성스팩2호"        
##  [7] "대신밸런스제5호스팩" "케이비제10호스팩"    "엔에이치스팩11호"   
## [10] "유진스팩4호"         "신한제4호스팩"       "하나금융11호스팩"   
## [13] "케이비17호스팩"      "DB금융스팩7호"       "SK4호스팩"          
## [16] "한국제7호스팩"       "대신밸런스제6호스팩" "미래에셋대우스팩1호"
## [19] "대신밸런스제4호스팩" "IBKS제5호스팩"       "동부스팩5호"        
## [22] "DB금융스팩6호"       "하나머스트제6호스팩" "하나금융10호스팩"   
## [25] "삼성머스트스팩3호"   "유안타제4호스팩"     "한국제6호스팩"      
## [28] "IBKS제6호스팩"       "신영스팩4호"         "한화수성스팩"       
## [31] "IBKS제10호스팩"      "하이제4호스팩"       "하나금융9호스팩"    
## [34] "유안타제3호스팩"     "교보7호스팩"         "한국제5호스팩"      
## [37] "IBKS제9호스팩"       "교보8호스팩"         "IBKS제7호스팩"      
## [40] "신한제3호스팩"       "키움제5호스팩"       "SK3호스팩"          
## [43] "한국제8호스팩"       "한화에이스스팩4호"   "엔에이치스팩13호"   
## [46] "미래에셋대우스팩2호" "한화에이스스팩3호"   "케이비제11호스팩"
```

```r
KOR_ticker[KOR_ticker[, '종목명'] == '골든브릿지이안5호', '종목명'] # 골든브릿지이안5호
```

```
## [1] "골든브릿지이안5호"
```

```r
KOR_ticker[substr(KOR_ticker[, '종목명'],
                  nchar(KOR_ticker[,'종목명']), nchar(KOR_ticker[,'종목명'])) == '우', '종목명']
```

```
##  [1] "삼성전자우"         "미래에셋대우"       "현대차우"          
##  [4] "LG생활건강우"       "LG화학우"           "아모레퍼시픽우"    
##  [7] "삼성화재우"         "LG전자우"           "신영증권우"        
## [10] "연우"               "두산우"             "한국금융지주우"    
## [13] "대신증권우"         "S-Oil우"            "대림산업우"        
## [16] "NH투자증권우"       "아모레G우"          "CJ제일제당 우"     
## [19] "LG우"               "SK이노베이션우"     "삼성SDI우"         
## [22] "삼성전기우"         "CJ우"               "금호석유우"        
## [25] "SK우"               "GS우"               "미래에셋대우우"    
## [28] "롯데칠성우"         "부국증권우"         "코오롱인더우"      
## [31] "롯데지주우"         "유한양행우"         "유화증권우"        
## [34] "호텔신라우"         "SK케미칼우"         "남양유업우"        
## [37] "한진칼우"           "LG하우시스우"       "BYC우"             
## [40] "유안타증권우"       "대한항공우"         "세방우"            
## [43] "SK디스커버리우"     "대덕전자1우"        "태영건설우"        
## [46] "대상우"             "금호산업우"         "한화우"            
## [49] "현대건설우"         "한화케미칼우"       "삼양홀딩스우"      
## [52] "녹십자홀딩스2우"    "신풍제약우"         "삼양사우"          
## [55] "넥센우"             "SK증권우"           "남선알미우"        
## [58] "코오롱우"           "계양전기우"         "NPC우"             
## [61] "한화투자증권우"     "SK네트웍스우"       "태양금속우"        
## [64] "쌍용양회우"         "서울식품우"         "성문전자우"        
## [67] "대원전선우"         "일양약품우"         "성신양회우"        
## [70] "대한제당우"         "유유제약1우"        "코리아써우"        
## [73] "크라운해태홀딩스우" "동원시스템즈우"     "CJ씨푸드1우"       
## [76] "현대비앤지스틸우"   "삼성중공우"         "금강공업우"        
## [79] "대호피앤씨우"       "크라운제과우"       "동부제철우"        
## [82] "깨끗한나라우"       "노루페인트우"       "대상홀딩스우"      
## [85] "덕성우"             "코오롱글로벌우"     "동양우"            
## [88] "신원우"             "DB하이텍1우"        "하이트진로홀딩스우"
## [91] "흥국화재우"         "JW중외제약우"       "한양증권우"        
## [94] "동부건설우"         "노루홀딩스우"       "소프트센우"
```

```r
KOR_ticker[substr(KOR_ticker[, '종목명'],
                  nchar(KOR_ticker[,'종목명']) -1, nchar(KOR_ticker[,'종목명'])) == '우B', '종목명'] 
```

```
##  [1] "현대차2우B"       "미래에셋대우2우B" "한화3우B"        
##  [4] "현대차3우B"       "삼성물산우B"      "대교우B"         
##  [7] "대신증권2우B"     "두산2우B"         "넥센타이어1우B"  
## [10] "하이트진로2우B"   "진흥기업2우B"     "진흥기업우B"     
## [13] "JW중외제약2우B"   "흥국화재2우B"     "코리아써키트2우B"
## [16] "유유제약2우B"     "동양2우B"         "대한제당3우B"    
## [19] "동양3우B"
```

```r
KOR_ticker[substr(KOR_ticker[, '종목명'],
                  nchar(KOR_ticker[,'종목명']) -1, nchar(KOR_ticker[,'종목명'])) == '우C', '종목명'] 
```

```
## [1] "루트로닉3우C"
```

`grepl()` 함수를 통해 종목명에 '스팩'이 들어가는 종목, 스팩 종목인 '골든브릿지이안5호', `substr()` 함수를 통해 종목명 끝이 '우', '우B', '우C'인 우선주 종목을 찾을 수 있습니다. 데이터 내에서 해당 데이터들을 제거^[해당 과정에서 미래에셋대우, 연우 등 의도치 않은 종목 역시 제거됩니다. 그러나 이러한 종목수가 그리 많지 않으므로 투자에 있어 중요하지는 않습니다.]해 주도록 하겠습니다.


```r
KOR_ticker = KOR_ticker[!grepl('스팩', KOR_ticker[, '종목명']), ]  # 스팩
KOR_ticker = KOR_ticker[KOR_ticker[, '종목명'] != '골든브릿지이안5호', ] # 골든브릿지이안5호
KOR_ticker = KOR_ticker[substr(KOR_ticker[, '종목명'],
                               nchar(KOR_ticker[,'종목명']), nchar(KOR_ticker[,'종목명'])) != '우', ]
KOR_ticker = KOR_ticker[substr(KOR_ticker[, '종목명'],
                               nchar(KOR_ticker[,'종목명']) -1, nchar(KOR_ticker[,'종목명'])) != '우B', ] 
KOR_ticker = KOR_ticker[substr(KOR_ticker[, '종목명'],
                               nchar(KOR_ticker[,'종목명']) -1, nchar(KOR_ticker[,'종목명'])) != '우C', ] 
```

마지막으로 행이름을 초기화 한 후, 정리된 데이터를 csv 파일로 저장해주도록 합니다.


```r
rownames(KOR_ticker) = NULL
write.csv(KOR_ticker, 'data/KOR_ticker.csv')
```
## WICS 기준 섹터정보 크롤링

일반적으로 주식의 섹터를 나누는 기준은 MSCI와 S&P가 개발한 GICS^[https://en.wikipedia.org/wiki/Global_Industry_Classification_Standard]를 가장 많이 사용합니다. 국내 종목의 GICS 기준 정보 역시 한국거래소에서 제공하고 있으나, 이는 독점적 지적재산으로 명시했기에 사용하는데 무리가 있습니다.

그러나 지수제공업체인 와이즈인덱스^[http://www.wiseindex.com/]에서는 GICS와 비슷한 WICS 산업분류를 발표하고  있으므로, 이를 크롤링하여 필요한 정보를 수집해보도록 하겠습니다.

먼저, 웹페이지에 접속하여 **Index → WISE SECTOR INDEX → WICS → 에너지**를 클릭합니다. 그 후 Components 탭을 클릭하면, 해당 섹터의 구성종목을 확인할 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_wics.png" alt="WICS 기준 구성종목" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-20)WICS 기준 구성종목</p>
</div>

개발자도구 화면을 통해 해당 페이지의 데이터전송 과정을 살펴보도록 하겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_wics2.png" alt="WICS 페이지 개발자도구 화면" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-21)WICS 페이지 개발자도구 화면</p>
</div>

일자를 선택하면 Network 탭의 **GetIndexComponets** 항목을 통해 데이터 전송과정이 나타나며, Request URL의 주소를 살펴보면 다음과 같습니다.

```
http://www.wiseindex.com/Index/GetIndexComponets?ceil_yn=0&dt=20190607&sec_cd=G10
```

1. http://www.wiseindex.com/Index/GetIndexComponets: 데이터를 요청하는 url 입니다.
2. ceil_yn = 0: 실링여부를 나타내며, 0일 경우 비실링을 의미합니다.
3. dt=20190607: 조회일자를 나타냅니다.
4. sec_cd=G10: 섹터 코드를 나타냅니다.

이번엔 위 주소의 페이지를 열어보도록 하겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_wics3.png" alt="WICS 데이터 페이지" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-22)WICS 데이터 페이지</p>
</div>

글자들을 살펴보면 페이지에 출력된 내용임을 알 수 있지만, 매우 특이한 형태로 구성되어 있습니다. 이러한 형식이 데이터를 json 형식이라 합니다. 기존에 우리가 살펴보았던 대부분의 웹페이지는 XML 형식으로 표현되었으며, 이는 문법이 복잡하고 엄격한 표현규칙으로 인해 데이터의 용량이 커진다는 단점이 있습니다. 반면 JSON 형식은 문법이 단순하여 데이터의 용량이 작아, 빠른 속도로 데이터를 교환할 수 있습니다. R에서는 `jsonlite` 패키지의 `fromJSON()` 함수를 사용하여 매우 손쉽게 해당 형태의 데이터를 크롤링할 수 있습니다.


```r
library(jsonlite)

url = 'http://www.wiseindex.com/Index/GetIndexComponets?ceil_yn=0&dt=20190607&sec_cd=G10'
data = fromJSON(url)
print(data)
```

```
## $info
## $info$TRD_DT
## [1] "/Date(1559833200000)/"
## 
## $info$MKT_VAL
## [1] 19850082
## 
## $info$TRD_AMT
## [1] 70030
## 
## $info$CNT
## [1] 23
## 
## 
## $list
##    IDX_CD  IDX_NM_KOR ALL_MKT_VAL CMP_CD            CMP_KOR MKT_VAL   WGT
## 1     G10 WICS 에너지    19850082 096770       SK이노베이션 9052841 45.61
## 2     G10 WICS 에너지    19850082 010950              S-Oil 3403265 17.14
## 3     G10 WICS 에너지    19850082 267250     현대중공업지주 2873204 14.47
## 4     G10 WICS 에너지    19850082 078930                 GS 2491805 12.55
## 5     G10 WICS 에너지    19850082 067630 에이치엘비생명과학  624986  3.15
## 6     G10 WICS 에너지    19850082 006120       SK디스커버리  257059  1.30
## 7     G10 WICS 에너지    19850082 002960         한국쉘석유  198881  1.00
## 8     G10 WICS 에너지    19850082 091090         세원셀론텍  146439  0.74
## 9     G10 WICS 에너지    19850082 011930         신성이엔지  118388  0.60
## 10    G10 WICS 에너지    19850082 128820           대성산업   79162  0.40
## 11    G10 WICS 에너지    19850082 043200               파루   75903  0.38
## 12    G10 WICS 에너지    19850082 003650           미창석유   71918  0.36
## 13    G10 WICS 에너지    19850082 014530           극동유화   62828  0.32
## 14    G10 WICS 에너지    19850082 099220                SDN   55967  0.28
## 15    G10 WICS 에너지    19850082 024060           흥구석유   53460  0.27
## 16    G10 WICS 에너지    19850082 041590           에너전트   50901  0.26
## 17    G10 WICS 에너지    19850082 095910         에스에너지   46873  0.24
## 18    G10 WICS 에너지    19850082 060900       퍼시픽바이오   43739  0.22
## 19    G10 WICS 에너지    19850082 012320       경동인베스트   40030  0.20
## 20    G10 WICS 에너지    19850082 093230           이아이디   32266  0.16
## 21    G10 WICS 에너지    19850082 038620           위즈코프   30094  0.15
## 22    G10 WICS 에너지    19850082 137950       제이씨케미칼   29363  0.15
## 23    G10 WICS 에너지    19850082 000440       중앙에너비스   10711  0.05
##     S_WGT CAL_WGT SEC_CD SEC_NM_KOR SEQ TOP60 APT_SHR_CNT
## 1   45.61       1    G10     에너지   1     2    56403994
## 2   62.75       1    G10     에너지   2     2    41655633
## 3   77.23       1    G10     에너지   3     2     9283372
## 4   89.78       1    G10     에너지   4     2    49245150
## 5   92.93       1    G10     에너지   5     2    39307272
## 6   94.22       1    G10     에너지   6     2    10470820
## 7   95.22       1    G10     에너지   7     2      611000
## 8   95.96       1    G10     에너지   8     2    42693554
## 9   96.56       1    G10     에너지   9     2   100756131
## 10  96.96       1    G10     에너지  10     2    15832417
## 11  97.34       1    G10     에너지  11     2    29707590
## 12  97.70       1    G10     에너지  12     2      922026
## 13  98.02       1    G10     에너지  13     2    18132098
## 14  98.30       1    G10     에너지  14     2    38598075
## 15  98.57       1    G10     에너지  15     2     9000000
## 16  98.83       1    G10     에너지  16     2    31132353
## 17  99.06       1    G10     에너지  17     2    10290527
## 18  99.28       1    G10     에너지  18     2    53017111
## 19  99.48       1    G10     에너지  19     2      993310
## 20  99.65       1    G10     에너지  20     2   140285009
## 21  99.80       1    G10     에너지  21     2    24075079
## 22  99.95       1    G10     에너지  22     2     8353752
## 23 100.00       1    G10     에너지  23     2     1556783
## 
## $sector
##    SEC_CD         SEC_NM_KOR SEC_RATE IDX_RATE
## 1     G25     경기관련소비재    16.05        0
## 2     G35           건강관리     9.27        0
## 3     G50 커뮤니케이션서비스     2.26        0
## 4     G40               금융    10.31        0
## 5     G10             에너지     2.37      100
## 6     G20             산업재    12.68        0
## 7     G55           유틸리티     1.70        0
## 8     G30         필수소비재     3.75        0
## 9     G15               소재     7.89        0
## 10    G45                 IT    33.73        0
## 
## $size
##   SEC_CD    SEC_NM_KOR SEC_RATE IDX_RATE
## 1 WMI510 WMI500 대형주    69.40    89.78
## 2 WMI520 WMI500 중형주    13.56     4.44
## 3 WMI530 WMI500 소형주    17.04     5.78
```

\$list 항목에는 해당 섹터의 구성종목 정보가 있으며, \$sector 항목을 통해 다른 섹터들의 코드도 확인할 수 있습니다. for loop 구문을 이용해 url의 sec_cd=에 해당하는 부분만 변경해주면, 모든 섹터의 구성종목을 매우 쉽게 얻을 수 있습니다.


```r
sector_code = c('G25', 'G35', 'G50', 'G40', 'G10', 'G20', 'G55', 'G30', 'G15', 'G45')
data_sector = list()

for (i in sector_code) {
  
  url = paste0(
    'http://www.wiseindex.com/Index/GetIndexComponets?ceil_yn=0&dt=20190607&sec_cd=',i)
  data = fromJSON(url)
  data = data$list
  
  data_sector[[i]] = data
  
  Sys.sleep(1)
}

data_sector = do.call(rbind, data_sector)
```

해당 데이터 역시 csv 파일로 저장해주도록 합니다.


```r
write.csv(data_sector, 'data/KOR_sector.csv')
```


