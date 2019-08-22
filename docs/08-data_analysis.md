
# 데이터 분석 및 시각화하기

데이터 수집 및 정리가 끝났다면, 내가 가지고 있는 데이터가 어떠한 특성을 가지고 있는지에 대한 분석 및 시각화 과정, 즉 탐색적 데이터 분석(Exploratory Data Analysis)을 할 필요가 있습니다. 이 과정을 통해 데이터를 더 잘 이해할 수 있으며, 극단치나 결측치 등 데이터가 가지고 있는 잠재적인 문제를 발견하고 이를 어떻게 처리할지 고민할 수 있습니다.

이 CHAPTER에서는 dplyr 패키지를 이용한 데이터 분석과 ggplot2 패키지를 이용한 데이터 시각화에 대해 알아보겠습니다.

## 종목정보 데이터 분석 

먼저 거래소를 통해 수집한 산업별 현황과 개별지표를 정리한 파일, WICS 기준 섹터 지표를 정리한 파일을 통해 국내 상장종목의 데이터를 분석해보겠습니다.


```r
library(stringr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1,
                      stringsAsFactors = FALSE)
KOR_sector = read.csv('data/KOR_sector.csv', row.names = 1,
                      stringsAsFactors = FALSE)

KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6,'left', 0)
KOR_sector$'CMP_CD' =
  str_pad(KOR_sector$'CMP_CD', 6, 'left', 0)
```

각 파일을 불러온 후 티커에 해당하는 종목코드와 CMP_CD 열을 6자리 숫자로 만들어줍니다.

이제 dplyr 패키지의 여러 함수들을 이용해 데이터를 분석해보겠습니다. 해당 패키지는 데이터 처리에 특화된 패키지이며, C++로 작성되어 매우 빠른 처리 속도를 자랑합니다. 또한 문법이 SQL과 매우 비슷해 함수의 내용을 직관적으로 이해할 수 있습니다.

### `*_join`: 데이터 합치기

두 테이블을 하나로 합치기 위해 `*_join()` 함수를 이용합니다. 해당 함수는 기존에 살펴본 `merge()` 함수와 동일하며, 합치는 방법은 그림 \@ref(fig:joinimg)과 표 \@ref(tab:joindesc)과 같이 크게 네가지 종류가 있습니다.

<div class="figure" style="text-align: center">
<img src="images/data_analysis_join.png" alt="*_ join() 함수의 종류" width="70%" />
<p class="caption">(\#fig:joinimg)*_ join() 함수의 종류</p>
</div>


Table: (\#tab:joindesc)join 함수의 종류

     함수          내용    
--------------  -----------
 inner_join()     교집합   
 full_join()      합집합   
 left_join()     좌측 기준 
 right_join()    우측 기준 

이 중 거래소 티커 기준으로 데이터를 맞추기 위해 `left_join()` 함수를 사용해 두 데이터를 합치겠습니다.


```r
library(dplyr)

data_market = left_join(KOR_ticker, KOR_sector,
                         by = c('종목코드' = 'CMP_CD',
                                '종목명' = 'CMP_KOR'))

head(data_market)
```

```
##   종목코드     종목명 시장구분 산업분류 현재가.종가. 전일대비 시가총액.원.
## 1   005930   삼성전자   코스피 전기전자        45400     -850    2.710e+14
## 2   000660 SK하이닉스   코스피 전기전자        69100    -2300    5.030e+13
## 3   005380     현대차   코스피 운수장비       136000    -1000    2.906e+13
## 4   068270   셀트리온   코스피   의약품       206000     1000    2.644e+13
## 5   051910     LG화학   코스피     화학       355500     7000    2.510e+13
## 6   012330 현대모비스   코스피 운수장비       229500    -2500    2.187e+13
##         일자 관리여부   종가    EPS   PER     BPS   PBR 주당배당금
## 1 2019-07-03        -  45400  6,461  7.03  35,342  1.28       1416
## 2 2019-07-03        -  69100 22,255   3.1  64,348  1.07       1500
## 3 2019-07-03        - 136000  5,632 24.15 245,447  0.55       4000
## 4 2019-07-03        - 206000  2,063 99.85  19,766 10.42          0
## 5 2019-07-03        - 355500 19,217  18.5 218,227  1.63       6000
## 6 2019-07-03        - 229500 19,944 11.51 314,650  0.73       4000
##   배당수익률 게시물..일련번호 총카운트 IDX_CD          IDX_NM_KOR
## 1       3.12             2165       NA    G45             WICS IT
## 2       2.17             1885       NA    G45             WICS IT
## 3       2.94             2159       NA    G25 WICS 경기관련소비재
## 4       0.00             2049       NA    G35       WICS 건강관리
## 5       1.69             2041       NA    G15           WICS 소재
## 6       1.74             2169       NA    G25 WICS 경기관련소비재
##   ALL_MKT_VAL   MKT_VAL   WGT S_WGT CAL_WGT SEC_CD     SEC_NM_KOR SEQ
## 1   376270891 208452867 55.40 55.40       1    G45             IT   1
## 2   376270891  35232402  9.36 64.76       1    G45             IT   2
## 3   141374708  20042076 14.18 14.18       1    G25 경기관련소비재   1
## 4    81157991  16895164 20.82 20.82       1    G35       건강관리   1
## 5    71815100  15165000 21.12 43.84       1    G15           소재   2
## 6   141374708  14257881 10.09 24.26       1    G25 경기관련소비재   2
##   TOP60 APT_SHR_CNT
## 1     2  4716128215
## 2     2   538721750
## 3    12   143157685
## 4    21    85980477
## 5     6    45885023
## 6    12    64808552
```

`left_join()` 함수를 이용해 KOR_ticker와 KOR_sector 데이터를 합쳐줍니다. by 인자는 데이터를 합치는 기준점을 의미하며, x 데이터(KOR_ticker)의 종목코드와 y 데이터(KOR_sector)의 CMP_CD는 같음을, x 데이터의 종목명과 y 데이터의 CMP_KOR는 같음을 정의합니다.

### `glimpse()`: 데이터 구조 확인하기


```r
glimpse(data_market)
```

```
## Observations: 2,041
## Variables: 30
## $ 종목코드         <chr> "005930", "000660", "005...
## $ 종목명           <chr> "삼성전자", "SK하이닉스", "현대차"...
## $ 시장구분         <chr> "코스피", "코스피", "코스피", "코스...
## $ 산업분류         <chr> "전기전자", "전기전자", "운수장비", ...
## $ 현재가.종가.     <int> 45400, 69100, 136000, 206...
## $ 전일대비         <int> -850, -2300, -1000, 1000...
## $ 시가총액.원.     <dbl> 2.710e+14, 5.030e+13, 2.9...
## $ 일자             <chr> "2019-07-03", "2019-07...
## $ 관리여부         <chr> "-", "-", "-", "-", "-",...
## $ 종가             <int> 45400, 69100, 136000, ...
## $ EPS              <chr> "6,461", "22,255", "...
## $ PER              <chr> "7.03", "3.1", "24.1...
## $ BPS              <chr> "35,342", "64,348", ...
## $ PBR              <chr> "1.28", "1.07", "0.5...
## $ 주당배당금       <int> 1416, 1500, 4000, 0, 6000...
## $ 배당수익률       <dbl> 3.12, 2.17, 2.94, 0.00, 1...
## $ 게시물..일련번호 <int> 2165, 1885, 2159, 2049, 204...
## $ 총카운트         <int> NA, NA, NA, NA, NA, NA, ...
## $ IDX_CD           <chr> "G45", "G45", "G25",...
## $ IDX_NM_KOR       <chr> "WICS IT", "WICS IT"...
## $ ALL_MKT_VAL      <int> 376270891, 376270891...
## $ MKT_VAL          <int> 208452867, 35232402,...
## $ WGT              <dbl> 55.40, 9.36, 14.18, ...
## $ S_WGT            <dbl> 55.40, 64.76, 14.18,...
## $ CAL_WGT          <int> 1, 1, 1, 1, 1, 1, 1,...
## $ SEC_CD           <chr> "G45", "G45", "G25",...
## $ SEC_NM_KOR       <chr> "IT", "IT", "경기관련소비재...
## $ SEQ              <int> 1, 2, 1, 1, 2, 2, 1,...
## $ TOP60            <int> 2, 2, 12, 21, 6, 12,...
## $ APT_SHR_CNT      <dbl> 4716128215, 53872175...
```

`glimpse()` 함수는 데이터 내용, 구조, 형식을 확인하는 함수입니다. 기본 함수인 `str()`과 그 역할은 비슷하지만, tidy 형태로 결과물이 훨씬 깔끔하게 출력됩니다. 총 관측값 및 열의 개수, 각 열의 이름과 데이터 형식, 앞부분 데이터를 확인할 수 있습니다.

### `rename()`: 열 이름 바꾸기


```r
head(names(data_market), 10)
```

```
##  [1] "종목코드"     "종목명"       "시장구분"     "산업분류"    
##  [5] "현재가.종가." "전일대비"     "시가총액.원." "일자"        
##  [9] "관리여부"     "종가"
```

```r
data_market = data_market %>%
  rename(`시가총액` = `시가총액.원.`)

head(names(data_market), 10)
```

```
##  [1] "종목코드"     "종목명"       "시장구분"     "산업분류"    
##  [5] "현재가.종가." "전일대비"     "시가총액"     "일자"        
##  [9] "관리여부"     "종가"
```

`rename()` 함수는 열 이름을 바꾸는 함수로서, `rename(tbl, new_name, old_name)` 형태로 입력합니다. 위의 경우 시가총액.원. 열 이름이 시가총액으로 변경되었습니다.

### distinct(): 고유한 값 확인


```r
data_market %>%
  distinct(SEC_NM_KOR) %>% c() 
```

```
## $SEC_NM_KOR
##  [1] "IT"                 "경기관련소비재"     "건강관리"          
##  [4] "소재"               "금융"               "커뮤니케이션서비스"
##  [7] "산업재"             "유틸리티"           "에너지"            
## [10] "필수소비재"         NA
```

`distinct()` 함수는 고유한 값을 반환하며, 기본 함수 중 `unique()`와 동일한 기능을 합니다. 데이터의 섹터 정보를 확인해보면, WICS 기준 10개 섹터 및 섹터 정보가 없는 종목인 NA 값이 있습니다.

### `select()`: 원하는 열만 선택


```r
data_market %>%
  select(`종목명`) %>% head()
```

```
##       종목명
## 1   삼성전자
## 2 SK하이닉스
## 3     현대차
## 4   셀트리온
## 5     LG화학
## 6 현대모비스
```

```r
data_market %>%
  select(`종목명`, `PBR`, `SEC_NM_KOR`) %>% head()
```

```
##       종목명   PBR     SEC_NM_KOR
## 1   삼성전자  1.28             IT
## 2 SK하이닉스  1.07             IT
## 3     현대차  0.55 경기관련소비재
## 4   셀트리온 10.42       건강관리
## 5     LG화학  1.63           소재
## 6 현대모비스  0.73 경기관련소비재
```

`select()` 함수는 원하는 열을 선택해주는 함수이며, 원하는 열 이름을 입력하면 됩니다. 하나의 열뿐만 아니라 다수의 열을 입력하면 해당 열들이 선택됩니다.


```r
data_market %>%
  select(starts_with('시')) %>% head()
```

```
##   시장구분  시가총액
## 1   코스피 2.710e+14
## 2   코스피 5.030e+13
## 3   코스피 2.906e+13
## 4   코스피 2.644e+13
## 5   코스피 2.510e+13
## 6   코스피 2.187e+13
```

```r
data_market %>%
  select(ends_with('R')) %>% head()
```

```
##     PER   PBR          IDX_NM_KOR     SEC_NM_KOR
## 1  7.03  1.28             WICS IT             IT
## 2   3.1  1.07             WICS IT             IT
## 3 24.15  0.55 WICS 경기관련소비재 경기관련소비재
## 4 99.85 10.42       WICS 건강관리       건강관리
## 5  18.5  1.63           WICS 소재           소재
## 6 11.51  0.73 WICS 경기관련소비재 경기관련소비재
```

```r
data_market %>%
  select(contains('가')) %>% head()
```

```
##   현재가.종가.  시가총액   종가
## 1        45400 2.710e+14  45400
## 2        69100 5.030e+13  69100
## 3       136000 2.906e+13 136000
## 4       206000 2.644e+13 206000
## 5       355500 2.510e+13 355500
## 6       229500 2.187e+13 229500
```

해당 함수는 다양한 응용 기능도 제공합니다. `starts_with()`는 특정 문자로 시작하는 열들을 선택하고, `ends_with()`는 특정 문자로 끝나는 열들을 선택하며, `contains()`는 특정 문자가 포함되는 열들을 선택합니다.

### `mutate()`: 열 생성 및 데이터 변형


```r
data_market = data_market %>%
  mutate(`PBR` = as.numeric(PBR),
         `PER` = as.numeric(PER),
         `ROE` = PBR / PER,
         `ROE` = round(ROE, 4),
         `size` = ifelse(`시가총액` >=
                           median(`시가총액`, na.rm = TRUE),
                                        'big', 'small')
  )

data_market %>%
  select(`종목명`, `ROE`, `size`) %>% head()
```

```
##       종목명    ROE size
## 1   삼성전자 0.1821  big
## 2 SK하이닉스 0.3452  big
## 3     현대차 0.0228  big
## 4   셀트리온 0.1044  big
## 5     LG화학 0.0881  big
## 6 현대모비스 0.0634  big
```

`mutate()` 함수는 원하는 형태로 열을 생성하거나 변형하는 함수입니다. 위 예제에 서는 먼저 PBR과 PER 열을 `as.numeric()` 함수를 통해 숫자형으로 변경한 후 PBR을 PER로 나눈 값을 ROE 열에 생성합니다. 그 후 `round()` 함수를 통해 ROE 값을 반올림하며, `ifelse()` 함수를 통해 시가총액의 중앙값보다 큰 기업은 big, 아닐 경우 small임을 size 열에 저장합니다.

이 외에도 `mutate_*()` 계열 함수에는 `mutate_all()`, `mutate_if()`, `mutate_at()` 처럼 각 상황에 맞게 쓸 수 있는 다양한 함수들이 있습니다.

### `filter()`: 조건을 충족하는 행 선택


```r
data_market %>%
  select(`종목명`, `PBR`) %>%
  filter(`PBR` < 1) %>% head()
```

```
##       종목명  PBR
## 1     현대차 0.55
## 2 현대모비스 0.73
## 3      POSCO 0.49
## 4   신한지주 0.59
## 5   SK텔레콤 0.93
## 6     KB금융 0.53
```

```r
data_market %>%
  select(`종목명`, `PBR`, `PER`, `ROE`) %>%
  filter(PBR < 1 & PER < 20 & ROE > 0.1 ) %>% head()
```

```
##       종목명  PBR  PER    ROE
## 1   SK텔레콤 0.93 5.85 0.1590
## 2         SK 0.97 5.66 0.1714
## 3         LG 0.74 7.19 0.1029
## 4 롯데케미칼 0.72 5.83 0.1235
## 5         GS 0.56 5.28 0.1061
## 6   대림산업 0.80 6.69 0.1196
```

`filter()` 함수는 조건을 충족하는 부분의 데이터를 반환하는 함수입니다. 첫 번째 예제와 같이 PBR이 1 미만인 단일 조건을 입력할 수도 있으며, 두 번째 예제와 같이 PBR 1 미만, PER 20 미만, ROE 0.1 초과 등 복수 조건을 입력할 수도 있습니다.

### `summarize()`: 요약 통곗값 계산


```r
data_market %>%
  summarize(PBR_max = max(PBR, na.rm = TRUE),
            PBR_min = min(PBR, na.rm = TRUE))
```

```
##   PBR_max PBR_min
## 1    87.2    0.19
```

`summarize()` 혹은 `summarise()` 함수는 원하는 요약 통곗값을 계산합니다. PBR_max는 PBR 열에서 최댓값을, PBR_min은 최솟값을 계산해줍니다.

### `arrange()`: 데이터 정렬


```r
data_market %>%
  select(PBR) %>%
  arrange(PBR) %>%
  head(5)
```

```
##    PBR
## 1 0.19
## 2 0.21
## 3 0.21
## 4 0.23
## 5 0.23
```

```r
data_market %>%
  select(ROE) %>%
  arrange(desc(ROE)) %>%
  head(5)
```

```
##      ROE
## 1 1.3404
## 2 0.9589
## 3 0.7175
## 4 0.5761
## 5 0.5714
```

`arrange()` 함수는 선택한 열을 기준으로 데이터를 정렬해주며, 오름차순으로 정렬합니다. 내림차순으로 데이터를 정렬하려면 `arrange()` 내에 `desc()` 함수를 추가로 입력해주면 됩니다.

### `row_number()`: 순위 계산


```r
data_market %>%
  mutate(PBR_rank = row_number(PBR)) %>%
  select(`종목명`, PBR, PBR_rank) %>%
  arrange(PBR) %>%
  head(5)
```

```
##       종목명  PBR PBR_rank
## 1 세아홀딩스 0.19        1
## 2   한국제지 0.21        2
## 3   세원정공 0.21        3
## 4     휴스틸 0.23        4
## 5       전방 0.23        5
```

```r
data_market %>%
  mutate(PBR_rank = row_number(desc(ROE))) %>%
  select(`종목명`, ROE, PBR_rank) %>%
  arrange(desc(ROE)) %>%
  head(5)
```

```
##           종목명    ROE PBR_rank
## 1           효성 1.3404        1
## 2 바른손이앤에이 0.9589        2
## 3        THE E&M 0.7175        3
## 4         케이씨 0.5761        4
## 5     한일홀딩스 0.5714        5
```

`row_number()` 함수는 선택한 열의 순위를 구해줍니다. 기본적으로 오름차순으로 순위를 구하며, 내림차순으로 순위를 구하려면 `desc()` 함수를 추가해주면 됩니다.

순위를 구하는 함수는 이 외에도 `min_rank()`, `dense_rank()`, `percent_rank()`가 있습니다.

### `ntile()`: 분위수 계산


```r
data_market %>%
  mutate(PBR_tile = ntile(PBR, n = 5)) %>%
  select(PBR, PBR_tile) %>%
  head()
```

```
##     PBR PBR_tile
## 1  1.28        3
## 2  1.07        3
## 3  0.55        1
## 4 10.42        5
## 5  1.63        4
## 6  0.73        2
```

`ntile()` 함수는 분위수를 계산해주며, n 인자를 통해 몇 분위로 나눌지 선택할 수 있습니다. 해당 함수 역시 오름차순으로 분위수를 나눕니다.


### `group_by()`: 그룹별로 데이터를 묶기


```r
data_market %>%
  group_by(`SEC_NM_KOR`) %>%
  summarize(n())
```

```
## # A tibble: 11 x 2
##    SEC_NM_KOR         `n()`
##    <chr>              <int>
##  1 IT                   570
##  2 건강관리             226
##  3 경기관련소비재       391
##  4 금융                  77
##  5 산업재               330
##  6 소재                 216
##  7 에너지                22
##  8 유틸리티              19
##  9 커뮤니케이션서비스     7
## 10 필수소비재            96
## 11 <NA>                  87
```

`group_by()` 함수는 선택한 열 중 동일한 데이터를 기준으로 데이터를 묶어줍니다. 위 예제에서는 섹터를 나타내는 SEC_NM_KOR 기준으로 데이터를 묶었으며, `n()` 함수를 통해 해당 그룹 내 데이터의 개수를 구할 수 있습니다.


```r
data_market %>%
  group_by(`SEC_NM_KOR`) %>% 
  summarize(PBR_median = median(PBR, na.rm = TRUE)) %>%
  arrange(PBR_median)
```

```
## # A tibble: 11 x 2
##    SEC_NM_KOR         PBR_median
##    <chr>                   <dbl>
##  1 유틸리티                0.48 
##  2 금융                    0.715
##  3 소재                    0.76 
##  4 산업재                  0.925
##  5 커뮤니케이션서비스      0.93 
##  6 에너지                  0.955
##  7 필수소비재              0.96 
##  8 경기관련소비재          1.07 
##  9 IT                      1.51 
## 10 <NA>                    1.79 
## 11 건강관리                2.59
```

위 예제는 섹터를 기준으로 데이터를 묶은 후 `summarize()`를 통해 각 섹터에 속하는 종목의 PBR 중앙값을 구한 후 정렬했습니다.


```r
data_market %>%
  group_by(`시장구분`, `SEC_NM_KOR`) %>%
  summarize(PBR_median = median(PBR, na.rm = TRUE)) %>%
  arrange(PBR_median)
```

```
## # A tibble: 22 x 3
## # Groups:   시장구분 [2]
##    시장구분 SEC_NM_KOR         PBR_median
##    <chr>    <chr>                   <dbl>
##  1 코스피   유틸리티                0.46 
##  2 코스피   금융                    0.575
##  3 코스피   소재                    0.69 
##  4 코스피   경기관련소비재          0.79 
##  5 코스피   에너지                  0.8  
##  6 코스피   필수소비재              0.81 
##  7 코스피   산업재                  0.83 
##  8 코스피   커뮤니케이션서비스      0.92 
##  9 코스닥   유틸리티                0.93 
## 10 코스닥   에너지                  1.02 
## # ... with 12 more rows
```

위 예제는 시장과 섹터를 기준으로 데이터를 그룹화한 후 각 그룹별 PBR 중앙값을 구했습니다. 이처럼 그룹은 하나만이 아닌 원하는 만큼 나눌 수 있습니다.

## 종목정보 시각화

R에서 기본적으로 제공하는 `plot()` 함수를 이용해도 시각화가 충분히 가능합니다. 그러나 데이터 과학자들에게 가장 많이 사랑받는 패키지 중 하나인 ggplot2 패키지의 `ggplot()` 함수를 사용하면 그림을 훨씬 아름답게 표현할 수 있으며 다양한 기능들을 매우 쉽게 사용할 수도 있습니다.

`ggplot()` 함수는 플러스(+) 기호를 사용한다는 점과 문법이 다소 어색하다는 점 때문에 처음에 배우기가 쉽지는 않습니다. 그러나 해당 패키지의 근본이 되는 철학인 **The Grammar of Graphics**를 이해하고 조금만 연습해본다면, 충분히 손쉽게 사용이 가능합니다.

<div class="figure" style="text-align: center">
<img src="images/data_analysis_gg.png" alt="The Grammar of Graphics" width="50%" />
<p class="caption">(\#fig:unnamed-chunk-19)The Grammar of Graphics</p>
</div>

### `geom_point()`: 산점도 나타내기


```r
library(ggplot2)

ggplot(data_market, aes(x = ROE, y = PBR)) +
  geom_point()
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-20-1.png" width="70%" style="display: block; margin: auto;" />

1. `ggplot()` 함수 내에 사용될 데이터인 data_market을 입력합니다. aes 인자 내부에 x축은 ROE 열을 사용하고, y축은 PBR 열을 사용하도록 정의합니다.
2. `geom_point()` 함수를 통해 산점도 그래프를 그려줍니다. 원하는 그림이 그려지기는 했으나, ROE와 PBR에 극단치 데이터가 있어 둘 사이에 관계가 잘 보이지 않습니다.


```r
ggplot(data_market, aes(x = ROE, y = PBR)) +
  geom_point() +
  coord_cartesian(xlim = c(0, 0.30), ylim = c(0, 3))
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-21-1.png" width="70%" style="display: block; margin: auto;" />

이번에는 극단치 효과를 제거하기 위해 `coord_cartesian()` 함수 내에 xlim과 ylim, 즉 x축과 y축의 범위를 직접 지정해줍니다. 극단치가 제거되어 데이터를 한눈에 확인할 수 있습니다.


```r
ggplot(data_market, aes(x = ROE, y = PBR,
                        color = `시장구분`,
                        shape = `시장구분`)) +
  geom_point() +
  geom_smooth(method = 'lm') +
  coord_cartesian(xlim = c(0, 0.30), ylim = c(0, 3))
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-22-1.png" width="70%" style="display: block; margin: auto;" />

1. `ggplot()` 함수 내부 aes 인자에 color와 shape를 지정해주면, 해당 그룹별로 모양과 색이 나타납니다. 코스피와 코스닥 종목들에 해당하는 데이터의 색과 점 모양을 다르게 표시할 수 있습니다.
2. `geom_smooth()` 함수를 통해 평활선을 추가할 수도 있으며, 방법으로 lm(linear model)을 지정할 경우 선형회귀선을 그려주게 됩니다. 이 외에도 glm, gam, loess 등의 다양한 회귀선을 그려줄 수 있습니다.

### `geom_histogram()`: 히스토그램 나타내기


```r
ggplot(data_market, aes(x = PBR)) +
  geom_histogram(binwidth = 0.1) + 
  coord_cartesian(xlim = c(0, 10))
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-23-1.png" width="70%" style="display: block; margin: auto;" />

`geom_histogram()` 함수는 히스토그램을 나타내주며, binwidth 인자를 통해 막대의 너비를 선택해줄 수 있습니다. 국내 종목들의 PBR 데이터는 왼쪽에 쏠려 있고 오른쪽으로 꼬리가 긴 분포를 가지고 있습니다.


```r
ggplot(data_market, aes(x = PBR)) +
  geom_histogram(aes(y = ..density..),
                 binwidth = 0.1,
                 color = 'sky blue', fill = 'sky blue') + 
  coord_cartesian(xlim = c(0, 10)) +
  geom_density(color = 'red') +
  geom_vline(aes(xintercept = median(PBR, na.rm = TRUE)),
             color = 'blue') +
  geom_text(aes(label = median(PBR, na.rm = TRUE),
                x = median(PBR, na.rm = TRUE), y = 0.05),
             col = 'black', size = 6, hjust = -0.5)
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-24-1.png" width="70%" style="display: block; margin: auto;" />

PBR 히스토그램을 좀 더 자세하게 나타내보겠습니다.

1. `geom_histogram()` 함수 내에 aes(y = ..density..)를 추가해 밀도함수로 바꿉니다.
2. `geom_density()` 함수를 추가해 밀도곡선을 그려줍니다.
3. `geom_vline()` 함수는 세로선을 그려주며, xintercept 즉 x축으로 PBR의 중앙값을 선택합니다.
4. `geom_text()` 함수는 그림 내에 글자를 표현해주며, label 인자에 원하는 글자를 입력해준 후 글자가 표현될 x축, y축, 색상, 사이즈 등을 선택할 수 있습니다.

### `geom_boxplot()`: 박스 플롯 나타내기


```r
ggplot(data_market, aes(x = SEC_NM_KOR, y = PBR)) +
  geom_boxplot() +
  coord_flip()
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-25-1.png" width="70%" style="display: block; margin: auto;" />

박스 플롯 역시 데이터의 분포와 이상치를 확인하기 좋은 그림이며, `geom_boxplot()` 함수를 통해 나타낼 수 있습니다.

1. x축 데이터로는 섹터 정보, y축 데이터로는 PBR을 선택합니다.
2. `geom_boxplot()`을 통해 박스 플롯을 그려줍니다.
3. `coord_flip()` 함수는 x축과 y축을 뒤집어 표현해주며 x축에 PBR, y축에 섹터 정보가 나타나게 됩니다.

결과를 살펴보면 유틸리티나 금융 섹터는 PBR이 잘 모여 있는 반면, IT나 건강관리 섹터 등은 매우 극단적인 PBR을 가지고 있는 종목이 있습니다.

### `dplyr`과 `ggplot`을 연결하여 사용하기


```r
data_market %>%
  filter(!is.na(SEC_NM_KOR)) %>%
  group_by(SEC_NM_KOR) %>%
  summarize(ROE_sector = median(ROE, na.rm = TRUE),
            PBR_sector = median(PBR, na.rm = TRUE)) %>%
  ggplot(aes(x = ROE_sector, y = PBR_sector,
             color = SEC_NM_KOR, label = SEC_NM_KOR)) +
  geom_point() +
  geom_text(color = 'black', size = 3, vjust = 1.3) +
  theme(legend.position = 'bottom',
        legend.title = element_blank())
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-26-1.png" width="70%" style="display: block; margin: auto;" />

앞에서 배운 데이터 분석과 시각화를 동시에 연결해 사용할 수도 있습니다.

1. 데이터 분석의 단계로 `filter()`를 통해 섹터가 NA가 아닌 종목을 선택합니다.
2. `group_by()`를 통해 섹터별 그룹을 묶습니다.
3. `summarize()`를 통해 ROE와 PBR의 중앙값을 계산해줍니다. 해당 과정을 거치면 다음의 결과가 계산됩니다.


```
## # A tibble: 10 x 3
##    SEC_NM_KOR         ROE_sector PBR_sector
##    <chr>                   <dbl>      <dbl>
##  1 IT                     0.0962      1.51 
##  2 건강관리               0.0705      2.59 
##  3 경기관련소비재         0.062       1.07 
##  4 금융                   0.0896      0.715
##  5 산업재                 0.0684      0.925
##  6 소재                   0.0631      0.76 
##  7 에너지                 0.0608      0.955
##  8 유틸리티               0.0697      0.48 
##  9 커뮤니케이션서비스     0.137       0.93 
## 10 필수소비재             0.0696      0.96
```

해당 결과를 파이프 오퍼레이터(`%>%`)로 이을 경우 그대로 시각화가 가능하며, `ggplot()` 함수 내에 데이터를 입력하지 않아도 됩니다.
4. x축과 y축을 설정한 후 색상과 라벨을 섹터로 지정해주면 각 섹터별로 색상이 다른 산점도가 그려집니다.
5. `geom_text()` 함수를 통해 앞에서 라벨로 지정한 섹터 정보들을 출력해줍니다.
6. `theme()` 함수를 통해 다양한 테마를 지정합니다. legend.position 인자로 범례를 하단에 배치했으며, legend.title 인자로 범례의 제목을 삭제했습니다.

### `geom_bar()`: 막대 그래프 나타내기


```r
data_market %>%
  group_by(SEC_NM_KOR) %>%
  summarize(n = n()) %>%
  ggplot(aes(x = SEC_NM_KOR, y = n)) +
  geom_bar(stat = 'identity') +
  theme_classic()
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-28-1.png" width="70%" style="display: block; margin: auto;" />

`geom_bar()`는 막대 그래프를 그려주는 함수입니다.

1. `group_by()`를 통해 섹터별 그룹을 묶어줍니다.
2. `summarize()` 함수 내부에 `n()`을 통해 각 그룹별 데이터 개수를 구합니다.
3. `ggplot()` 함수에서 x축에는 SEC_NM_KOR, y축에는 n을 지정해줍니다.
4. `geom_bar()`를 통해 막대 그래프를 그려줍니다. y축에 해당하는 n 데이터를 그대로 사용하기 위해서는 stat 인자를 identity로 지정해주어야 합니다. `theme_*()` 함수를 통해 배경 테마를 바꿀 수도 있습니다.

한편 위 그래프는 데이터 개수에 따라 순서대로 막대가 정렬되지 않아 보기에 좋은 형태는 아닙니다. 이를 반영해 더욱 보기 좋은 그래프로 나타내보겠습니다.


```r
data_market %>%
  filter(!is.na(SEC_NM_KOR)) %>%
  group_by(SEC_NM_KOR) %>%
  summarize(n = n()) %>%
  ggplot(aes(x = reorder(SEC_NM_KOR, n), y = n, label = n)) +
  geom_bar(stat = 'identity') +
  geom_text(color = 'black', size = 4, hjust = -0.3) +
  xlab(NULL) +
  ylab(NULL) +
  coord_flip() +
  scale_y_continuous(expand = c(0, 0, 0.1, 0)) + 
  theme_classic()
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-29-1.png" width="70%" style="display: block; margin: auto;" />

1. `filter()` 함수를 통해 NA 종목은 삭제해준 후 섹터별 종목 개수를 구해줍니다.
2. `ggplot()`의 x축에 `reorder()` 함수를 적용해 SEC_NM_KOR 변수를 n 순서대로 정렬해줍니다.
3. `geom_bar()`를 통해 막대 그래프를 그려준 후 `geom_text()`를 통해 라벨에 해당하는 종목 개수를 출력합니다.
4. `xlab()`과 `ylab()`에 NULL을 입력해 라벨을 삭제합니다.
5. `coord_flip()` 함수를 통해 x축과 y축을 뒤집어줍니다.
6. `scale_y_continuous()` 함수를 통해 그림의 간격을 약간 넓혀줍니다.
7. `theme_classic()`으로 테마를 변경해줍니다.

결과를 보면 종목수가 많은 섹터부터 순서대로 정렬되어 보기도 쉬우며, 종목수도 텍스트로 표현되어 한눈에 확인할 수 있습니다.

이처럼 데이터 시각화를 통해 정보의 분포나 특성을 한눈에 확인할 수 있으며, `ggplot()`을 이용하면 복잡한 형태의 그림도 매우 간단하고 아름답게 표현할 수 있습니다.

## 주가 및 수익률 시각화

주가 혹은 수익률을 그리는 것 역시 매우 중요합니다. R의 기본 함수로도 주가나 수익률을 나타낼 수 있지만, 패키지를 사용하면 더욱 보기 좋은 그래프를 그릴 수 있습니다. 또한 최근에 나온 여러 패키지들을 이용하면 매우 손쉽게 인터랙티브 그래프를 구현할 수도 있습니다.

### 주가 그래프 나타내기


```r
library(quantmod)

getSymbols('SPY')
prices = Cl(SPY)
```

`getSymbols()` 함수를 이용해 미국 S&P 500 지수를 추종하는 ETF인 SPY의 데이터를 다운로드한 후 `Cl()` 함수를 이용해 종가에 해당하는 데이터만 추출합니다. 이제 해당 가격 및 수익률을 바탕으로 그래프를 그려보겠습니다.


```r
plot(prices, main = 'Price')
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />

`getSymbols()` 함수는 데이터를 xts 형식으로 다운로드합니다. R에서는 데이터가 xts 형식일 경우 기본 함수인 `plot()`으로 그래프를 그려도 x축에 시간을 나타내고 오른쪽 상단에 기간을 표시합니다. 그러나 완벽히 깔끔한 형태의 그래프라고 보기에 어려운 면이 있습니다.


```r
library(ggplot2)

SPY %>%
  ggplot(aes(x = Index, y = SPY.Close)) +
  geom_line()
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-32-1.png" width="70%" style="display: block; margin: auto;" />

`ggplot()`을 이용하면 기본 `plot()`보다 한결 깔끔해지며, 패키지 내의 다양한 함수를 이용해 그래프를 꾸밀 수도 있습니다.

### 인터랙티브 그래프 나타내기


```r
library(dygraphs)

dygraph(prices) %>%
  dyRangeSelector()
```



<img src="images/dygraph.png" width="70%" style="display: block; margin: auto;" />

`dygraphs` 패키지의 `dygraph()` 함수를 이용하면 사용자의 움직임에 따라 반응하는 그래프를 그릴 수 있습니다. 해당 패키지는 JavaScript를 이용해 인터랙티브한 그래프를 구현합니다. 그래프 위에 마우스 커서를 올리면 날짜 및 가격이 표시되기도 하며, 하단의 셀렉터를 이용해 원하는 기간의 수익률을 선택할 수도 있습니다.


```r
library(highcharter)

highchart(type = 'stock') %>%
  hc_add_series(prices) %>%
  hc_scrollbar(enabled = FALSE)
```



<img src="images/highcharter.png" width="70%" style="display: block; margin: auto;" />

highcharter 패키지의 `highchart()` 함수 역시 이와 비슷하게 인터랙티브 그래프를 생성해줍니다. 왼쪽 상단의 기간을 클릭하면 해당 기간의 수익률만 확인할 수 있으며, 오른쪽 상단에 기간을 직접 입력할 수도 있습니다.


```r
library(plotly)

p = SPY %>%
  ggplot(aes(x = Index, y = SPY.Close)) +
  geom_line()

ggplotly(p)
```



<img src="images/ggplotly.png" width="70%" style="display: block; margin: auto;" />

plotly 패키지는 R뿐만 아니라 Python, MATLAB, Julia 등 여러 프로그래밍 언어에 사용될 수 있는 그래픽 패키지로서 최근에 많은 사랑을 받고 있습니다. R에서는 단순히 `ggplot()`을 이용해 나타낸 그림에 `ggplotly()` 함수를 추가하는 것만으로 인터랙티브한 그래프를 만들어줍니다.

또한 해당 패키지는 최근 샤이니에서도 많이 사용되고 있습니다. 따라서 샤이니를 이용한 웹페이지 제작을 생각하고 있는 분이라면, 원래의 함수 실행 방법도 알아두는 것이 좋습니다.


```r
prices %>%
  fortify.zoo %>%
  plot_ly(x= ~Index, y = ~SPY.Close ) %>%
  add_lines()
```



<img src="images/plotly.png" width="70%" style="display: block; margin: auto;" />

`plot_ly()` 함수 내부에 x축과 y축을 설정해주며, 변수명 앞에 물결표(~)를 붙여줍니다. 그 후 `add_lines()` 함수를 추가하면 선 그래프를 표시해줍니다. `ggplot()` 함수는 플러스 기호(+)를 통해 각 레이어를 연결해주었지만, `plot_ly()` 함수는 파이프 오퍼레이터(`%>%`)를 통해 연결할 수 있다는 장점이 있습니다.

### 연도별 수익률 나타내기

주가 그래프 외에 연도별 수익률을 그리는 것도 중요합니다. `ggplot()`을 통해 연도별 수익률을 막대 그래프로 나타내는 방법을 살펴보겠습니다.


```r
library(PerformanceAnalytics)

ret_yearly = prices %>%
  Return.calculate() %>%
  apply.yearly(., Return.cumulative) %>%
  round(4) %>%
  fortify.zoo() %>%
  mutate(Index = as.numeric(substring(Index, 1, 4)))

ggplot(ret_yearly, aes(x = Index, y = SPY.Close)) +
  geom_bar(stat = 'identity') +
  scale_x_continuous(breaks = ret_yearly$Index,
                       expand = c(0.01, 0.01)) +
  geom_text(aes(label = paste(round(SPY.Close * 100, 2), "%"),
                vjust = ifelse(SPY.Close >= 0, -0.5, 1.5)),
            position = position_dodge(width = 1),
            size = 3) +
  xlab(NULL) + ylab(NULL)
```

<img src="08-data_analysis_files/figure-html/unnamed-chunk-45-1.png" width="70%" style="display: block; margin: auto;" />

1. `apply.yearly()` 함수를 이용해 연도별 수익률을 계산한 뒤 반올림합니다.
2. `fortify.zoo()` 함수를 통해 인덱스에 있는 시간 데이터를 Index 열로 이동합니다.
3. `mutate()` 함수 내에 `substring()` 함수를 통해 Index의 1번째부터 4번째 글자, 즉 연도에 해당하는 부분을 뽑아낸 후 숫자 형태로 저장합니다.
4. `ggplot()` 함수를 이용해 x축에는 연도가 저장된 Index, y축에는 수익률이 저장된 SPY.Close를 입력합니다.
5. `geom_bar()` 함수를 통해 막대 그래프를 그려줍니다.
6. `scale_x_continuous()` 함수를 통해 x축에 모든 연도가 출력되도록 합니다.
7. `geom_text()`를 통해 막대 그래프에 연도별 수익률이 표시되도록 합니다. `vjust()` 내에 `ifelse()` 함수를 사용해 수익률이 0보다 크면 위쪽에 표시하고, 0보다 작으면 아래쪽에 표시되도록 합니다.

해당 과정을 거치면 막대 그래프와 텍스트를 통해 연도별 수익률을 한눈에 확인할 수 있게 됩니다.
