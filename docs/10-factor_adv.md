# 퀀트 전략을 이용한 종목선정 (심화)

지난 장에서는 팩터를 이용한 투자 전략의 기본이 되는 로우볼, 모멘텀, 밸류, 퀄리티 전략에 대해 알아보았습니다. 물론 이러한 단일 팩터를 이용한 투자도 장기적으로 우수한 성과를 보이지만, 여러 팩터를 결합하거나 좀더 정밀하게 전략을 만든다면 더욱 우수한 성과를 거둘 수 있습니다.

이번 장에서는 섹터별 효과를 없앤 후 포트폴리오를 구성하는 방법, 극단치 데이터 제거 및 팩터 결합 방법, 그리고 멀티팩터 구성방법에 대해 알아보겠습니다.

## 섹터 중립 포트폴리오

팩터 전략의 단점 중 하나는 선택된 종목들이 특정 섹터로 쏠리는 경우가 있다는 점입니다. 특히 과거 수익률을 토대로 종목을 선정하는 모멘텀 전략의 경우, 특정 섹터가 좋을때 동일한 섹터의 모든 종목이 함께 움직이는 경향이 있어 이러한 쏠림이 심할 수 있습니다.

먼저 지난 장에서 배운 12개월 모멘텀을 이용한 포트폴리오 구성 방법을 다시 살펴보도록 하겠습니다.


```r
library(stringr)
library(xts)
library(PerformanceAnalytics)
library(dplyr)
library(ggplot2)

KOR_price = read.csv('data/KOR_price.csv', row.names = 1, stringsAsFactors = FALSE) %>% as.xts()
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1, stringsAsFactors = FALSE) 
KOR_ticker$'종목코드' = str_pad(KOR_ticker$'종목코드', 6, 'left', 0)

ret = Return.calculate(KOR_price) %>% xts::last(252) 
ret_12m = ret %>% sapply(., function(x) {
  prod(1+x) - 1
  })

invest_mom = rank(-ret_12m) <= 30
```

기존의 코드와 동일하게, 주식 가격 및 티커 데이터를 불러온 후, 최근 12개얼 수익률을 구해 상위 30 종목을 선택합니다.


```r
KOR_sector = read.csv('data/KOR_sector.csv', row.names = 1, stringsAsFactors = FALSE)
KOR_sector$'CMP_CD' = str_pad(KOR_sector$'CMP_CD', 6, 'left', 0)
data_market = left_join(KOR_ticker, KOR_sector,
                         by = c('종목코드' = 'CMP_CD', '종목명' = 'CMP_KOR'))
```

해당 종목들의 섹터 정보를 추가로 살펴보기 위해, 섹터 데이터를 불러온 후, `left_join()` 함수를 이용해 티커와 결합하여 data_market에 저장해줍니다.


```r
data_market[invest_mom, ] %>%
  select(`SEC_NM_KOR`) %>%
  group_by(`SEC_NM_KOR`) %>%
  summarize(n = n()) %>%
  ggplot(aes(x = reorder(`SEC_NM_KOR`, `n`), y = `n`, label = n)) +
  geom_col() +
  geom_text(color = 'black', size = 4, hjust = -0.3) +
  xlab(NULL) +
  ylab(NULL) +
  coord_flip() +
  scale_y_continuous(expand = c(0, 0, 0.1, 0)) + 
  theme_classic()
```

<img src="10-factor_adv_files/figure-html/unnamed-chunk-3-1.png" width="50%" style="display: block; margin: auto;" />

`group_by()` 함수를 이용하여 12개월 기준 모멘텀 포트폴리오 종목들의 섹터 별 종목수를 계산해준 후, `ggplot()` 함수를 이용하여 이를 그림으로 나타내줍니다. 그림에서 알 수 있듯이, 특정 섹터에 대부분의 종목이 몰려있습니다.

따라서 여러 종목으로 포트폴리오를 구성하였지만, 분해해보면 특정 섹터에 쏠림이 심하다는 것을 알 수 있습니다. 이러한 섹터 쏠림 현상을 제거한 **섹터 중립 포트폴리오**를 구성해 보도록 하겠습니다.


```r
sector_neutral = data_market %>%
  select(`종목코드`, `SEC_NM_KOR`) %>%
  mutate(`ret` = ret_12m) %>%
  group_by(`SEC_NM_KOR`) %>%
  mutate(scale_per_sector = scale(`ret`),
         scale_per_sector = ifelse(is.na(`SEC_NM_KOR`), NA, scale_per_sector))
```

1. 먼저 종목코드와 섹터정보, 그리고 12개월 수익률 정보를 불러옵니다.
2. `group_by()` 함수를 통해 섹터별 그룹을 만들어 줍니다.
3. `scale()` 함수를 이용해 정규화를 해줍니다. 정규화의 경우 $\frac{x- \mu}{\sigma}$로 계산됩니다. 
4. 섹터 정보가 없는 정보는 삭제해주도록 합니다.

위의 정규화 과정을 살펴보면, 전체 종목에서 12개월 수익률을 비교하는 것이 아닌 각 섹터별로 수익률의 강도를 비교하게 됩니다. 따라서 특정 종목의 과거 수익률이 전체 종목과 비교해서 높았어도 해당 섹터 내에서의 순위가 낮다면, 정규화된 값은 낮게됩니다. 

따라서 섹터 별 정규화 과정을 거친 값으로 비교 분석을 한다면, 섹터 효과가 어느정도 제거된 포트폴리오를 구성할 수 있습니다.


```r
invest_mom_neutral = rank(-sector_neutral$scale_per_sector) <= 30

data_market[invest_mom_neutral, ] %>%
  select(`SEC_NM_KOR`) %>%
  group_by(`SEC_NM_KOR`) %>%
  summarize(n = n()) %>%
  ggplot(aes(x = reorder(`SEC_NM_KOR`, `n`), y = `n`, label = n)) +
  geom_col() +
  geom_text(color = 'black', size = 4, hjust = -0.3) +
  xlab(NULL) +
  ylab(NULL) +
  coord_flip() +
  scale_y_continuous(expand = c(0, 0, 0.1, 0)) + 
  theme_classic()
```

<img src="10-factor_adv_files/figure-html/unnamed-chunk-5-1.png" width="50%" style="display: block; margin: auto;" />

정규화된 값의 랭킹이 높은 상위 30 종목을 선택하며, 내림차순을 위해 마이너스를 붙여줍니다. 해당 포트폴리오의 섹터 별 구성종목을 확인해보면, 단순하게 포트폴리오를 구성한 것 대비, 여러 섹터에 종목이 분산되어 있음이 확인됩니다.

이처럼 `group_by()` 함수를 통해 손쉽게 그룹별 중립화를 할 수 있으며, 글로벌 투자를 하는 경우에는 지역, 국가, 섹터 별로도 중립화된 포트폴리오를 구성하기도 합니다.

## 마법공식

하나의 팩터만을 보고 투자하는 것 보다, 둘 혹은 그 이상의 팩터를 결합하여 투자하는 것이 훨씬 좋은 포트폴리오를 구성할 수 있으며, 이러한 방법을 멀티 팩터라 합니다. 그중에서도 밸류와 퀄리티의 조합은 전통적으로 많이 사용되어진 방법이며, 그 중 대표적인 예가 조엘 그린블라트의 마법공식입니다.

이번 장에서는 퀄리티와 밸류 간의 관계, 그리고 마법공식의 정의와 구성방법에 대해 알아보도록 하겠습니다.

### 퀄리티와 밸류 간의 관계

투자의 정석 중 하나는 **좋은 기업을 싸게 사는 것**입니다. 이를 팩터의 관점에서 이해하면 퀄리티 팩터와 밸류 팩터로 이해할 수도 있습니다. 

여러 논문에 따르면 흔히 밸류와 퀄리티 팩터는 반대의 관계에 있습니다. 먼저 가치주들은 위험이 크기 때문에 시장에서 소외를 받아 저평가가 이루어지는 것이며, 이러한 위험에 대한 댓가로 밸류 팩터의 수익률이 높게됩니다. 반대로 사람들은 우량주에 기꺼이 프리미엄을 지불하려 하기 때문에 퀄리티 팩터의 수익률이 높기도 합니다. 이는 마치 동전의 양면과 같지만, 장기적으로 가치주와 우량주 모두 우수한 성과를 기록합니다. 

먼저 퀄리티의 지표인 매출총이익과 밸류 지표인 PBR을 통해 둘간의 관계를 확인해보도록 하겠습니다.


```r
library(stringr)
library(dplyr)

KOR_value = read.csv('data/KOR_value.csv', row.names = 1, stringsAsFactors = FALSE)
KOR_fs = readRDS('data/KOR_fs.Rds')
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1, stringsAsFactors = FALSE) 

data_pbr = KOR_value['PBR']
data_gpa = (KOR_fs$'매출총이익' / KOR_fs$'자산')[ncol(KOR_fs$'매출총이익')] %>%
  setNames('GPA')

cbind(data_pbr, -data_gpa) %>%
  cor(method = 'spearman', use = 'complete.obs') %>% round(4)
```

```
##         PBR     GPA
## PBR  1.0000 -0.2096
## GPA -0.2096  1.0000
```

데이터를 불러온 후, PBR과 GPA(매출총이익 / 자산)를 구해주도록 합니다. 그 후 랭킹의 상관관계인 스피어만 상관관계를 구해보면, 서로 간 반대 관계가 있음이 확인됩니다. PBR의 경우 오름차순, GPA의 경우 내림차순 이므로 GPA 앞에 마이너스를 붙여주었습니다.


```r
cbind(data_pbr, data_gpa) %>%
  mutate(quantile_pbr = ntile(data_pbr, 5)) %>%
  filter(!is.na(quantile_pbr)) %>%
  group_by(quantile_pbr) %>%
  summarise(mean_gpa = mean(GPA, na.rm = TRUE)) %>%
  ggplot(aes(x = quantile_pbr, y = mean_gpa)) +
  geom_col() +
  xlab('PBR') + ylab('GPA')
```

<img src="10-factor_adv_files/figure-html/unnamed-chunk-7-1.png" width="50%" style="display: block; margin: auto;" />

이번에는 PBR의 분위수 별 GPA 평균값을 구하도록 하겠습니다.

1. `ntile()` 함수를 이용해 PBR을 5분위수로 나누어 줍니다.
2. PBR이 없는 종목은 제외합니다.
3. `group_by()`를 통해 PBR의 분위수별 그룹을 묶어 줍니다.
4. 각 PBR 그룹 별 GPA의 평균값을 구해줍니다.
5. `ggplot()`을 이용해 시각화를 해줍니다.

그림에서 알수 있듯이 PBR이 낮을수록 GPA도 낮으며, 즉 가치주일수록 우량성은 떨어집니다. 반면에 PBR이 높을수록 GPA도 늪으며, 이는 주식의 가격이 비쌀수록 우량성도 높다는 것을 의미합니다.

이를 이용해 밸류 팩터와 퀄리티 팩터간의 관계를 나타내면 다음과 같습니다.


<div class="figure" style="text-align: center">
<img src="images/tableqv.png" alt="밸류 팩터와 퀄리티 팩터간의 관계" width="50%" />
<p class="caption">(\#fig:unnamed-chunk-8)밸류 팩터와 퀄리티 팩터간의 관계</p>
</div>

주가가 쌀수록 기업의 우량성은 떨어지며(①번), 반대로 기업의 우량성이 좋으면 주식은 비싼 경향(③번)이 있습니다. 물론 우량성도 떨어지고 비싸기만한 주식(②번)을 사려는 사람들 아마 없을 겁니다. 결과적으로 우리가 원하는 최고의 주식은 우량성이 있으면서도 가격은 싼 주식(④번)일 것입니다. 

### 마법공식 이해하기

마법공식이란 고담 캐피탈의 설립자이자 전설적인 투자자 조엘 그린블라트에 의해 알려진 투자방법입니다. 그는 본인의 책 **주식 시장을 이기는 작은 책**에서 투자를 하는데 있어 중요한 두가지 지표와, 이를 혼합할 경우 뛰어난 성과를 기록할 수 있다고 하였습니다.

첫번째 지표는 이율(Earnings Yield)로써 기업의 수익을 기업의 가치로 나는 값입니다. 이는 PER의 역수와 비슷하며, 밸류 지표 중 하나입니다.

두번째 지표는 투자 자본 수익률(Return on Capital)로써 기업의 수익을 투자한 자본으로 나눈 값입니다. 이는 ROE와도 비슷하며, 퀄리티 지표 중 하나입니다.

마법공식은 이 두가지 지표의 랭킹을 각각 구한 후, 랭킹의 합 기준 상위 30 개 종목을 1년간 보유한 후 매도하는 전략입니다.

해당 전략은 국내 투자자들에게도 많이 사랑받는 전략입니다. 그러나 두 지표를 계산하기 위한 데이터를 수집하는데 어려움이 있어 많은 투자자들이 이율 대신 PER를, 투하 자본 수익률 대신 ROE를 사용합니다. 그러나 우리가 수집한 데이터를 통해 충분히 원래의 마법공식을 구현할 수 있습니다.


Table: (\#tab:unnamed-chunk-9)마법공식의 구성 요소

팩터   Value                                              Quality                                        
-----  -------------------------------------------------  -----------------------------------------------
지표   이율 (Earnings Yield)                              투하 자본 수익률 (Return On Capital)           
계산   $\frac{이자\,및\,법인세 차감전이익}{기업\,가치}$   $\frac{이자\,및\,법인세 차감전이익}{투하자본}$ 

### 마법공식 구성하기

재무제표 항목을 통해 이율과 투하 자본 수익률을 계산하고, 이를 통해 마법공식 포트폴리오를 구성하도록 하겠습니다.

먼저, 밸류지표에 해당하는 이익수익률을 계산해보도록 하겟습니다. 이익수익률은 이자 및 법인세 차감전이익(EBIT)를 기업 가치(시가총액 + 순차입금)으로 나눈 값입니다. 이를 분해하면 다음과 같습니다.

\begin{equation} 

이익수익률 = \frac{이자\,및\,법인세\,차감전이익}{기업\,가치} \\
= \frac{이자\,및\,법인세\,차감전이익}{시가총액 + 순차입금} \\
= \frac{당기순이익 + 법인세 + 이자비용}{시가총액 + 총부채 - 여유자금} \\
= \frac{당기순이익 + 법인세 + 이자비용}{시가총액 + 총부채 - (현금 - max(0, 유동부채 - 유동자산 + 현금))}

\end{equation} 


```r
library(stringr)
library(dplyr)

KOR_value = read.csv('data/KOR_value.csv', row.names = 1, stringsAsFactors = FALSE)
KOR_fs = readRDS('data/KOR_fs.Rds')
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1, stringsAsFactors = FALSE) 
KOR_ticker$'종목코드' = str_pad(KOR_ticker$'종목코드', 6, 'left', 0)

num_col = ncol(KOR_fs[[1]])

# 분자
magic_ebit = (KOR_fs$'지배주주순이익' + KOR_fs$'법인세비용' + KOR_fs$'이자비용')[num_col]

# 분모
magic_cap = KOR_value$PER * KOR_fs$'지배주주순이익'[num_col]
magic_debt = KOR_fs$'부채'[num_col]
magic_excess_cash_1 = KOR_fs$'유동부채' - KOR_fs$'유동자산' + KOR_fs$'현금및현금성자산'
magic_excess_cash_1[magic_excess_cash_1 < 0] = 0
magic_excess_cash_2 = (KOR_fs$'현금및현금성자산' - magic_excess_cash_1)[num_col]

magic_ev = magic_cap + magic_debt - magic_excess_cash_2

# 이익수익률
magic_ey = magic_ebit / magic_ev
```

먼저 가치지표, 재무제표, 티커 데이터를 불러온 후, 재무제표 열 갯수를 구해주도록 합니다. 그 후 분자와 분모 항목에 해당하는 부분을 하나씩 계산해 줍니다.

먼저 분자 부분인 **이자 및 법인세 차감전이익**은 **지배주주 순이익**에 **법인세비용**과 **이자비용**을 더해줍니다. 그 후, 최근년도 데이터를 선택해 줍니다.

분모 부분은 시가총액, 총부채, 여유자금 총 세가지로 구성되어 있습니다.

1. 우리가 가지고 있는 밸류 데이터와 재무제표 데이터를 통해 시가총액을 역산할 수 있습니다. PER 값에 Earnings를 곱해주면 시가총액이 계산되게 됩니다. 이를 통해 계산된 시가총액을 HTS나 금융 사이트의 값과 비교하면 거의 비슷함이 확인됩니다.

\begin{equation} 

PER \times Earnings = \frac{Price}{Earnings/Shares} \times Earnings \\
= \frac{Price \times Shares}{Earnings} \times Earnings \\
= Price \times Earnings = Market\,Cap

\end{equation} 



2. 총 부채는 부채 항목을 사용하면 됩니다.
3. 여유자금은 두 단계에 걸쳐 계산하도록 합니다. 먼저 **유동부채 - 유동자산 + 현금** 값을 구해준 후, 0보다 작은 값은 모두 0으로 바꾸어주도록 합니다. 이 값을 현금 및 현금성자산 항목에서 차감하여 최종적인 여유자금을 구하도록 합니다.

분자와 분모 부분을 나누어주면 이익수익률을 계산할 수 있습니다.

다음으로 퀄리티 지표에 해당하는 투하 자본 수익률을 계산하도록 하겠습니다. 해당 값은 이자 및 법인세 차감전이익(EBIT)를 투하자본(IC)으로 나누어 계산되며, 이를 분해하면 다음과 같습니다.

\begin{equation} 

투하 자본 수익률 = \frac{이자\,및\,법인세\,차감전이익}{투하자본} \\
= \frac{당기순이익 + 법인세 + 이자비용}{(유동자산 - 유동부채) + (비유동자산 - 감가상각비)}

\end{equation} 


```r
magic_ic = ((KOR_fs$'유동자산' - KOR_fs$'유동부채') +
              (KOR_fs$'비유동자산' - KOR_fs$'감가상각비'))[num_col]
magic_roc = magic_ebit / magic_ic
```

투하 자본 수익률은 비교적 쉽게 계산할 수 있습니다. 분모에 해당하는 투하 자본의 경우 재무제표 항목을 그대로 사용하면 되며, 분자인 이자 및 법인세 차감전이익은 위에서 이미 구해둔 값을 그대로 사용하면 됩니다.

이제 두 지표를 활용하여 마법공식 포트폴리오를 구성하도록 하겠습니다.


```r
invest_magic = rank(rank(-magic_ey) + rank(-magic_roc)) <= 30

KOR_ticker[invest_magic, ] %>%
  select(`종목코드`, `종목명`) %>%
  mutate(`이익수익률` = magic_ey[invest_magic, ],
         `투하자본수익률` = magic_roc[invest_magic, ])
```

```
##    종목코드         종목명 이익수익률 투하자본수익률
## 1    005930       삼성전자  0.1894849      0.2504221
## 2    000660     SK하이닉스  0.3441471      0.4793078
## 3    004800           효성  0.5663100      1.8507795
## 4    010780   아이에스동서  0.1851429      0.2913760
## 5    008060       대덕전자  0.2526047      0.2936349
## 6    012630            HDC  0.4907727      0.3623118
## 7    001820     삼화콘덴서  0.1298620      0.6383476
## 8    090460       비에이치  0.1307829      0.5129063
## 9    003300     한일홀딩스  0.3919292      0.2164415
## 10   086390     유니테스트  0.3067661      0.4580397
## 11   045100     한양이엔지  0.2697852      0.3235486
## 12   003030   세아제강지주  0.3028029      0.2302996
## 13   004960       한신공영  0.1831483      0.3066055
## 14   036190   금화피에스시  0.2395210      0.2316258
## 15   035620 바른손이앤에이  0.5380096      0.9668008
## 16   029460         케이씨  0.9663764      0.5832074
## 17   121800         비덴트  0.4687894      0.3265007
## 18   040910       아이씨디  0.1741219      0.2611465
## 19   036200         유니셈  0.1658174      0.2693798
## 20   126700 하이비젼시스템  0.2130603      0.2265886
## 21   006580       대양제지  0.1892245      0.2778542
## 22   083930         아바코  0.1656007      0.2599010
## 23   001570           금양  0.1461728      0.3548387
## 24   042040   케이피엠테크  0.2948247      0.2938830
## 25   036010     아비코전자  0.5160426      0.2416226
## 26   010280   쌍용정보통신  0.2960666      0.3963415
## 27   290740         액트로  0.1736520      0.3194444
## 28   127710     아시아경제  0.3627433      0.2408985
## 29   094970       제이엠티  0.2402346      0.2700186
## 30   194510     파티게임즈  0.2170685      0.5069124
```

이익수익률과 투하 자본 수익률의 랭킹을 각각 구해주며, 내림차순으로 값을 구하기 위해 마이너스를 붙여줍니다. 그 후 두 값의 합의 랭킹 기준 상위 30 종목을 선택합니다. 그 후 종목코드와 종목명, 각 지표를 확인해주도록 합니다.
