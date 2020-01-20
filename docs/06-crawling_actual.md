

# 금융 데이터 수집하기 (심화)

지난 CHAPTER에서 수집한 주식티커를 바탕으로 이번 CHAPTER에서는 퀀트 투자의 핵심 자료인 수정주가, 재무제표, 가치지표를 크롤링하는 방법을 알아보겠습니다.

## 수정주가 크롤링

주가 데이터는 투자를 함에 있어 반드시 필요한 데이터이며, 인터넷에서 주가를 수집할 수 있는 방법은 매우 많습니다. 먼저 API를 이용한 데이터 수집에서 살펴본 것과 같이, `getSymbols()` 함수를 이용해 데이터를 받을 수 있습니다. 그러나 야후 파이낸스에서 제공하는 데이터 중 미국 주가는 이상 없이 다운로드되지만, 국내 중소형주는 주가가 없는 경우가 있습니다.

또한 단순 주가를 구할 수 있는 방법은 많지만, 투자에 필요한 수정주가를 구할 수 있는 방법은 찾기 힘듭니다. 다행히 네이버 금융에서 제공하는 정보를 통해 모든 종목의 수정주가를 매우 손쉽게 구할 수 있습니다. 

### 개별종목 주가 크롤링

먼저 네이버 금융에서 특정종목(예: 삼성전자)의 [차트] 탭^[https://finance.naver.com/item/fchart.nhn?code=005930]을 선택합니다.^[플래쉬가 차단되어 화면이 나오지 않는 경우, 주소창의 왼쪽 상단에 위치한 자물쇠 버튼을 클릭한 다음, Flash를 허용으로 바꾼 후 새로고침을 누르면 차트가 나오게 됩니다.] 해당 차트는 주가 데이터를 받아 그래프를 그려주는 형태입니다. 따라서 해당 데이터가 어디에서 오는지 알기 위해 개발자 도구 화면을 이용합니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_price2.png" alt="네이버금융 차트의 통신기록" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-3)네이버금융 차트의 통신기록</p>
</div>

화면을 연 상태에서 [일봉] 탭을 선택하면 sise.nhn, schedule.nhn, notice.nhn 총 세 가지 항목이 생성됩니다. 이 중 sise.nhn 항목의 Request URL이 주가 데이터를 요청하는 주소입니다. 해당 URL에 접속해보겠습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_price3.png" alt="주가 데이터 페이지" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-4)주가 데이터 페이지</p>
</div>

각 날짜별로 시가, 고가, 저가, 종가, 거래량이 있으며, 주가는 모두 수정주가 기준입니다. 또한 해당 데이터가 item 태그 내 data 속성에 위치하고 있습니다.

URL에서 symbol= 뒤에 6자리 티커만 변경하면 해당 종목의 주가 데이터가 있는 페이지로 이동할 수 있으며, 우리가 원하는 모든 종목의 주가 데이터를 크롤링할 수 있습니다.


```r
library(stringr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
print(KOR_ticker$'종목코드'[1])
```

```
## [1] 5930
```

```r
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')
```

먼저 저장해두었던 csv 파일을 불러옵니다. 종목코드를 살펴보면 005930이어야 할 삼성전자의 티커가 5930으로 입력되어 있습니다. 이는 파일을 불러오는 과정에서 0으로 시작하는 숫자들이 지워졌기 때문입니다. stringr 패키지의 `str_pad()` 함수를 사용해 6자리가 되지 않는 문자는 왼쪽에 0을 추가해 강제로 6자리로 만들어주도록 합니다.

다음은 첫 번째 종목인 삼성전자의 주가를 크롤링한 후 가공하는 방법입니다.


```r
library(xts)

ifelse(dir.exists('data/KOR_price'), FALSE,
       dir.create('data/KOR_price'))
```

```
## [1] FALSE
```

```r
i = 1
name = KOR_ticker$'종목코드'[i]

price = xts(NA, order.by = Sys.Date())
print(price)
```

```
##            [,1]
## 2020-01-20   NA
```

1. data 폴더 내에 KOR_price 폴더를 생성합니다.
2. i = 1을 입력합니다. 향후 for loop 구문을 통해 i 값만 변경하면 모든 종목의 주가를 다운로드할 수 있습니다.
3. name에 해당 티커를 입력합니다.
4. `xts()` 함수를 이용해 빈 시계열 데이터를 생성하며, 인덱스는 `Sys.Date()`를 통해 현재 날짜를 입력합니다.


```r
library(httr)
library(rvest)

url = paste0(
  'https://fchart.stock.naver.com/sise.nhn?symbol=',
  name,'&timeframe=day&count=500&requestType=0')
data = GET(url)
data_html = read_html(data, encoding = 'EUC-KR') %>%
  html_nodes('item') %>%
  html_attr('data') 

print(head(data_html))
```

```
## [1] "20180105|51300|52120|51200|52120|189623"
## [2] "20180108|52400|52520|51500|52020|167673"
## [3] "20180109|51460|51720|49980|50400|360272"
## [4] "20180110|50500|50520|48640|48840|371336"
## [5] "20180111|48200|49260|48020|48240|502476"
## [6] "20180112|48240|48480|46760|48200|545409"
```

1. `paste0()` 함수를 이용해 원하는 종목의 url을 생성합니다. url 중 티커에 해당하는 6자리 부분만 위에서 입력한 name으로 설정해주면 됩니다.
2. `GET()` 함수를 통해 페이지의 데이터를 불러옵니다.
3. `read_html()` 함수를 통해 HTML 정보를 읽어옵니다.
4. `html_nodes()`와 `html_attr()` 함수를 통해 item 태그 및 data 속성의 데이터를 추출합니다.

결과적으로 날짜 및 주가, 거래량 데이터가 추출됩니다. 해당 데이터는 |으로 구분되어 있으며, 이를 테이블 형태로 바꿀 필요가 있습니다.


```r
library(readr)

price = read_delim(data_html, delim = '|')
print(head(price))
```

```
## # A tibble: 6 x 6
##   `20180105` `51300` `52120` `51200` `52120_1` `189623`
##        <dbl>   <dbl>   <dbl>   <dbl>     <dbl>    <dbl>
## 1   20180108   52400   52520   51500     52020   167673
## 2   20180109   51460   51720   49980     50400   360272
## 3   20180110   50500   50520   48640     48840   371336
## 4   20180111   48200   49260   48020     48240   502476
## 5   20180112   48240   48480   46760     48200   545409
## 6   20180115   48800   48980   47920     48540   201920
```

readr 패키지의 `read_delim()` 함수를 쓰면 구분자로 이루어진 데이터를 테이블로 쉽게 변경할 수 있습니다. 데이터를 확인해보면 테이블 형태로 변경되었으며 각 열은 날짜, 시가, 고가, 저가, 종가, 거래량을 의미합니다. 이 중 우리가 필요한 날짜와 종가를 선택한 후 데이터 클렌징을 해줍니다.


```r
library(lubridate)
library(timetk)

price = price[c(1, 5)] 
price = data.frame(price)
colnames(price) = c('Date', 'Price')
price[, 1] = ymd(price[, 1])
price = tk_xts(price, date_var = Date)
 
print(tail(price))
```

```
##            Price
## 2020-01-13 60000
## 2020-01-14 60000
## 2020-01-15 59000
## 2020-01-16 60700
## 2020-01-17 61300
## 2020-01-20 62400
```

1. 날짜에 해당하는 첫 번째 열과, 종가에 해당하는 다섯 번째 열만 선택해 저장합니다.
2. 티블 형태의 데이터를 데이터 프레임 형태로 변경합니다.
3. 열 이름을 Date와 Price로 변경합니다.
4. lubridate 패키지의 `ymd()` 함수를 이용하면 yyyymmdd 형태가 yyyy-mm-dd로 변경되며 데이터 형태 또한 Date 타입으로 변경됩니다.
5. `timetk` 패키지의 `tk_xts()` 함수를 이용해 시계열 형태로 변경하며, 인덱스는 Date 열을 설정합니다. 형태를 변경한 후 해당 열은 자동으로 삭제됩니다.

데이터를 확인해보면 우리에게 필요한 형태로 정리되었습니다.


```r
write.csv(price, paste0('data/KOR_price/', name,
                        '_price.csv'))
```

마지막으로 해당 데이터를 data 폴더의 KOR_price 폴더 내에 티커_price.csv 이름으로 저장합니다.

### 전 종목 주가 크롤링

위의 코드에서 for loop 구문을 이용해 i 값만 변경해주면 모든 종목의 주가를 다운로드할 수 있습니다. 전 종목 주가를 다운로드하는 전체 코드는 다음과 같습니다.


```r
library(httr)
library(rvest)
library(stringr)
library(xts)
library(lubridate)
library(readr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
print(KOR_ticker$'종목코드'[1])
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')

ifelse(dir.exists('data/KOR_price'), FALSE,
       dir.create('data/KOR_price'))

for(i in 1 : nrow(KOR_ticker) ) {
  
  price = xts(NA, order.by = Sys.Date()) # 빈 시계열 데이터 생성
  name = KOR_ticker$'종목코드'[i] # 티커 부분 선택
  
  # 오류 발생 시 이를 무시하고 다음 루프로 진행
  tryCatch({
    # url 생성
    url = paste0(
      'https://fchart.stock.naver.com/sise.nhn?symbol='
      ,name,'&timeframe=day&count=500&requestType=0')
    
    # 이 후 과정은 위와 동일함
    # 데이터 다운로드
    data = GET(url)
    data_html = read_html(data, encoding = 'EUC-KR') %>%
      html_nodes("item") %>%
      html_attr("data") 
    
    # 데이터 나누기
    price = read_delim(data_html, delim = '|')
    
    # 필요한 열만 선택 후 클렌징
    price = price[c(1, 5)] 
    price = data.frame(price)
    colnames(price) = c('Date', 'Price')
    price[, 1] = ymd(price[, 1])
    
    rownames(price) = price[, 1]
    price[, 1] = NULL
    
  }, error = function(e) {
    
    # 오류 발생시 해당 종목명을 출력하고 다음 루프로 이동
    warning(paste0("Error in Ticker: ", name))
  })
  
  # 다운로드 받은 파일을 생성한 폴더 내 csv 파일로 저장
  write.csv(price, paste0('data/KOR_price/', name,
                          '_price.csv'))
  
  # 타임슬립 적용
  Sys.sleep(2)
}
```

위 코드에서 추가된 점은 다음과 같습니다. 페이지 오류, 통신 오류 등 오류가 발생할 경우 for loop 구문은 멈춰버리는데 전체 데이터를 처음부터 다시 받는 일은 매우 귀찮은 작업입니다. 따라서 `tryCatch()` 함수를 이용해 오류가 발생할 때 해당 티커를 출력한 후 다음 루프로 넘어가게 합니다.

또한 오류가 발생하면 `xts()` 함수를 통해 만들어둔 빈 데이터를 저장하게 됩니다. 마지막으로 무한 크롤링을 방지하기 위해 한 번의 루프가 끝날 때마다 2초의 타임슬립을 적용했습니다.

위 코드가 모두 돌아가는 데는 수 시간이 걸립니다. 작업이 끝난 후 data/KOR_price 폴더를 확인해보면 전 종목 주가가 csv 형태로 저장되어 있습니다.

## 재무제표 및 가치지표 크롤링

주가와 더불어 재무제표와 가치지표 역시 투자에 있어 핵심이 되는 데이터입니다. 해당 데이터 역시 여러 웹사이트에서 구할 수 있지만, 국내 데이터 제공업체인 FnGuide에서 운영하는 Company Guide 웹사이트^[http://comp.fnguide.com/]에서 손쉽게 구할 수 있습니다.

### 재무제표 다운로드

먼저 개별종목의 재무제표를 탭을 선택하면 포괄손익계산서, 재무상태표, 현금흐름표 항목이 보이게 되며, 티커에 해당하는 A005930 뒤의 주소는 불필요한 내용이므로, 이를 제거한 주소로 접속합니다. A 뒤의 6자리 티커만 변경한다면 해당 종목의 재무제표 페이지로 이동하게 됩니다.

**http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A005930**


우리가 원하는 재무제표 항목들은 모두 테이블 형태로 제공되고 있으므로 html_table() 함수를 이용해 추출할 수 있습니다.


```r
library(httr)
library(rvest)

ifelse(dir.exists('data/KOR_fs'), FALSE,
       dir.create('data/KOR_fs'))

Sys.setlocale("LC_ALL", "English")

url = paste0('http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A005930')

data = GET(url)
data = data %>%
  read_html() %>%
  html_table()

Sys.setlocale("LC_ALL", "Korean")
```

```r
lapply(data, function(x) {
  head(x, 3)})
```

```
## [[1]]
##   IFRS(연결)   2016/12   2017/12   2018/12   2019/09  전년동기 전년동기(%)
## 1     매출액 2,018,667 2,395,754 2,437,714 1,705,161 1,845,064        -7.6
## 2   매출원가 1,202,777 1,292,907 1,323,944 1,086,850   983,784        10.5
## 3 매출총이익   815,890 1,102,847 1,113,770   618,311   861,279       -28.2
## 
## [[2]]
##   IFRS(연결) 2018/12 2019/03 2019/06 2019/09 전년동기 전년동기(%)
## 1     매출액 592,651 523,855 561,271 620,035  654,600        -5.3
## 2   매출원가 340,160 327,465 359,447 399,939  351,944        13.6
## 3 매출총이익 252,491 196,391 201,824 220,096  302,656       -27.3
## 
## [[3]]
##                          IFRS(연결)   2016/12   2017/12   2018/12
## 1                              자산 2,621,743 3,017,521 3,393,572
## 2 유동자산계산에 참여한 계정 펼치기 1,414,297 1,469,825 1,746,974
## 3                          재고자산   183,535   249,834   289,847
##     2019/09
## 1 3,533,860
## 2 1,860,421
## 3   309,088
## 
## [[4]]
##                          IFRS(연결)   2018/12   2019/03   2019/06
## 1                              자산 3,393,572 3,450,679 3,429,401
## 2 유동자산계산에 참여한 계정 펼치기 1,746,974 1,773,885 1,734,335
## 3                          재고자산   289,847   314,560   312,470
##     2019/09
## 1 3,533,860
## 2 1,860,421
## 3   309,088
## 
## [[5]]
##                     IFRS(연결) 2016/12 2017/12 2018/12 2019/09
## 1     영업활동으로인한현금흐름 473,856 621,620 670,319 256,658
## 2                   당기순손익 227,261 421,867 443,449 165,118
## 3 법인세비용차감전계속사업이익                                
## 
## [[6]]
##                     IFRS(연결) 2018/12 2019/03 2019/06 2019/09
## 1     영업활동으로인한현금흐름 224,281  52,443  65,949 138,266
## 2                   당기순손익  84,622  50,436  51,806  62,877
## 3 법인세비용차감전계속사업이익
```

1. data 폴더 내에 KOR_fs 폴더를 생성합니다.
2. `Sys.setlocale()` 함수를 통해 로케일 언어를 English로 설정합니다.
3. url을 입력한 후 `GET()` 함수를 통해 페이지 내용을 받아옵니다.
4. `read_html()` 함수를 통해 HTML 내용을 읽어오며, `html_table()` 함수를 통해 테이블 내용만 추출합니다.
5. 로케일 언어를 다시 Korean으로 설정합니다.

위의 과정을 거치면 data 변수에는 리스트 형태로 총 6개의 테이블이 들어오게 되며, 그 내용은 표 \@ref(tab:fstable)와 같습니다.


Table: (\#tab:fstable)재무제표 테이블 내역

 순서            내용          
------  -----------------------
  1      포괄손익계산서 (연간) 
  2      포괄손익계산서 (분기) 
  3        재무상태표 (연간)   
  4        재무상태표 (분기)   
  5        현금흐름표 (연간)   
  6        현금흐름표 (분기)   

이 중 연간 기준 재무제표에 해당하는 첫 번째, 세 번째, 다섯 번째 테이블을 선택합니다.


```r
data_IS = data[[1]]
data_BS = data[[3]]
data_CF = data[[5]]

print(names(data_IS))
```

```
## [1] "IFRS(연결)"  "2016/12"     "2017/12"     "2018/12"     "2019/09"    
## [6] "전년동기"    "전년동기(%)"
```

```r
data_IS = data_IS[, 1:(ncol(data_IS)-2)]
```

포괄손익계산서 테이블(data_IS)에는 전년동기, 전년동기(%) 열이 있는데 통일성을 위해 해당 열을 삭제합니다. 이제 테이블을 묶은 후 클렌징하겠습니다.


```r
data_fs = rbind(data_IS, data_BS, data_CF)
data_fs[, 1] = gsub('계산에 참여한 계정 펼치기',
                    '', data_fs[, 1])
data_fs = data_fs[!duplicated(data_fs[, 1]), ]

rownames(data_fs) = NULL
rownames(data_fs) = data_fs[, 1]
data_fs[, 1] = NULL

data_fs = data_fs[, substr(colnames(data_fs), 6,7) == '12']
```

1. `rbind()` 함수를 이용해 세 테이블을 행으로 묶은 후 data_fs에 저장합니다.
2. 첫 번째 열인 계정명에는 ‘계산에 참여한 계정 펼치기’라는 글자가 들어간 항목이 있습니다. 이는 페이지 내에서 펼치기 역할을 하는 (+) 항목에 해당하며 `gsub()` 함수를 이용해 해당 글자를 삭제합니다.
3. 중복되는 계정명이 다수 있는데 대부분 불필요한 항목입니다. `!duplicated()` 함수를 사용해 중복되지 않는 계정명만 선택합니다.
4. 행 이름을 초기화한 후 첫 번째 열의 계정명을 행 이름으로 변경합니다. 그 후 첫 번째 열은 삭제합니다.
5. 간혹 12월 결산법인이 아닌 종목이거나 연간 재무제표임에도 불구하고 분기 재무제표가 들어간 경우가 있습니다. 비교의 통일성을 위해 `substr()` 함수를 이용해 끝 글자가 12인 열, 즉 12월 결산 데이터만 선택합니다.


```r
print(head(data_fs))
```

```
##                    2016/12   2017/12   2018/12
## 매출액           2,018,667 2,395,754 2,437,714
## 매출원가         1,202,777 1,292,907 1,323,944
## 매출총이익         815,890 1,102,847 1,113,770
## 판매비와관리비     523,484   566,397   524,903
## 인건비              59,763    67,972    64,514
## 유무형자산상각비    10,018    13,366    14,477
```

```r
sapply(data_fs, typeof)
```

```
##     2016/12     2017/12     2018/12 
## "character" "character" "character"
```

데이터를 확인해보면 연간 기준 재무제표가 정리되었습니다. 문자형 데이터이므로 숫자형으로 변경합니다.


```r
library(stringr)

data_fs = sapply(data_fs, function(x) {
  str_replace_all(x, ',', '') %>%
    as.numeric()
}) %>%
  data.frame(., row.names = rownames(data_fs))

print(head(data_fs))
```

```
##                  X2016.12 X2017.12 X2018.12
## 매출액            2018667  2395754  2437714
## 매출원가          1202777  1292907  1323944
## 매출총이익         815890  1102847  1113770
## 판매비와관리비     523484   566397   524903
## 인건비              59763    67972    64514
## 유무형자산상각비    10018    13366    14477
```

```r
sapply(data_fs, typeof)
```

```
## X2016.12 X2017.12 X2018.12 
## "double" "double" "double"
```

1. `sapply()` 함수를 이용해 각 열에 stringr 패키지의 `str_replace_allr()` 함수를 적용해 콤마(,)를 제거한 후 `as.numeric()` 함수를 통해 숫자형 데이터로 변경합니다.
2. `data.frame()` 함수를 이용해 데이터 프레임 형태로 만들어주며, 행 이름은 기존 내용을 그대로 유지합니다.

정리된 데이터를 출력해보면 문자형이던 데이터가 숫자형으로 변경되었습니다.


```r
write.csv(data_fs, 'data/KOR_fs/005930_fs.csv')
```

data 폴더의 KOR_fs 폴더 내에 티커_fs.csv 이름으로 저장합니다.

### 가치지표 계산하기

위에서 구한 재무제표 데이터를 이용해 가치지표를 계산할 수 있습니다. 흔히 사용되는 가치지표는 **PER, PBR, PCR, PSR**이며 분자는 주가, 분모는 재무제표 데이터가 사용됩니다.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:unnamed-chunk-19)가치지표의 종류</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> 순서 </th>
   <th style="text-align:center;"> 분모 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> PER </td>
   <td style="text-align:center;"> Earnings (순이익) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> PBR </td>
   <td style="text-align:center;"> Book Value (순자산) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> PCR </td>
   <td style="text-align:center;"> Cashflow (영업활동현금흐름) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> PSR </td>
   <td style="text-align:center;"> Sales (매출액) </td>
  </tr>
</tbody>
</table>

위에서 구한 재무제표 항목에서 분모 부분에 해당하는 데이터만 선택해보겠습니다.


```r
ifelse(dir.exists('data/KOR_value'), FALSE,
       dir.create('data/KOR_value'))
```

```
## [1] FALSE
```

```r
value_type = c('지배주주순이익',
               '자본',
               '영업활동으로인한현금흐름',
               '매출액')

value_index = data_fs[match(value_type, rownames(data_fs)),
                      ncol(data_fs)]
print(value_index)
```

```
## [1]  438909 2477532  670319 2437714
```

1. data 폴더 내에 KOR_value 폴더를 생성합니다.
2. 분모에 해당하는 항목을 저장한 후 `match()` 함수를 이용해 해당 항목이 위치하는 지점을 찾습니다. `ncol()` 함수를 이용해 맨 오른쪽, 즉 최근년도 재무제표 데이터를 선택합니다.

다음으로 분자 부분에 해당하는 현재 주가를 수집해야 합니다. 이 역시 Company Guide 접속 화면에서 구할 수 있습니다. 불필요한 부분을 제거한 URL은 다음과 같습니다.

**http://comp.fnguide.com/SVO2/ASP/SVD_main.asp?pGB=1&gicode=A005930**

위의 주소 역시 A 뒤의 6자리 티커만 변경하면 해당 종목의 스냅샷 페이지로 이동하게 됩니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_practice_comp_price.png" alt="Company Guide 스냅샷 화면" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-21)Company Guide 스냅샷 화면</p>
</div>

주가추이 부분에 우리가 원하는 현재 주가가 있습니다. 해당 데이터의 Xpath는 다음과 같습니다.


```css
//*[@id="svdMainChartTxt11"]
```


<style type="text/css">
//*[@id="svdMainChartTxt11"]
</style>

위에서 구한 주가의 Xpath를 이용해 해당 데이터를 크롤링하겠습니다.


```r
library(readr)

url = 'http://comp.fnguide.com/SVO2/ASP/SVD_main.asp?pGB=1&gicode=A005930'
data = GET(url)

price = read_html(data) %>%
  html_node(xpath = '//*[@id="svdMainChartTxt11"]') %>%
  html_text() %>%
  parse_number()

print(price)
```

```
## [1] 61300
```

1. url을 입력한 후, `GET()` 함수를 이용해 데이터를 불러옵니다.
2. `read_html()` 함수를 이용해 HTML 데이터를 불러온 후 `html_node()` 함수에 앞서 구한 Xpath를 입력해 해당 지점의 데이터를 추출합니다.
3. `html_text()` 함수를 통해 텍스트 데이터만을 추출하며, readr 패키지의 `parse_number()` 함수를 적용합니다. 해당 함수는 문자형 데이터에서 콤마와 같은 불필요한 문자를 제거한 후 숫자형 데이터로 변경해줍니다.

가치지표를 계산하려면 발행주식수 역시 필요합니다. 예를 들어 PER를 계산하는 방법은 다음과 같습니다.

$$ PER = Price / EPS  = 주가 / 주당순이익$$
  
주당순이익은 순이익을 전체 주식수로 나눈 값이므로, 해당 값의 계산하려면 전체 주식수를 구해야 합니다. 전체 주식수 데이터 역시 웹페이지에 있으므로 앞서 주가를 크롤링한 방법과 동일한 방법으로 구할 수 있습니다. 전체 주식수 데이터의 Xpath는 다음과 같습니다.


```css
//*[@id="svdMainGrid1"]/table/tbody/tr[7]/td[1]
```


<style type="text/css">
//*[@id="svdMainGrid1"]/table/tbody/tr[7]/td[1]
</style>

이를 이용해 발행주식수 중 보통주를 선택하는 방법은 다음과 같습니다.


```r
share = read_html(data) %>%
  html_node(
    xpath =
      '//*[@id="svdMainGrid1"]/table/tbody/tr[7]/td[1]') %>%
  html_text()

print(share)
```

```
## [1] "5,969,782,550/ 822,886,700"
```

`read_html()` 함수와 `html_node()` 함수를 이용해, HTML 내에서 Xpath에 해당하는 데이터를 추출합니다. 그 후 `html_text()` 함수를 통해 텍스트 부분만 추출합니다. 해당 과정을 거치면 보통주/우선주의 형태로 발행주식주가 저장됩니다. 이 중 우리가 원하는 데이터는 / 앞에 있는 보통주 발행주식수입니다.


```r
share = share %>%
  strsplit('/') %>%
  unlist() %>%
  .[1] %>%
  parse_number()

print(share)
```

```
## [1] 5969782550
```

1. `strsplit()` 함수를 통해 /를 기준으로 데이터를 나눕니다. 해당 결과는 리스트 형태로 저장됩니다.
2. `unlist()` 함수를 통해 리스트를 벡터 형태로 변환합니다.
3. `.[1]`.[1]을 통해 보통주 발행주식수인 첫 번째 데이터를 선택합니다.
4. `parse_number()` 함수를 통해 문자형 데이터를 숫자형으로 변환합니다.

재무 데이터, 현재 주가, 발행주식수를 이용해 가치지표를 계산해보겠습니다.


```r
data_value = price / (value_index * 100000000 / share)
names(data_value) = c('PER', 'PBR', 'PCR', 'PSR')
data_value[data_value < 0] = NA

print(data_value)
```

```
##   PER   PBR   PCR   PSR 
## 8.338 1.477 5.459 1.501
```

분자에는 현재 주가를 입력하며, 분모에는 재무 데이터를 보통주 발행주식수로 나눈 값을 입력합니다. 단, 주가는 원 단위, 재무 데이터는 억 원 단위이므로, 둘 사이에 단위를 동일하게 맞춰주기 위해 분모에 억을 곱합니다. 또한 가치지표가 음수인 경우는 NA로 변경해줍니다.

결과를 확인해보면 4가지 가치지표가 잘 계산되었습니다.^[분모에 사용되는 재무데이터의 구체적인 항목과 발행주식수를 계산하는 방법의 차이로 인해 여러 업체에서 제공하는 가치지표와 다소 차이가 발생할 수 있습니다.]


```r
write.csv(data_value, 'data/KOR_value/005930_value.csv')
```

data 폴더의 KOR_value 폴더 내에 티커_value.csv 이름으로 저장합니다.

### 전 종목 재무제표 및 가치지표 다운로드

위 코드에서 for loop 구문을 이용해 URL 중 6자리 티커에 해당하는 값만 변경해주면 모든 종목의 재무제표를 다운로드하고 이를 바탕으로 가치지표를 계산할 수 있습니다. 해당 코드는 다음과 같습니다.


```r
library(stringr)
library(httr)
library(rvest)
library(stringr)
library(readr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6,side = c('left'), pad = '0')

ifelse(dir.exists('data/KOR_fs'), FALSE,
       dir.create('data/KOR_fs'))
ifelse(dir.exists('data/KOR_value'), FALSE,
       dir.create('data/KOR_value'))

for(i in 1 : nrow(KOR_ticker) ) {
  
  data_fs = c()
  data_value = c()
  name = KOR_ticker$'종목코드'[i]
  
  # 오류 발생 시 이를 무시하고 다음 루프로 진행
  tryCatch({
    
    Sys.setlocale('LC_ALL', 'English')
    
    # url 생성
    url = paste0(
      'http://comp.fnguide.com/SVO2/ASP/'
      ,'SVD_Finance.asp?pGB=1&gicode=A',
      name)
    
    # 이 후 과정은 위와 동일함
    
    # 데이터 다운로드 후 테이블 추출
    data = GET(url) %>%
      read_html() %>%
      html_table()
    
    Sys.setlocale('LC_ALL', 'Korean')
    
    # 3개 재무제표를 하나로 합치기
    data_IS = data[[1]]
    data_BS = data[[3]]
    data_CF = data[[5]]
    
    data_IS = data_IS[, 1:(ncol(data_IS)-2)]
    data_fs = rbind(data_IS, data_BS, data_CF)
    
    # 데이터 클랜징
    data_fs[, 1] = gsub('계산에 참여한 계정 펼치기',
                        '', data_fs[, 1])
    data_fs = data_fs[!duplicated(data_fs[, 1]), ]
    
    rownames(data_fs) = NULL
    rownames(data_fs) = data_fs[, 1]
    data_fs[, 1] = NULL
    
    # 12월 재무제표만 선택
    data_fs =
      data_fs[, substr(colnames(data_fs), 6,7) == "12"]
    
    data_fs = sapply(data_fs, function(x) {
      str_replace_all(x, ',', '') %>%
        as.numeric()
    }) %>%
      data.frame(., row.names = rownames(data_fs))
    
    
    # 가치지표 분모부분
    value_type = c('지배주주순이익', 
                   '자본', 
                   '영업활동으로인한현금흐름', 
                   '매출액') 
    
    # 해당 재무데이터만 선택
    value_index = data_fs[match(value_type, rownames(data_fs)),
                          ncol(data_fs)]
    
    # Snapshot 페이지 불러오기
    url =
      paste0(
        'http://comp.fnguide.com/SVO2/ASP/SVD_Main.asp',
        '?pGB=1&gicode=A',name)
    data = GET(url)
    
    # 현재 주가 크롤링
    price = read_html(data) %>%
      html_node(xpath = '//*[@id="svdMainChartTxt11"]') %>%
      html_text() %>%
      parse_number()
    
    # 보통주 발행장주식수 크롤링
    share = read_html(data) %>%
      html_node(
        xpath =
        '//*[@id="svdMainGrid1"]/table/tbody/tr[7]/td[1]') %>%
      html_text() %>%
      strsplit('/') %>%
      unlist() %>%
      .[1] %>%
      parse_number()
    
    # 가치지표 계산
    data_value = price / (value_index * 100000000/ share)
    names(data_value) = c('PER', 'PBR', 'PCR', 'PSR')
    data_value[data_value < 0] = NA
    
  }, error = function(e) {
    
    # 오류 발생시 해당 종목명을 출력하고 다음 루프로 이동
    data_fs <<- NA
    data_value <<- NA
    warning(paste0("Error in Ticker: ", name))
  })
  
  # 다운로드 받은 파일을 생성한 각각의 폴더 내 csv 파일로 저장
  
  # 재무제표 저장
  write.csv(data_fs, paste0('data/KOR_fs/', name, '_fs.csv'))
  
  # 가치지표 저장
  write.csv(data_value, paste0('data/KOR_value/', name,
                               '_value.csv'))
  
  # 2초간 타임슬립 적용
  Sys.sleep(2)
}
```

전 종목 주가 데이터를 받는 과정과 동일하게 KOR_ticker.csv 파일을 불러온 후 for loop를 통해 i 값이 변함에 따라 티커를 변경해가며 모든 종목의 재무제표 및 가치지표를 다운로드합니다. `tryCatch()` 함수를 이용해 오류가 발생하면 NA로 이루어진 빈 데이터를 저장한 후 다음 루프로 넘어가게 됩니다. data/KOR_fs 폴더에는 전 종목의 재무제표 데이터가 저장되고, data/KOR_value 폴더에는 전 종목의 가치지표 데이터가 csv 형태로 저장됩니다.

## DART 데이터 수집하기

DART(Data Analysis, Retrieval and Transfer System)는 금융감독원 전자공시시스템으로써, 상장법인 등이 공시서류를 인터넷으로 제출하고, 투자자 등 이용자는 제출 즉시 인터넷을 통해 조회할 수 있도록 하는 종합적 기업공시 시스템입니다.

홈페이지에서도 각종 공시내역을 확인할 수 있지만, 해당 사이트에서 제공하는 API를 이용할 경우 더욱 쉽게 공시 보고서 목록을 크롤링할 수 있습니다.

### 인증키 발급받기

먼저 http://dart.fss.or.kr 에 접속하여 우측 상단의 [오픈API] 메뉴를 누른 후, 좌측의 [인증키 신청/관리]를 통해 회원가입을 합니다.


<div class="figure" style="text-align: center">
<img src="images/dart_api.png" alt="오픈API 회원가입" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-30)오픈API 회원가입</p>
</div>

[계정신청]을 통해 계정을 만들고 이메일을 통해 이용자 등록을 한 후 로그인을 합니다. 그 후 [개인용 오픈API 인증키 신청]을 통해 API KEY를 발급받습니다.

<div class="figure" style="text-align: center">
<img src="images/dart_api_private.png" alt="API KEY 발급" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-31)API KEY 발급</p>
</div>

<div class="figure" style="text-align: center">
<img src="images/dart_api_private2.png" alt="API Key 발급완료" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-32)API Key 발급완료</p>
</div>

개인용 API의 경우 하루에 총 10,000회 데이터를 요청할 수 있으며, 일분마다 한번씩 요청해도 될 정도로 넉넉한 횟수입니다.

발급받은 인증키를 관리하기 위해 `.Renviron` 파일을 이용합니다. `file.edit("~/.Renviron")` 명령어를 통해 `.Renviron` 파일을 연 후, 다음과 같이 인증키를 입력합니다.

```
dart_api_key = 'YOUR API KEY'
```
**`.Renviron` 파일의 적용을 위해 R을 재시작**한 후, 다음 코드를 통해 인증키를 불러옵니다.


```r
dart_api = Sys.getenv("dart_api_key")
```

### 오늘의 공시 확인하기

홈페이지 좌측의 [오픈API 개발가이드] 메뉴를 통해 원하는 항목의 요청 주소를 알 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/dart_api_sample.png" alt="검색API 샘플" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-34)검색API 샘플</p>
</div>

이 중 auth= 뒤의 xxx는 위에서 발급 받은 인증키를 의미합니다. 당일 접수 100건에 해당하는 주소는 다음과 같습니다.

```
http://dart.fss.or.kr/api/search.json?auth=xxx&page_set=100
```

해당 주소에 해당하는 데이터를 불러오도록 하겠습니다. 위 주소는 xml 형태로 이루어져 있지만, 데이터 가공의 편이성을 위해 json 형태로 데이터를 불러오도록 합니다.


```r
library(jsonlite)

url = paste0('http://dart.fss.or.kr/api/search.json?auth=',dart_api,'&page_set=100')
dart_discl = fromJSON(url)

str(dart_discl)
```

```
## List of 7
##  $ err_code   : chr "000"
##  $ err_msg    : chr "정상"
##  $ page_no    : int 1
##  $ page_set   : int 100
##  $ total_count: int 411
##  $ total_page : int 5
##  $ list       :'data.frame':	100 obs. of  8 variables:
##   ..$ crp_cls: chr [1:100] "K" "N" "N" "K" ...
##   ..$ crp_nm : chr [1:100] "라이트론" "휴벡셀" "휴벡셀" "한류AI센터" ...
##   ..$ crp_cd : chr [1:100] "069540" "212310" "212310" "222810" ...
##   ..$ rpt_nm : chr [1:100] "횡령ㆍ배임혐의진행사항" "감자완료" "감자완료" "타법인주식및출자증권처분결정" ...
##   ..$ rcp_no : chr [1:100] "20200120900678" "20200120600674" "20200120600673" "20200120900654" ...
##   ..$ flr_nm : chr [1:100] "라이트론" "휴벡셀" "휴벡셀" "한류AI센터" ...
##   ..$ rcp_dt : chr [1:100] "20200120" "20200120" "20200120" "20200120" ...
##   ..$ rmk    : chr [1:100] "코" "넥" "넥" "코" ...
```

```r
dart_discl_data = dart_discl$list
head(dart_discl_data)
```

```
##   crp_cls     crp_nm crp_cd
## 1       K   라이트론 069540
## 2       N     휴벡셀 212310
## 3       N     휴벡셀 212310
## 4       K 한류AI센터 222810
## 5       K       코렌 078650
## 6       Y     비티원 101140
##                                                     rpt_nm         rcp_no
## 1                                   횡령ㆍ배임혐의진행사항 20200120900678
## 2                                                 감자완료 20200120600674
## 3                                                 감자완료 20200120600673
## 4                             타법인주식및출자증권처분결정 20200120900654
## 5 [기재정정]매출액또는손익구조30%(대규모법인은15%)이상변동 20200120900653
## 6                                         주주총회소집결의 20200120800652
##       flr_nm   rcp_dt rmk
## 1   라이트론 20200120  코
## 2     휴벡셀 20200120  넥
## 3     휴벡셀 20200120  넥
## 4 한류AI센터 20200120  코
## 5       코렌 20200120  코
## 6     비티원 20200120  유
```

1. 인증키를 이용하여 url을 생성합니다.
2. `fromJSON()` 함수를 이용해 JSON 데이터를 불러옵니다.
3. 공시 데이터가 존재하는 \$list 부분만 추출하여 dart_discl_data에 저장합니다.

http://dart.fss.or.kr/dsaf001/main.do?rcpNo= 뒤에 공시번호인 rcp_no를 입력할 경우 이에 해당하는 페이지로 이동할 수 있습니다.


```r
discl_url = paste0('http://dart.fss.or.kr/dsaf001/main.do?rcpNo=', dart_discl_data$rcp_no)
head(discl_url)
```

```
## [1] "http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20200120900678"
## [2] "http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20200120600674"
## [3] "http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20200120600673"
## [4] "http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20200120900654"
## [5] "http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20200120900653"
## [6] "http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20200120800652"
```

첫번째 url에 접속하여 해당 공시내역을 확인해봅니다.



<div class="figure" style="text-align: center">
<img src="images/dart_api_web.png" alt="공시내역 확인" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-38)공시내역 확인</p>
</div>

#### 관심종목 공시 확인하기

특정 회사의 당일 접수 10건에 해당하는 url은 다음과 같습니다.

```
http://dart.fss.or.kr/api/search.json?auth=xxx&crp_cd=xxx
```

이를 이용해 관심종목들의 오늘자 공시 읽어오도록 합니다. 먼저, 시가총액 상위 30 종목을 관심종목으로 설정합니다.


```r
library(stringr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')

eq_list = KOR_ticker[1:30, '종목코드']
print(eq_list)
```

```
##  [1] "005930" "000660" "035420" "207940" "005380" "012330" "051910"
##  [8] "068270" "051900" "005490" "028260" "105560" "055550" "017670"
## [15] "006400" "015760" "034730" "000270" "018260" "032830" "035720"
## [22] "090430" "036570" "033780" "096770" "003550" "066570" "000810"
## [29] "086790" "009150"
```

1. 티커가 저장된 csv 파일을 불러온 후 티커를 6자리로 맞춰줍니다.
2. 상위 30 종목의 코드에 해당하는 열만 선택하여 eq_list에 저장합니다.

해당 종목들의 금일 공시를 불러오는 코드는 다음과 같습니다.


```r
rcp_no_name = c()
rcp_no_list = c()

for (i in eq_list) {
  
  eq_url = paste0('http://dart.fss.or.kr/api/search.json?auth=', dart_api, '&crp_cd=', i)
  
  eq_discl =  fromJSON(eq_url) 
  eq_discl = eq_discl$list
  
  eq_title = paste(eq_discl$crp_nm, eq_discl$rpt_nm)
  eq_rcp_no = eq_discl$rcp_no
  
  rcp_no_name = append(rcp_no_name, eq_title)
  rcp_no_list = append(rcp_no_list, eq_rcp_no)
  
  Sys.sleep(1)
  
}

my_discl = data.frame(rcp_no_name, rcp_no_list)
print(my_discl)
```

1. `c()`를 통해 종목명과 공시 번호가 들어갈 빈 공간을 만들어 줍니다.
2. for loop 구문 내에서 인증키와 주식 티커를 이용해 해당 종목의 금일 공시 10건에 해당하는 url을 만들어 줍니다.
3. `fromJSON()` 함수를 이용해 JSON 데이터를 불러옵니다.
4. 공시 데이터가 존재하는 \$list 부분만 추출하여 eq_discl 저장합니다.
5. 종목명인 crp_nm와 공시제목인 rpt_nm을 결합하여 제목을 만든 후 eq_title에 저장합니다.
6. 공시번호에 해당하는 rcp_no 부분을 eq_rcp_no에 저장합니다.
7. `append()` 함수를 이용해 제목과 공시번호를 쌓아줍니다.
8. url과 공시번호를 결합하여 공시내역이 있는 url을 생성합니다.
9. 제목과 url 벡터를 데이터프레임 형태로 결합합니다.

my_discl에는 관심종목의 금일 공시명과 해당 url이 저장되며, 공시가 없을 경우 아무런 내용도 출력되지 않습니다.


### 사업보고서의 재무제표 다운로드

회사의 사업보고서 10건에 해당하는 주소는 다음과 같습니다.

http://dart.fss.or.kr/api/search.json?auth=xxx&crp_cd=xxx&start_dt=19990101&bsn_tp=A001

auth는 인증키를, crp_cd는 티커를, start_dt는 시작시점을, bsn_tp는 공시종류에 해당하며 A001은 연간 사업보고서를 의미합니다. 삼성전자(005930)의 사업보고서 10건에 해당하는 API를 요청해보도록 하겠습니다.


```r
url = paste0('http://dart.fss.or.kr/api/search.json?auth=',dart_api,'&crp_cd=005930&start_dt=19990101&bsn_tp=A001')

dart_data = fromJSON(url)
print(dart_data)
```

```
## $err_code
## [1] "000"
## 
## $err_msg
## [1] "정상"
## 
## $page_no
## [1] 1
## 
## $page_set
## [1] 10
## 
## $total_count
## [1] 23
## 
## $total_page
## [1] 3
## 
## $list
##    crp_cls   crp_nm crp_cd                         rpt_nm         rcp_no
## 1        Y 삼성전자 005930           사업보고서 (2018.12) 20190401004781
## 2        Y 삼성전자 005930           사업보고서 (2017.12) 20180402005019
## 3        Y 삼성전자 005930           사업보고서 (2016.12) 20170331004518
## 4        Y 삼성전자 005930           사업보고서 (2015.12) 20160330003536
## 5        Y 삼성전자 005930           사업보고서 (2014.12) 20150331002915
## 6        Y 삼성전자 005930           사업보고서 (2013.12) 20140331002427
## 7        Y 삼성전자 005930           사업보고서 (2012.12) 20130401003031
## 8        Y 삼성전자 005930 [첨부추가]사업보고서 (2011.12) 20120330002110
## 9        Y 삼성전자 005930 [첨부추가]사업보고서 (2010.12) 20110331002193
## 10       Y 삼성전자 005930 [첨부추가]사업보고서 (2009.12) 20100331001680
##      flr_nm   rcp_dt rmk
## 1  삼성전자 20190401  연
## 2  삼성전자 20180402  연
## 3  삼성전자 20170331  연
## 4  삼성전자 20160330  연
## 5  삼성전자 20150331  연
## 6  삼성전자 20140331  연
## 7  삼성전자 20130401  연
## 8  삼성전자 20120330  연
## 9  삼성전자 20110331  연
## 10 삼성전자 20100331  연
```

다시 DART 홈페이지에 접속하여 데이터 추출에 필요한 값들을 찾도록 합니다.

<div class="figure" style="text-align: center">
<img src="images/dart_api_search.png" alt="사업보고서 검색하기" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-42)사업보고서 검색하기</p>
</div>

회사명은 삼성전자, 기간은 전체, 정기공시의 사업보고서 항목을 체크한 후 검색을 누르면 연말 사업보고서가 검색됩니다. 이 중 최근 보고서를 클릭합니다.

<div class="figure" style="text-align: center">
<img src="images/dart_api_report.png" alt="사업보고서 확인하기" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-43)사업보고서 확인하기</p>
</div>

url의 rcpNO 부분은 API 요청을 통해 발급받은 rcp_no 값과 동일하며, 해당 부분을 변경하여 매해 사업보고서에 해당하는 url을 생성할 수 있습니다.

다음으로 재무제표가 첨부된 엑셀 시트의 문서번호를 파악해야 합니다. 

<div class="figure" style="text-align: center">
<img src="images/dart_api_dcm.png" alt="문서번호 검색하기" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-44)문서번호 검색하기</p>
</div>

상단의 [다운로드] 버튼을 우클릭 후 검사를 눌러 해당 부분의 HTML을 파악합니다. \<img> 태그 위 \<a href> 태그 내의 openPdfDownload 괄호안에는 '20190401004781'과 '6616741'라는 숫자가 있습니다. 이 중 앞의 숫자는 우리가 이미 구한 공시번호 즉 rcp_no에 해당하는 값이며, 뒤의 숫자는 문서번호에 해당하는 dcm_no에 해당하는 값이며, 이를 크롤링할 필요가 있습니다.

\<a href> 태그의 Xpath는 다음과 같으며, 이를 이용하여 dcm_no에 해당하는 값을 크롤링 하도록 하겠습니다.

```
//*[@id="north"]/div[2]/ul/li[1]/a
```


```r
library(httr)
library(rvest)

report_url =
  'http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20190401004781'

report_data = GET(report_url) %>%
  read_html() %>%
  html_node(xpath = '//*[@id="north"]/div[2]/ul/li[1]/a')

print(report_data)
```

```
## {xml_node}
## <a href="#download" onclick="openPdfDownload('20190401004781', '6616741'); return false;">
## [1] <img src="/images/common/viewer_down.gif" style="cursor:pointer;" al ...
```

1. report_url에 사업보고서의 url을 입력합니다.
2. `GET()` 함수와 `read_html()` 함수를 통해 HTML 내용을 읽어옵니다.
3. `html_node()` 함수 내에 위에서 구한 Xpath를 입력해서 해당 지점의 데이터를 추출합니다.

\<a> 태그의 onclick 속성 내 우리가 원하는 dcm_no 값이 위치하고 있으므로, 추가적으로 해당 데이터만을 추출하도록 하겠습니다.


```r
library(stringr)

dcm_no = report_data %>%
  html_attr('onclick') %>%
  str_match_all('[0-9]+') %>%
  unlist() %>%
  tail(1)

print(dcm_no)
```

```
## [1] "6616741"
```

1. `html_attr()` 함수를 이용해 onclick 속성에 해당하는 값을 읽어옵니다.
2. `str_match_all()` 함수 내에 정규표현식 [0-9]+ 을 이용하여 숫자에 해당하는 값들만 추출합니다.
3. rcp_no와 dcm_no가 list 형식으로 데이터가 추출되므로 `unlist()`를 통해 벡터 형태로 변경 후 `tail()` 함수를 통해 마지막 데이터 즉 dcm_no만 추출합니다.

이제 rcp_no와 dcm_no를 이용하여 어떻게 엑셀 파일을 다운로드 받는지 확인하도록 합니다.

<div class="figure" style="text-align: center">
<img src="images/dart_api_excel.png" alt="엑셀 다운로드 과정 확인하기" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-47)엑셀 다운로드 과정 확인하기</p>
</div>

상단의 [다운로드] 버튼을 누르면 각종 첨부파일을 받을 수 있는 팝업창이 열립니다. 개발자도구 화면을 연 상태에서 [재무제표]에 해당하는 파일을 다운로드 받으면 해당 과정이 표시됩니다.

Request URL과 쿼리값을 살펴보면 http://dart.fss.or.kr/pdf/download/excel.do 주소에 rcp_no, dcm_no, lang 쿼리를 요청함이 확인됩니다. 이를 POST 형식의 코드로 나타내면 다음과 같습니다.


```r
excel_data = 
  POST('http://dart.fss.or.kr/pdf/download/excel.do',
       query = list(
         rcp_no = '20190401004781',
         dcm_no = dcm_no,
         lang = 'ko'
       ))

print(excel_data)
```

```
## Response [http://dart.fss.or.kr/pdf/download/excel.do?rcp_no=20190401004781&dcm_no=6616741&lang=ko]
##   Date: 2020-01-20 13:21
##   Status: 200
##   Content-Type: application/vnd.ms-excel
##   Size: 61.4 kB
## <BINARY BODY>
```

```
## NULL
```

Response 값을 확인해보면 Content-Type이 excel이며 BINARY 파일입니다. 마지막으로 해당 파일을 저장합니다.


```r
ifelse(dir.exists('data/dart'), FALSE, dir.create('data/dart'))

writeBin(content(excel_data, 'raw'), 'data/dart/005930_20190401004781.xls')
```

data 폴더 내에 dart 폴더를 생성한 후, `writeBin()` 함수를 이용해 바이너리 파일(엑셀 파일)을 저장합니다.

<div class="figure" style="text-align: center">
<img src="images/dart_api_excel_down.png" alt="엑셀 데이터 확인하기" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-50)엑셀 데이터 확인하기</p>
</div>

저장된 엑셀 파일을 확인해보면 재무제표 항목이 포함되어 있습니다. 이 중 연결 재무상태표 시트의 데이터만 불러오도록 하겠습니다.


```r
library(readxl)
dart_data = read_xls('data/dart/005930_20190401004781.xls', sheet = '연결 재무상태표')

head(dart_data)
```

```
## # A tibble: 6 x 4
##   `연결 재무상태표`        ...2     ...3     ...4    
##   <chr>                    <chr>    <chr>    <chr>   
## 1 제 50 기 2018.12.31 현재 <NA>     <NA>     <NA>    
## 2 제 49 기 2017.12.31 현재 <NA>     <NA>     <NA>    
## 3 제 48 기 2016.12.31 현재 <NA>     <NA>     <NA>    
## 4 (단위 : 백만원)          <NA>     <NA>     <NA>    
## 5 <NA>                     제 50 기 제 49 기 제 48 기
## 6 자산                     <NA>     <NA>     <NA>
```

#### 10년치 재무제표 다운로드

위 과정을 응용하여 원하는 종목의 10년치 재무제표 데이터에 해당하는 엑셀 파일을 다운로드 받는 방법은 다음과 같습니다.


```r
library(jsonlite)

ticker = '005930'

url = paste0('http://dart.fss.or.kr/api/search.json?','auth=',dart_api,
             '&crp_cd=', ticker, '&start_dt=19990101&bsn_tp=A001')

dart_data = fromJSON(url)
dart_rcp_no = dart_data$list$rcp_no

for (i in dart_rcp_no) {
  
  report_url =
    paste0('http://dart.fss.or.kr/dsaf001/main.do?rcpNo=', i)
  
  report_data = GET(report_url) %>%
    read_html() %>%
    html_node(xpath = '//*[@id="north"]/div[2]/ul/li[1]/a')
  
  dcm_no = report_data %>%
    html_attr('onclick') %>%
    str_match_all('[0-9]+') %>%
    unlist() %>%
    tail(1)
  
  excel_data = 
    POST('http://dart.fss.or.kr/pdf/download/excel.do',
         query = list(
           rcp_no = i,
           dcm_no = dcm_no,
           lang = 'ko'
         ))
  
  ifelse(dir.exists('data/dart'), FALSE, dir.create('data/dart'))
  
  writeBin(content(excel_data, 'raw'),
           paste0('data/dart/',ticker,'_',i,'.xls'))
  
  Sys.sleep(1)
  
}
```

1. ticker에 원하는 종목의 티커를 입력합니다.
2. 인증키와 티커를 이용해 API를 요청할 url을 생성합니다.
3. `fromJSON()` 함수를 이용해 JSON 데이터를 불러옵니다.
4. 데이터 중 공시번호에 해당하는 rcp_no만 선택하여 저장합니다.
5. for loop 구문을 이용하여 모든 공시번호에 해당하는 작업을 반복합니다.
6. 공시번호를 이용해 사업보고의 url을 생성한 후 report_url에 저장합니다.
7. Xpath를 이용해 공시번호와 문서번호가 있는 데이터를 크롤링합니다.
8. `str_match_all()` 함수 내 정규표현식을 이용하여 문서번호에 해당하는 dcm_no를 추출합니다.
9. `POST()` 함수 내에 rcp_no와 dcm_no를 쿼리로 이용하여 엑셀 파일을 요청합니다.
10. `writeBin()` 함수를 이용하여 data/dart 폴더 내에 티커_공시번호(rcp_no).xls로 엑셀 파일을 저장합니다.

<div class="figure" style="text-align: center">
<img src="images/dart_api_excel_list.png" alt="엑셀 리스트 확인하기" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-53)엑셀 리스트 확인하기</p>
</div>

해당 폴더를 확인해보면 원하는 종목의 10년치 재무제표가 있는 엑셀 파일이 다운로드 되며, 사업보고서에 엑셀 파일이 존재하지 않는 경우 용량이 0KB인 파일이 저장됩니다. (가끔 재무제표가 PDF 형식으로 업로드 되는 경우가 있습니다.)

