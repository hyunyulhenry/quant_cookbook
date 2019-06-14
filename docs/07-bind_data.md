# 데이터 정리하기

앞장에서는 API와 크롤링을 통하여 퀀트 투자에 필요한 주가, 재무제표, 가치지표를 수집하는 방법에 대해 배웠습니다. 이번 장에서는 각각 csv 파일로 저장된 데이터들을 하나로 합친 후 저장하는 과정을 살펴보도록 하겠습니다.

## 주가 정리하기

주가의 경우 **data/KOR_price** 폴더 내에 **티커_price.csv** 파일로 저장되어 있습니다. 해당 파일들을 불러온 후 데이터를 묶는 작업을 통해 하나의 파일로 합치는 방법에 대해 알아보도록 하겠습니다.


```r
library(stringr)
library(xts)
library(magrittr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
KOR_ticker$'종목코드' = str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')

price_list = list()

for (i in 1 : nrow(KOR_ticker)) {
  
  name = KOR_ticker[i, '종목코드']
  price_list[[i]] = read.csv(paste0('data/KOR_price/', name, '_price.csv'), row.names = 1) %>%
    as.xts()
  
}

price_list = do.call(cbind, price_list) %>% na.locf()
colnames(price_list) = KOR_ticker$'종목코드'

head(price_list[, 1:5])
```

```
##            005930 000660 005380 068270 051910
## 2017-05-23     NA     NA     NA  91678 289500
## 2017-05-24     NA     NA 164000  93149 290000
## 2017-05-25     NA     NA 165000  91972 296000
## 2017-05-26     NA     NA 163500  91972 304500
## 2017-05-29     NA  57900 162000  91776 309500
## 2017-05-30  44640  57400 164000  93933 306500
```

1. 먼저 티커가 저장된 csv 파일을 불러온 후, 티커를 6자리로 맞춰주도록 합니다. 
2. 빈 리스트인 price_list 생성합니다.
3. for loop 구문을 이용해 종목별 가격 데이터를 불러온 후, `as.xts()`를 통해 시계열 형태로 데이터를 변경한 후 리스트에 저장합니다.
4. `do.call()` 함수를 통해 리스트를 열의 형태로 묶습니다.
5. 간혹 결측치가 발생할 수 있으므로, `na.locf()` 함수를 통해 결측치의 경우 전일 데이터를 사용하도록 합니다.
6. 행 이름을 각 종목의 티커로 변경해 주도록 합니다.

해당 작업을 통해 각각 흩어져있던 가격 데이터가 하나의 데이터로 잘 묶어지게 되었습니다.


```r
write.csv(data.frame(price_list), 'data/KOR_price.csv')
```

마지막으로 해당 데이터를 data 폴더 내에 **KOR_price.csv** 파일로 저장해주도록 합니다. 시계열 형태 그대로 저장할 경우 인덱스가 삭제되므로, 데이터프레임 형태로 변경한 후 저장하도록 합니다.

## 재무제표 정리하기

재무제표의 경우 **data/KOR_fs** 폴더 내 **티커_fs.csv** 파일로 저장되어 있습니다. 주가의 경우 하나의 열로 이루어져있어 데이터를 정리하는 것이 간단하였지만, 재무제표의 경우 각 종목 별 재무 항목이 모두 다르다는 어려움이 있습니다.


```r
library(stringr)
library(magrittr)
library(dplyr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
KOR_ticker$'종목코드' = str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')

data_fs = list()

for (i in 1 : nrow(KOR_ticker)){
  
  name = KOR_ticker[i, '종목코드']
  data_fs[[i]] = read.csv(paste0('data/KOR_fs/', name, '_fs.csv'), row.names = 1)
}
```

위와 동일하게 티커를 불러온 후, 이를 바탕으로 종목별 재무제표 데이터를 불러온 후 리스트에 저장합니다. 


```r
fs_item = data_fs[[1]] %>% rownames()
length(fs_item)
```

```
## [1] 236
```

```r
print(head(fs_item))
```

```
## [1] "매출액"           "매출원가"         "매출총이익"      
## [4] "판매비와관리비"   "인건비"           "유무형자산상각비"
```

다음으로 재무제표 항목의 기준을 정해줄 필요가 있습니다. 재무제표 작성 항목의 경우 각 업종별로 상이하므로, 이를 모두 고려할 경우 지나치게 데이터가 커지게 됩니다. 또한 퀀트 투자에는 일반적이고 공통적인 항목을 주로 사용하므로 대표적인 재무 항목을 정해 이를 기준으로 데이터를 정리하여도 충분합니다.

따라서 기준점으로 첫번째 리스트, 즉 삼성전자의 재무 항목을 선택하도록 하며, 총 236개 항목이 존재합니다. 해당 기준을 바탕으로 재무제표 데이터를 정리하도록 하며, 전체 항목에 대한 정리 이전에 간단한 예시로 첫번째 항목인 **매출액** 기준 데이터 정리를 살펴보도록 하겠습니다. 


```r
select_fs = lapply(data_fs, function(x) {
    # 해당 항목이 있을시 데이터를 선택
    if ( '매출액' %in% rownames(x) ) {
          x[which(rownames(x) == '매출액'), ]
    # 해당 항목이 존재하지 않을 시, NA로 된 데이터프레임 생성
      } else {
      data.frame(NA)
    }
  })

select_fs = bind_rows(select_fs)

print(head(select_fs))
```

```
##   X2016.12 X2017.12 X2018.12 NA. X2015.12
## 1  2018667  2395754  2437714  NA       NA
## 2   171980   301094   404451  NA       NA
## 3   936490   963761   968126  NA       NA
## 4     6706     9491     9821  NA       NA
## 5   206593   256980   281830  NA       NA
## 6       NA       NA       NA  NA       NA
```

먼저 `lapply()` 함수를 이용하여 모든 재무데이터가 들어있는 data_fs 변수를 대상으로 함수를 적용합니다. `%in%()` 함수를 통해 만일 매출액이라는 항목이 행이름에 존재할 시, 해당 부분의 데이터를 select_fs 리스트에 저장하며, 그렇지 않을 경우, 즉 해당 항목이 존재하지 않을 경우 NA로 이루어진 데이터프레임을 저장합니다.

그 후, `dplyr` 패키지의 `bind_rows()` 함수를 이용하여 리스트 내 데이터들을 행으로 묶어주도록 합니다. `rbind()`의 경우 모든 데이터의 열갯수가 동일해야 하는 반면, `bind_rows()`의 경우 갯수가 다를 경우 나머지 부분을 NA로 처리해 합쳐주는 장점이 있습니다. 

합쳐진 데이터를 살펴보면, 먼저 열이름이 **.** 혹은 **NA.**인 부분이 존재합니다. 이는 매출액 항목이 없는 종목의 경우 NA 데이터프레임을 저장하여 생긴 결과입니다. 또한 2016, 2017, 2017, 2015년 등 연도가 순서대로 저장되지 않은 경우가 있습니다. 이 두가지를 고려하여 데이터를 클랜징해주도록 합니다.



```r
select_fs = select_fs[!colnames(select_fs) %in% c('.', 'NA.')]
select_fs = select_fs[, order(names(select_fs))]
rownames(select_fs) = KOR_ticker[, '종목코드']

print(head(select_fs))
```

```
##        X2015.12 X2016.12 X2017.12 X2018.12
## 005930       NA  2018667  2395754  2437714
## 000660       NA   171980   301094   404451
## 005380       NA   936490   963761   968126
## 068270       NA     6706     9491     9821
## 051910       NA   206593   256980   281830
## 055550       NA       NA       NA       NA
```

1. `!`와 `%in%()` 함수를 이용하여, 열이름에 **.** 혹은 **NA.**이 들어가지 않은 열만을 선택해주도록 합니다.
2. `order()` 함수를 이용해 열이름의 연도별 순서를 구한 후, 이를 바탕으로 열을 다시 정리하도록 합니다.
3. 행이름을 티커들로 지정해줍니다.

해당 과정을 통해 전 종목의 매출액 데이터가 연도별로 정리되었습니다. for loop 구문을 이용하여 모든 재무항목에 대해 정리하는 법은 다음과 같습니다.


```r
fs_list = list()

for (i in 1 : length(fs_item)) {
  select_fs = lapply(data_fs, function(x) {
    # 해당 항목이 있을시 데이터를 선택
    if ( fs_item[i] %in% rownames(x) ) {
          x[which(rownames(x) == fs_item[i]), ]
    # 해당 항목이 존재하지 않을 시, NA로 된 데이터프레임 생성
      } else {
      data.frame(NA)
    }
  })

  # 리스트 데이터를 행으로 묶어줌 
  select_fs = bind_rows(select_fs)

  # 열이름이 '.' 혹은 'NA.'인 지점은 삭제 (NA 데이터)
  select_fs = select_fs[!colnames(select_fs) %in% c('.', 'NA.')]
  
  # 연도 순별로 정리
  select_fs = select_fs[, order(names(select_fs))]
  
  # 행이름을 티커로 변경
  rownames(select_fs) = KOR_ticker[, '종목코드']
  
  # 리스트에 최종 저장
  fs_list[[i]] = select_fs

}

# 리스트 이름을 재무 항목으로 변경
names(fs_list) = fs_item
```

위의 과정을 거치면 fs_list에 총 236개 리스트가 생성되며, 각 리스트에는 해당 재무 항목에 대한 전 종목의 연도별 데이터가 정리되어 있습니다.


```r
saveRDS(fs_list, 'data/KOR_fs.Rds')
```

마지막으로 해당 데이터를 data 폴더 내에 저장해주도록 하며, 리스트 형태 그대로 저장하기 위해 `saveRDS()` 함수를 이용하여 
**KOR_fs.Rds**로 저장해주도록 합니다.

RDS 형식의 경우, 파일을 더블 클릭한 후 연결 프로그램을 RStudio로 설정해 파일을 불러올 수 있습니다. 혹은 `readRDS()` 함수를 이용하여 파일을 읽어올 수도 있습니다.

## 가치지표 정리하기

재무제표의 경우 **data/KOR_value** 폴더 내 **티커_value.csv** 파일로 저장되어 있으며, 재무제표를 정리하는 방법과 거의 동일합니다.


```r
library(stringr)
library(magrittr)
library(dplyr)

KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
KOR_ticker$'종목코드' = str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')

data_value = list()

for (i in 1 : nrow(KOR_ticker)){
  
  name = KOR_ticker[i, '종목코드']
  data_value[[i]] =
    read.csv(paste0('data/KOR_value/', name, '_value.csv'), row.names = 1) %>% t() %>% data.frame()

}
```

먼저 티커에 해당하는 파일을 불러온 후, for loop 구문을 통해 `read.csv()` 함수를 통해 불러온 가치지표를 data_value 리스트에 저장해주도록 합니다. 단, csv 내에 데이터가 테이블 \@ref(tab:valuesample)와 같이 행의 형태로 저장되어 있으므로, `t()` 함수를 이용해 열의 형태로 바꿔주도록 하며, 데이터프레임 형태로 저장해줍니다.


Table: (\#tab:valuesample)가치지표의 저장 예시

value   x        
------  ---------
PER     Number 1 
PBR     Number 2 
PCR     Number 3 
PSR     Number 4 


```r
data_value = bind_rows(data_value)
print(head(data_value))
```

```
##         PER       PBR       PCR        PSR X1
## 1  5.950618 1.0541861  3.896324  1.0714054 NA
## 2  3.077828 1.0208625  2.151857  1.1825847 NA
## 3 20.260295 0.4134804  8.116928  0.3156051 NA
## 4 97.300689 9.6753724 66.666633 25.9376035 NA
## 5 16.154841 1.3733681 11.195115  0.8441124 NA
## 6  6.835012 0.5886837        NA         NA NA
```

`bind_rows()` 함수를 이용하여 리스트 내 데이터들을 행으로 묶어준 후 데이터를 확인해보면 PER, PBR, PCR, PSR 열 외에 불필요한 NA로 이루어진 열이 존재합니다. 해당 열을 삭제한 후 정리작업을 해주도록 하겠습니다.


```r
data_value = data_value[colnames(data_value) %in% c('PER', 'PBR', 'PCR', 'PSR')]
rownames(data_value) = KOR_ticker[, '종목코드']

print(head(data_value))
```

```
##              PER       PBR       PCR        PSR
## 005930  5.950618 1.0541861  3.896324  1.0714054
## 000660  3.077828 1.0208625  2.151857  1.1825847
## 005380 20.260295 0.4134804  8.116928  0.3156051
## 068270 97.300689 9.6753724 66.666633 25.9376035
## 051910 16.154841 1.3733681 11.195115  0.8441124
## 055550  6.835012 0.5886837        NA         NA
```

```r
write.csv(data_value, 'data/KOR_value.csv')
```

열 이름이 가치지표에 해당하는 부분만을 선택한 후, 행이름을 티커들로 변경합니다. 마지막으로 data 폴더 내에 **KOR_value.csv** 파일로 저장해주도록 합니다.
