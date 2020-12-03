# 금융 데이터 수집하기 (기본)

API와 크롤링을 이용한다면 비용을 지불하지 않고 얼마든지 금융 데이터를 수집할 수있습니다. 이 CHAPTER에서는 금융 데이터를 받기 위해 필요한 주식티커를 구하는 방법과 섹터별 구성종목을 크롤링하는 방법을 알아보겠습니다.

## 한국거래소의 산업별 현황 및 개별지표 크롤링

앞 CHAPTER의 예제를 통해 네이버 금융에서 주식티커를 크롤링하는 방법을 살펴보았습니다. 그러나 이 방법은 지나치게 복잡하고 시간이 오래 걸립니다. 반면 한국거래소에서 제공하는 산업별 현황과 개별종목 지표 데이터를 이용하면 훨씬 간단하게 주식티커 데이터를 수집할 수 있습니다.

- 산업별 현황: http://marketdata.krx.co.kr/mdi#document=03030103
- 개별지표: http://marketdata.krx.co.kr/mdi#document=13020401

해당 데이터들을 크롤링이 아닌 [Excel] 버튼을 클릭해 엑셀 파일로 받을 수도 있습니다. 그러나 매번 엑셀 파일을 다운로드하고 이를 R로 불러오는 작업은 상당히 비효율적이며, 크롤링을 이용한다면 해당 데이터를 R로 직접 불러올 수 있습니다.

### 산업별 현황 크롤링

먼저 산업별 현황에 해당하는 페이지에 접속한 후 개발자 도구 화면을 열고 [Excel] 버튼을 클릭합니다. [Network] 탭에는 GenerateOTP.jspx와 download.jspx 두 가지 항목이 있습니다. 거래소에서 엑셀 데이터를 받는 과정은 다음과 같습니다.

1. http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx 에 원하는 항목을쿼리로 발송하면 해당 쿼리에 해당하는 OTP(GenerateOTP.jspx)를 받게 됩니다.

2. 부여받은 OTP를 **http://file.krx.co.kr/download.jspx**에 제출하면 이에 해당하는 데이터(download.jspx)를 다운로드하게 됩니다.

먼저 1번 단계를 살펴보겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_krx_sector.png" alt="OTP 생성 부분" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-1)OTP 생성 부분</p>
</div>

General 항목의 Request URL의 앞부분이 원하는 항목을 제출할 주소입니다. Query String Parameters에는 우리가 원하는 항목들이 적혀 있습니다. 이를 통해 POST 방식으로 데이터를 요청함을 알 수 있습니다.

다음으로 2번 단계를 살펴보겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_krx_sector2.png" alt="OTP 제출 부분" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-2)OTP 제출 부분</p>
</div>

General 항목의 Request URL은 OTP를 제출할 주소입니다. Form Data의 OTP는 1번 단계에서 부여받은 OTP에 해당합니다. 이 역시 POST 방식으로 데이터를 요청합니다.

위 과정을 코드로 나타내면 다음과 같습니다.


```r
library(httr)
library(rvest)
library(readr)

gen_otp_url =
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(
  name = 'fileDown',
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

1. gen_otp_url에 원하는 항목을 제출할 URL을 입력합니다.
2. 개발자 도구 화면에 나타는 쿼리 내용들을 리스트 형태로 입력합니다. **단, filetype은 xls이 아닌 csv로 변경하는데**, csv 형태로 다운로드하면 데이터를 처리하기 훨씬 쉽기 때문입니다.
3. `POST()` 함수를 통해 해당 URL에 쿼리를 전송하면 이에 해당하는 데이터를 받게 됩니다.
4. `read_html()`함수를 통해 HTML 내용을 읽어옵니다.
5. `html_text()` 함수는 HTML 내에서 텍스트에 해당하는 부분만을 추출합니다. 이를 통해 OTP 값만 추출하게 됩니다.

위의 과정을 거쳐 생성된 OTP를 제출하면, 우리가 원하는 데이터를 다운로드할 수 있습니다.


```r
down_url = 'http://file.krx.co.kr/download.jspx'
down_sector = POST(down_url, query = list(code = otp),
                   add_headers(referer = gen_otp_url)) %>%
  read_html() %>%
  html_text() %>%
  read_csv()
```

1. OTP를 제출할 URL을 down_url에 입력합니다.
2. `POST()` 함수를 통해 위에서 부여받은 OTP 코드를 해당 URL에 제출합니다.
3. `add_headers()` 구문을 통해 리퍼러(referer)를 추가해야 합니다. 리퍼러란 링크를 통해서 각각의 웹사이트로 방문할 때 남는 흔적입니다. 거래소 데이터를 다운로드하는 과정을 살펴보면 첫 번째 URL에서 OTP를 부여받고, 이를 다시 두번째 URL에 제출했습니다. 그런데 이러한 과정의 흔적이 없이 OTP를 바로 두번째 URL에 제출하면 서버는 이를 로봇으로 인식해 데이터를 반환하지 않습니다. 따라서 `add_headers()` 함수를 통해 우리가 거쳐온 과정을 흔적으로 남겨
야 데이터를 반환하게 되며 첫 번째 URL을 리퍼러로 지정해줍니다.
4. `read_html()`과 `html_text()` 함수를 통해 텍스트 데이터만 추출합니다.
5. `read_csv()` 함수는 csv 형태의 데이터를 불러옵니다. 위의 요청 쿼리에서 filetype을 csv로 지정했으므로 손쉽게 데이터를 읽어올 수 있습니다.


```r
print(down_sector)
```

```
## # A tibble: 2,243 x 7
##    시장구분 종목코드 종목명 산업분류 `현재가(종가)`
##    <chr>    <chr>    <chr>  <chr>             <dbl>
##  1 코스피   030720   동원수산… 어업               8940
##  2 코스피   007160   사조산업… 어업              54400
##  3 코스피   006040   동원산업… 어업             246500
##  4 코스피   004970   신라교역… 어업              14350
##  5 코스피   006090   사조오양… 음식료품           8220
##  6 코스피   271560   오리온 음식료품          83300
##  7 코스피   101530   해태제과식… 음식료품           9500
##  8 코스피   26490K   크라운제과… 음식료품           7930
##  9 코스피   003580   넥스트사이… 광업               5200
## 10 코스피   012320   경동인베스… 광업              40300
## # … with 2,233 more rows, and 2 more variables:
## #   전일대비 <dbl>, `시가총액(원)` <dbl>
```

위 과정을 통해 down_sector 변수에는 산업별 현황 데이터가 저장되었습니다. 이를 csv 파일로 저장하겠습니다.


```r
ifelse(dir.exists('data'), FALSE, dir.create('data'))
write.csv(down_sector, 'data/krx_sector.csv')
```

먼저 `ifelse()` 함수를 통해 data라는 이름의 폴더가 있으면 FALSE를 반환하고, 없으면 해당 이름으로 폴더를 생성해줍니다. 그 후 앞서 다운로드한 데이터를 data 폴더 안에 krx_sector.csv 이름으로 저장합니다. 해당 폴더를 확인해보면 데이터가 csv 형태로 저장되어 있습니다.

### 개별종목 지표 크롤링

개별종목 데이터를 크롤링하는 방법은 위와 매우 유사하며, 요청하는 쿼리 값에만 차이가 있습니다. 개발자 도구 화면을 열고 [CSV] 버튼을 클릭해 어떠한 쿼리를 요청하는지 확인합니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_krx_ind.png" alt="개별지표 OTP 생성 부분" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-7)개별지표 OTP 생성 부분</p>
</div>

이 중 isu_cdnm, isu_cd, isu_nm, isu_srt_cd, fromdate 항목은 종목 구분의 개별 탭에 해당하는 부분이므로 우리가 원하는 전체 데이터를 받을 때는 필요하지 않은 요청값입니다. 이를 제외한 요청값을 산업별 현황 예제에 적용하면 해당 데이터 역시 손쉽게 다운로드할 수 있습니다.


```r
library(httr)
library(rvest)
library(readr)

gen_otp_url =
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(
  name = 'fileDown',
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
##    일자       종목코드 종목명 관리여부  종가 EPS   PER  
##    <date>     <chr>    <chr>  <chr>    <dbl> <chr> <chr>
##  1 2019-06-07 000250   삼천당제약… -        39650 409   96.94
##  2 2019-06-07 000440   중앙에너비… -         6880 958   7.18 
##  3 2019-06-07 001000   신라섬유… -         2225 7     317.…
##  4 2019-06-07 001540   안국약품… -        11350 1,154 9.84 
##  5 2019-06-07 001810   무림SP -         2795 505   5.53 
##  6 2019-06-07 001840   이화공영… -         5290 24    220.…
##  7 2019-06-07 002230   피에스텍… -         4275 -     -    
##  8 2019-06-07 002290   삼일기업공… -         3185 250   12.74
##  9 2019-06-07 002680   한탑   -         2435 -     -    
## 10 2019-06-07 002800   신신제약… -         7050 191   36.91
## # … with 2,194 more rows, and 6 more variables:
## #   BPS <chr>, PBR <chr>, 주당배당금 <dbl>,
## #   배당수익률 <dbl>, `게시물 일련번호` <dbl>,
## #   총카운트 <dbl>
```

위 과정을 통해 down_ind 변수에는 개별종목 지표 데이터가 저장되었습니다. 해당 데이터 역시 csv 파일로 저장하겠습니다.


```r
write.csv(down_ind, 'data/krx_ind.csv')
```

### 최근 영업일 기준 데이터 받기

위 예제의 쿼리 항목 중 date와 schdate 부분을 원하는 일자로 입력하면(예: 20190104) 해당일의 데이터를 다운로드할 수 있으며, 전 영업일 날짜를 입력하면 가장 최근의 데이터를 받을 수 있습니다. 그러나 매번 해당 항목을 입력하기는 번거로우므로 자동으로 반영되게 할 필요가 있습니다.

네이버 금융의 [국내증시 → 증시자금동향]에는 이전 2영업일에 해당하는 날짜가 있으며, 자동으로 날짜가 업데이트되어 편리합니다. 따라서 해당 부분을 크롤링해 쿼리 항목에 사용할 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_recentdate.png" alt="최근 영업일 부분" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-11)최근 영업일 부분</p>
</div>

크롤링하고자 하는 데이터가 하나거나 소수일때는 HTML 구조를 모두 분해한 후 데이터를 추출하는 것보다 Xpath를 이용하는 것이 훨씬 효율적입니다. Xpath란 XML 중 특정 값의 태그나 속성을 찾기 쉽게 만든 주소라 생각하면 됩니다. 예를 들어 R 프로그램이 저장된 곳을 윈도우 탐색기를 이용해 이용하면 C:\\Program Files\\R\\R-3.4.2 형태의 주소를 보이는데 이것은 윈도우의 path 문법입니다. XML 역시 이와 동일한 개념의 Xpath가 있습니다. 웹페이지에서 Xpath를 찾는 법은 다음과 같습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_xpath.png" alt="Xpath 복사하기" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-12)Xpath 복사하기</p>
</div>

먼저 크롤링하고자 하는 내용에 마우스 커서를 올린 채 마우스 오른쪽 버튼을 클릭한 후 [검사]를 선택합니다. 그러면 개발자 도구 화면이 열리며 해당 지점의 HTML 부분이 선택됩니다. 그 후 HTML 화면에서 마우스 오른쪽 버튼을 클릭하고 [Copy → Copy Xpath]를 선택하면 해당 지점의 Xpath가 복사됩니다.


```css
//*[@id="type_0"]/div/ul[2]/li/span
```


<style type="text/css">
//*[@id="type_0"]/div/ul[2]/li/span
</style>

위에서 구한 날짜의 Xpath를 이용해 해당 데이터를 크롤링하겠습니다.


```r
library(httr)
library(rvest)
library(stringr)

url = 'https://finance.naver.com/sise/sise_deposit.nhn'

biz_day = GET(url) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes(xpath =
               '//*[@id="type_1"]/div/ul[2]/li/span') %>%
  html_text() %>%
  str_match(('[0-9]+.[0-9]+.[0-9]+') ) %>%
  str_replace_all('\\.', '')

print(biz_day)
```

```
## [1] "20201201"
```

1. 페이지의 url을 저장합니다.
2. `GET()` 함수를 통해 해당 페이지 내용을 받습니다.
3. `read_html()` 함수를 이용해 해당 페이지의 HTML 내용을 읽어오며, 인코딩은 EUC-KR로 설정합니다.
4. `html_node()` 함수 내에 위에서 구한 Xpath를 입력해서 해당 지점의 데이터를 추출합니다.
5. `html_text()` 함수를 통해 텍스트 데이터만을 추출합니다.
6. `str_match()` 함수 내에서 정규표현식^[특정한 규칙을 가진 문자열의 집합을 표현하는데 사용하는 형식 언어]을 이용해 숫자.숫자.숫자 형식의 데이터를 추출합니다.
7. `str_replace_all()` 함수를 이용해 마침표(.)를 모두 없애줍니다.

이처럼 Xpath를 이용하면 태그나 속성을 분해하지 않고도 원하는 지점의 데이터를 크롤링할 수 있습니다. 위 과정을 통해 yyyymmdd 형태의 날짜만 남게 되었습니다. 이를 위의 date와 schdate에 입력하면 산업별 현황과 개별종목 지표를 최근일자 기준으로 다운로드하게 됩니다. 전체 코드는 다음과 같습니다.


```r
library(httr)
library(rvest)
library(stringr)
library(readr)

# 최근 영업일 구하기
url = 'https://finance.naver.com/sise/sise_deposit.nhn'

biz_day = GET(url) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes(xpath =
               '//*[@id="type_1"]/div/ul[2]/li/span') %>%
  html_text() %>%
  str_match(('[0-9]+.[0-9]+.[0-9]+') ) %>%
  str_replace_all('\\.', '')

# 산업별 현황 OTP 발급
gen_otp_url =
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(
  name = 'fileDown',
  filetype = 'csv',
  url = 'MKD/03/0303/03030103/mkd03030103',
  tp_cd = 'ALL',
  date = biz_day, # 최근영업일로 변경
  lang = 'ko',
  pagePath = '/contents/MKD/03/0303/03030103/MKD03030103.jsp')
otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

# 산업별 현황 데이터 다운로드
down_url = 'http://file.krx.co.kr/download.jspx'
down_sector = POST(down_url, query = list(code = otp),
                   add_headers(referer = gen_otp_url)) %>%
  read_html() %>%
  html_text() %>%
  read_csv()

ifelse(dir.exists('data'), FALSE, dir.create('data'))
write.csv(down_sector, 'data/krx_sector.csv')

# 개별종목 지표 OTP 발급
gen_otp_url =
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(
  name = 'fileDown',
  filetype = 'csv',
  url = "MKD/13/1302/13020401/mkd13020401",
  market_gubun = 'ALL',
  gubun = '1',
  schdate = biz_day, # 최근영업일로 변경
  pagePath = "/contents/MKD/13/1302/13020401/MKD13020401.jsp")

otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

# 개별종목 지표 데이터 다운로드
down_url = 'http://file.krx.co.kr/download.jspx'
down_ind = POST(down_url, query = list(code = otp),
                add_headers(referer = gen_otp_url)) %>%
  read_html() %>%
  html_text() %>%
  read_csv()

write.csv(down_ind, 'data/krx_ind.csv')
```

### 거래소 데이터 정리하기

위에서 다운로드한 데이터는 중복된 열이 있으며, 불필요한 데이터 역시 있습니다. 따라서 하나의 테이블로 합친 후 정리할 필요가 있습니다. 먼저 다운로드한 csv 파일을 읽어옵니다.


```r
down_sector = read.csv('data/krx_sector.csv', row.names = 1,
                       stringsAsFactors = FALSE)
down_ind = read.csv('data/krx_ind.csv',  row.names = 1,
                    stringsAsFactors = FALSE)
```

`read.csv()` 함수를 이용해 csv 파일을 불러옵니다. `row.names = 1`을 통해 첫 번째 열을 행 이름으로 지정하고, `stringsAsFactors = FALSE`를 통해 문자열 데이터가 팩터 형태로 변형되지 않게 합니다.


```r
intersect(names(down_sector), names(down_ind))
```

```
## [1] "종목코드" "종목명"
```

먼저 `intersect()` 함수를 통해 두 데이터 간 중복되는 열 이름을 살펴보면 종목코드와 종목명이 동일한 위치에 있습니다.


```r
setdiff(down_sector[, '종목명'], down_ind[ ,'종목명'])
```

```
##  [1] "엘브이엠씨홀딩스"   "한국패러랠"        
##  [3] "한국ANKOR유전"      "맵스리얼티1"       
##  [5] "맥쿼리인프라"       "베트남개발1"       
##  [7] "코람코에너지리츠"   "제이알글로벌리츠"  
##  [9] "미래에셋맵스리츠"   "이지스레지던스리츠"
## [11] "이지스밸류리츠"     "NH프라임리츠"      
## [13] "롯데리츠"           "신한알파리츠"      
## [15] "이리츠코크렙"       "모두투어리츠"      
## [17] "하이골드12호"       "바다로19호"        
## [19] "하이골드3호"        "케이탑리츠"        
## [21] "에이리츠"           "소마젠(Reg.S)"     
## [23] "JTC"                "뉴프라이드"        
## [25] "컬러레이"           "윙입푸드"          
## [27] "글로벌에스엠"       "크리스탈신소재"    
## [29] "씨케이에이치"       "골든센츄리"        
## [31] "오가닉티코스메틱"   "GRT"               
## [33] "로스웰"             "헝셩그룹"          
## [35] "이스트아시아홀딩스" "에스앤씨엔진그룹"  
## [37] "미투젠"             "SNK"               
## [39] "SBI핀테크솔루션즈"  "잉글우드랩"        
## [41] "코오롱티슈진"       "엑세스바이오"
```

`setdiff()` 함수를 통해 두 데이터에 공통적으로 없는 종목명, 즉 하나의 데이터에만 있는 종목을 살펴보면 위와 같습니다. 해당 종목들은 선박펀드, 광물펀드, 해외종목 등 일반적이지 않은 종목들이므로 제외하는 것이 좋습니다. 따라서 둘 사이에 공통적으로 존재하는 종목을 기준으로 데이터를 합쳐주겠습니다.


```r
KOR_ticker = merge(down_sector, down_ind,
                   by = intersect(names(down_sector),
                                  names(down_ind)),
                   all = FALSE
                   )
```

`merge()` 함수는 by를 기준으로 두 데이터를 하나로 합치며, 공통으로 존재하는 종목코드, 종목명을 기준으로 입력해줍니다. 또한 all 값을 TRUE로 설정하면 합집합을 반환하고, FALSE로 설정하면 교집합을 반환합니다. 공통으로 존재하는 항목을 원하므로 여기서는 FALSE를 입력합니다.


```r
KOR_ticker = KOR_ticker[order(-KOR_ticker['시가총액.원.']), ]
print(head(KOR_ticker))
```

```
##      종목코드           종목명 시장구분 산업분류
## 328    005930         삼성전자   코스피 전기전자
## 45     000660       SK하이닉스   코스피 전기전자
## 846    035420            NAVER   코스피 서비스업
## 1926   207940 삼성바이오로직스   코스피   의약품
## 1076   051910           LG화학   코스피     화학
## 329    005935       삼성전자우   코스피 전기전자
##      현재가.종가. 전일대비 시가총액.원.       일자
## 328         58600      400    3.498e+14 2020-09-23
## 45          83600     2300    6.086e+13 2020-09-23
## 846        296500    12000    4.870e+13 2020-09-23
## 1926       705000   -26000    4.665e+13 2020-09-23
## 1076       630000    -9000    4.447e+13 2020-09-23
## 329         50900     -100    4.188e+13 2020-09-23
##      관리여부   종가   EPS    PER     BPS   PBR
## 328         -  58600 3,166  18.51  37,528  1.56
## 45          -  83600 2,943  28.41  65,836  1.27
## 846         - 296500 4,006  74.01  35,223  8.42
## 1926        - 705000 3,067 229.87  65,812 10.71
## 1076        - 630000 4,085 154.22 217,230   2.9
## 329         -  50900     -      -       -     -
##      주당배당금 배당수익률 게시물..일련번호 총카운트
## 328        1416       2.42             1726       NA
## 45         1000       1.20             1459       NA
## 846         376       0.13             2045       NA
## 1926          0       0.00             2250       NA
## 1076       2000       0.32             2076       NA
## 329        1417       2.78             1727       NA
```

데이터를 시가총액 기준으로 내림차순 정렬할 필요도 있습니다. `order()` 함수를 통해 상대적인 순서를 구할 수 있습니다. R은 기본적으로 오름차순으로 순서를 구하므로 앞에 마이너스(-)를 붙여 내림차순 형태로 바꿉니다. 결과적으로 시가총액 기준 내림차
순으로 해당 데이터가 정렬됩니다.

마지막으로 스팩, 우선주 종목 역시 제외해야 합니다.


```r
library(stringr)

KOR_ticker[grepl('스팩', KOR_ticker[, '종목명']), '종목명']  
```

```
##  [1] "대신밸런스제6호스팩"  "엔에이치스팩14호"    
##  [3] "케이비제18호스팩"     "삼성스팩2호"         
##  [5] "엔에이치스팩17호"     "유안타제6호스팩"     
##  [7] "미래에셋대우스팩3호"  "케이비제20호스팩"    
##  [9] "엔에이치스팩15호"     "유안타제5호스팩"     
## [11] "한화에스비아이스팩"   "SK6호스팩"           
## [13] "대신밸런스제8호스팩"  "미래에셋대우스팩 5호"
## [15] "케이비17호스팩"       "교보10호스팩"        
## [17] "IBKS제11호스팩"       "대신밸런스제7호스팩" 
## [19] "IBKS제13호스팩"       "SK4호스팩"           
## [21] "한국제7호스팩"        "하이제5호스팩"       
## [23] "신한제6호스팩"        "삼성머스트스팩3호"   
## [25] "하나머스트제6호스팩"  "하나금융15호스팩"    
## [27] "상상인이안1호스팩"    "한화플러스제1호스팩" 
## [29] "하이제4호스팩"        "유안타제4호스팩"     
## [31] "DB금융스팩7호"        "미래에셋대우스팩4호" 
## [33] "하나금융14호스팩"     "IBKS제14호스팩"      
## [35] "유안타제3호스팩"      "엔에이치스팩16호"    
## [37] "IBKS제10호스팩"       "케이비제19호스팩"    
## [39] "SK5호스팩"            "신영스팩6호"         
## [41] "에이치엠씨제4호스팩"  "신한제5호스팩"       
## [43] "하나금융16호스팩"     "교보8호스팩"         
## [45] "유진스팩5호"          "교보9호스팩"         
## [47] "상상인이안제2호스팩"  "키움제5호스팩"       
## [49] "이베스트스팩5호"      "신영스팩5호"         
## [51] "유진스팩4호"          "엔에이치스팩13호"    
## [53] "한국제8호스팩"        "IBKS제12호스팩"      
## [55] "이베스트이안스팩1호"
```

```r
KOR_ticker[str_sub(KOR_ticker[, '종목코드'], -1, -1) != 0, '종목명']
```

```
##   [1] "삼성전자우"         "현대차2우B"        
##   [3] "LG화학우"           "현대차우"          
##   [5] "LG생활건강우"       "아모레퍼시픽우"    
##   [7] "미래에셋대우2우B"   "LG전자우"          
##   [9] "삼성화재우"         "삼성SDI우"         
##  [11] "신풍제약우"         "한국금융지주우"    
##  [13] "신영증권우"         "한화3우B"          
##  [15] "대신증권우"         "두산퓨얼셀1우"     
##  [17] "CJ4우(전환)"        "아모레G3우(전환)"  
##  [19] "SK케미칼우"         "CJ제일제당 우"     
##  [21] "현대차3우B"         "삼성전기우"        
##  [23] "LG우"               "삼성물산우B"       
##  [25] "대림산업우"         "두산우"            
##  [27] "SK이노베이션우"     "NH투자증권우"      
##  [29] "두산솔루스1우"      "녹십자홀딩스2우"   
##  [31] "아모레G우"          "S-Oil우"           
##  [33] "금호석유우"         "SK우"              
##  [35] "CJ우"               "대신증권2우B"      
##  [37] "두산퓨얼셀2우B"     "유한양행우"        
##  [39] "두산2우B"           "미래에셋대우우"    
##  [41] "SK디스커버리우"     "두산솔루스2우B"    
##  [43] "롯데지주우"         "한화솔루션우"      
##  [45] "코오롱인더우"       "부국증권우"        
##  [47] "GS우"               "일양약품우"        
##  [49] "대교우B"            "티와이홀딩스우"    
##  [51] "호텔신라우"         "삼성중공우"        
##  [53] "롯데칠성우"         "유화증권우"        
##  [55] "쌍용양회우"         "유안타증권우"      
##  [57] "한화우"             "한진칼우"          
##  [59] "남양유업우"         "BYC우"             
##  [61] "LG하우시스우"       "대한항공우"        
##  [63] "대상우"             "하이트진로2우B"    
##  [65] "세방우"             "SK증권우"          
##  [67] "현대건설우"         "한화투자증권우"    
##  [69] "남선알미우"         "태영건설우"        
##  [71] "유유제약1우"        "DB하이텍1우"       
##  [73] "SK네트웍스우"       "삼양사우"          
##  [75] "코오롱우"           "넥센타이어1우B"    
##  [77] "대덕전자1우"        "코리아써우"        
##  [79] "삼양홀딩스우"       "JW중외제약우"      
##  [81] "코오롱글로벌우"     "덕성우"            
##  [83] "성신양회우"         "계양전기우"        
##  [85] "태양금속우"         "서울식품우"        
##  [87] "NPC우"              "넥센우"            
##  [89] "금호산업우"         "깨끗한나라우"      
##  [91] "CJ씨푸드1우"        "대원전선우"        
##  [93] "JW중외제약2우B"     "금강공업우"        
##  [95] "대한제당우"         "대덕1우"           
##  [97] "한양증권우"         "크라운해태홀딩스우"
##  [99] "현대비앤지스틸우"   "동원시스템즈우"    
## [101] "하이트진로홀딩스우" "성문전자우"        
## [103] "진흥기업우B"        "대상홀딩스우"      
## [105] "크라운제과우"       "흥국화재우"        
## [107] "KG동부제철우"       "대호피앤씨우"      
## [109] "노루페인트우"       "동부건설우"        
## [111] "소프트센우"         "유유제약2우B"      
## [113] "루트로닉3우C"       "코리아써키트2우B"  
## [115] "동양우"             "동양2우B"          
## [117] "신원우"             "진흥기업2우B"      
## [119] "흥국화재2우B"       "노루홀딩스우"      
## [121] "동양3우B"
```

`grepl()` 함수를 통해 종목명에 ‘스팩’이 들어가는 종목을 찾고, `stringr` 패키지의 `str_sub()` 함수를 통해 종목코드 끝이 0이 아닌 우선주 종목을 찾을 수 있습니다.


```r
KOR_ticker = KOR_ticker[!grepl('스팩', KOR_ticker[, '종목명']), ]  
KOR_ticker = KOR_ticker[str_sub(KOR_ticker[, '종목코드'], -1, -1) == 0, ]
```

마지막으로 행 이름을 초기화한 후 정리된 데이터를 csv 파일로 저장합니다.


```r
rownames(KOR_ticker) = NULL
write.csv(KOR_ticker, 'data/KOR_ticker.csv')
```

## WICS 기준 섹터정보 크롤링

일반적으로 주식의 섹터를 나누는 기준은 MSCI와 S&P가 개발한 GICS^[https://en.wikipedia.org/wiki/Global_Industry_Classification_Standard]를 가장 많이 사용합니다. 국내 종목의 GICS 기준 정보 역시 한국거래소에서 제공하고 있으나, 이는 독점적 지적재산으로 명시했기에 사용하는 데 무리가 있습니다. 그러나 지수제공업체인 와이즈인덱스^[http://www.wiseindex.com/]에서는 GICS와 비슷한 WICS 산업분류를 발표하고 있습니다. WICS를 크롤링해 필요한 정보를 수집해보겠습니다.

먼저 웹페이지에 접속해 [Index → WISE SECTOR INDEX → WICS → 에너지]를 클릭합니다. 그 후 [Components] 탭을 클릭하면 해당 섹터의 구성종목을 확인할 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_wics.png" alt="WICS 기준 구성종목" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-24)WICS 기준 구성종목</p>
</div>

개발자도구 화면(그림 \@ref(fig:wicurl))을 통해 해당 페이지의 데이터전송 과정을 살펴보도록 하겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_wics2.png" alt="WICS 페이지 개발자도구 화면" width="100%" />
<p class="caption">(\#fig:wicurl)WICS 페이지 개발자도구 화면</p>
</div>

일자를 선택하면 [Network] 탭의 GetIndexComponets 항목을 통해 데이터 전송 과정이 나타납니다. Request URL의 주소를 살펴보면 다음과 같습니다.

1. http://www.wiseindex.com/Index/GetIndexComponets: 데이터를 요청하는 url 입니다.
2. ceil_yn = 0: 실링 여부를 나타내며, 0은 비실링을 의미합니다.
3. dt=20190607: 조회일자를 나타냅니다.
4. sec_cd=G10: 섹터 코드를 나타냅니다.

이번엔 위 주소의 페이지를 열어보겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_wics3.png" alt="WICS 데이터 페이지" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-25)WICS 데이터 페이지</p>
</div>

글자들은 페이지에 출력된 내용이지만 매우 특이한 형태로 구성되어 있는데 이것은 JSON 형식의 데이터입니다. 기존에 우리가 살펴보았던 대부분의 웹페이지는 XML 형식으로 표현되어 있습니다. XML 형식은 문법이 복잡하고 표현 규칙이 엄격해 데이터의 용량이 커지는 단점이 있습니다. 반면 JSON 형식은 문법이 단순하고 데이터의 용량이 작아 빠른 속도로 데이터를 교환할 수 있습니다. R에서는 jsonlite 패키지의 `fromJSON()` 함수를 사용해 매우 손쉽게 JSON 형식의 데이터를 크롤링할 수 있습니다.


```r
library(jsonlite)

url = 'http://www.wiseindex.com/Index/GetIndexComponets?ceil_yn=0&dt=20190607&sec_cd=G10'
data = fromJSON(url)

lapply(data, head)
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
##   IDX_CD  IDX_NM_KOR ALL_MKT_VAL CMP_CD
## 1    G10 WICS 에너지    19850082 096770
## 2    G10 WICS 에너지    19850082 010950
## 3    G10 WICS 에너지    19850082 267250
## 4    G10 WICS 에너지    19850082 078930
## 5    G10 WICS 에너지    19850082 067630
## 6    G10 WICS 에너지    19850082 006120
##              CMP_KOR MKT_VAL   WGT S_WGT CAL_WGT SEC_CD
## 1       SK이노베이션 9052841 45.61 45.61       1    G10
## 2              S-Oil 3403265 17.14 62.75       1    G10
## 3     현대중공업지주 2873204 14.47 77.23       1    G10
## 4                 GS 2491805 12.55 89.78       1    G10
## 5 에이치엘비생명과학  624986  3.15 92.93       1    G10
## 6       SK디스커버리  257059  1.30 94.22       1    G10
##   SEC_NM_KOR SEQ TOP60 APT_SHR_CNT
## 1     에너지   1     2    56403994
## 2     에너지   2     2    41655633
## 3     에너지   3     2     9283372
## 4     에너지   4     2    49245150
## 5     에너지   5     2    39307272
## 6     에너지   6     2    10470820
## 
## $sector
##   SEC_CD         SEC_NM_KOR SEC_RATE IDX_RATE
## 1    G25     경기관련소비재    16.05        0
## 2    G35           건강관리     9.27        0
## 3    G50 커뮤니케이션서비스     2.26        0
## 4    G40               금융    10.31        0
## 5    G10             에너지     2.37      100
## 6    G20             산업재    12.68        0
## 
## $size
##   SEC_CD    SEC_NM_KOR SEC_RATE IDX_RATE
## 1 WMI510 WMI500 대형주    69.40    89.78
## 2 WMI520 WMI500 중형주    13.56     4.44
## 3 WMI530 WMI500 소형주    17.04     5.78
```

\$list 항목에는 해당 섹터의 구성종목 정보가 있으며, \$sector 항목을 통해 다른 섹터의 코드도 확인할 수 있습니다. for loop 구문을 이용해 URL의 sec_cd=에 해당하는 부분만 변경하면 모든 섹터의 구성종목을 매우 쉽게 얻을 수 있습니다.


```r
sector_code = c('G25', 'G35', 'G50', 'G40', 'G10',
                'G20', 'G55', 'G30', 'G15', 'G45')
data_sector = list()

for (i in sector_code) {
  
  url = paste0(
    'http://www.wiseindex.com/Index/GetIndexComponets',
    '?ceil_yn=0&dt=',biz_day,'&sec_cd=',i)
  data = fromJSON(url)
  data = data$list
  
  data_sector[[i]] = data
  
  Sys.sleep(1)
}

data_sector = do.call(rbind, data_sector)
```

해당 데이터를 csv 파일로 저장해주도록 합니다.


```r
write.csv(data_sector, 'data/KOR_sector.csv')
```
