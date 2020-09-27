# 퀀트 전략을 이용한 종목선정 (기본)

투자에 필요한 주가, 재무제표, 가치지표 데이터가 준비되었다면 퀀트 전략을 활용해 투자하고자 하는 종목을 선정해야 합니다. 퀀트 투자는 크게 포트폴리오 운용 전략과 트레이딩 전략으로 나눌 수 있습니다. 포트폴리오 운용 전략은 과거 주식 시장을 분석해 좋은 주식의 기준을 찾아낸 후 해당 기준에 만족하는 종목을 매수하거나, 이와 반대에 있는 나쁜 주식을 공매도하기도 합니다. 투자의 속도가 느리며, 다수의 종목을 하나의 포트폴리오로 구성해 운용하는 특징이 있습니다. 반면 트레이딩 전략은 단기간에 발생되는 주식의 움직임을 연구한 후 예측해 매수 혹은 매도하는 전략입니다. 투자의 속도가 빠르며 소수의 종목을 대상으로 합니다.


Table: (\#tab:unnamed-chunk-1)퀀트 투자 종류의 비교

|    기준     | 포트폴리오 운용 전략 |       트레이딩 전략       |
|:-----------:|:--------------------:|:-------------------------:|
|  투자철학   |  규칙에 기반한 투자  |    규칙에 기반한 투자     |
|  투자목적   |   좋은 주식을 매수   |     좋은 시점을 매수      |
| 학문적 기반 |  경제학, 통계학 등   | 통계학, 공학, 정보처리 등 |
| 투자의 속도 |         느림         |           빠름            |

이 중 이 책에서는 포트폴리오에 기반한 운용 전략에 대해 다룹니다. 주식의 수익률에 영향을 미치는 요소를 팩터(Factor)라고 합니다. 즉 팩터의 강도가 양인 종목들로 구성한 포트폴리오는 향후 수익률이 높을 것으로 예상되며, 팩터의 강도가 음인 종목들로 구성한 포트폴리오는 반대로 향후 수익률이 낮을 것으로 예상됩니다.

팩터에 대한 연구는 학자들에 의해 오랫동안 진행되어 왔지만, 일반 투자자들이 이러한 논문을 모두 찾아보고 연구하기는 사실상 불가능에 가깝습니다. 그러나 최근에는 스마트 베타라는 이름으로 팩터 투자가 대중화되고 있습니다. 최근 유행하고 있는 스마트 베타 ETF는 팩터를 기준으로 포트폴리오를 구성한 상품으로서, 학계나 실무에서 검증된 팩터 전략을 기반으로 합니다.

해당 상품들의 웹사이트나 투자설명서에는 종목 선정 기준에 대해 자세히 나와 있으므로 스마트 베타 ETF에 나와 있는 투자 전략을 자세히 분석하는 것만으로도 훌륭한 퀀트 투자 전략을 만들 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/factor_smartbeta.png" alt="스마트베타 ETF 전략 예시" width="80%" />
<p class="caption">(\#fig:unnamed-chunk-2)스마트베타 ETF 전략 예시</p>
</div>

이 CHAPTER에서는 투자에 많이 활용되는 기본적인 팩터에 대해 알아보고, 우리가 구한 데이터를 바탕으로 각 팩터별 투자 종목을 선택하는 방법을 알아보겠습니다.

## 베타 이해하기

투자자들이라면 누구나 한 번은 베타(Beta)라는 용어를 들어봤을 것입니다. 기본적으로 주식시장의 움직임은 개별 주식의 수익률에 가장 크게 영향을 주는 요소일 수밖에 없습니다. 아무리 좋은 주식도 주식시장이 폭락한다면 같이 떨어지며, 아무리 나쁜 주식도 주식시장이 상승한다면 대부분 같이 오르기 마련입니다.

개별 주식이 전체 주식시장의 변동에 반응하는 정도를 나타낸 값이 베타입니다. 베타가 1이라는 뜻은 주식시장과 움직임이 정확히 같다는 뜻으로서 시장 그 자체를 나타냅니다. 베타가 1.5라는 뜻은 주식시장이 수익률이 +1%일 때 개별 주식의 수익률은 +1.5% 움직이며, 반대로 주식시장의 수익률이 -1%일 때 개별 주식의 수익률은 -1.5% 움직인다는 뜻입니다. 반면 베타가 0.5라면 주식시장 수익률의 절반 정도만 움직이게 됩니다.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:unnamed-chunk-3)베타에 따른 개별 주식의 수익률 움직임</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> 베타 </th>
   <th style="text-align:center;"> 주식시장이 +1% 일 경우 </th>
   <th style="text-align:center;"> 주식시장이 -1% 일 경우 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> 0.5 </td>
   <td style="text-align:center;"> +0.5% </td>
   <td style="text-align:center;"> -0.5% </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 1.0 </td>
   <td style="text-align:center;"> +1.0% </td>
   <td style="text-align:center;"> -1.0% </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 1.5 </td>
   <td style="text-align:center;"> +1.5% </td>
   <td style="text-align:center;"> -1.5% </td>
  </tr>
</tbody>
</table>

이처럼 베타가 큰 주식은 주식시장보다 수익률의 움직임이 크며, 반대로 베타가 낮은 주식은 주식시장보다 수익률의 움직임이 작습니다. 따라서 일반적으로 상승장이 기대될 때는 베타가 큰 주식에, 하락장이 기대될 때는 베타가 낮은 주식에 투자하는 것이 좋습니다.

주식시장에서 베타는 통계학의 회귀분석모형에서 기울기를 나타내는 베타와 정확히 의미가 같습니다. 회귀분석모형은 $y = a + bx$ 형태로 나타나며, 회귀계수인 $b$는 $x$의 변화에 따른 $y$의 변화의 기울기입니다. 이를 주식에 적용한 모형이 자산가격결정모형(CAPM: Capital Asset Pricing Model)[@sharpe1964capital]이며, 그 식은 다음과 같습니다.

$$회귀분석모형: y = a + bx$$
$$자산가격결정모형: R_i = R_f + \beta_i\times[R_m - R_f]$$

먼저 회귀분석모형의 상수항인 $a$에 해당하는 부분은 무위험 수익률을 나타내는 $R_f$입니다. 독립변수인 $x$에 해당하는 부분은 무위험 수익률 대비 주식 시장의 초과 수익률을 나타내는 시장위험 프리미엄인 $R_m - R_f$입니다. 종속변수인 $y$에 해당하는 부분은 개별주식의 수익률을 나타내는 $R_i$이며, 최종적으로 회귀계수인 $b$에 해당하는 부분은 개별 주식의 베타입니다.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:unnamed-chunk-4)회귀분석모형과 자산가격결정모형의 비교</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> 구분 </th>
   <th style="text-align:center;"> 회귀분석모형 </th>
   <th style="text-align:center;"> 자산가격결정모형 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> 상수항 </td>
   <td style="text-align:center;"> a </td>
   <td style="text-align:center;"> $R_f$ (무위험 수익률) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 독립변수 </td>
   <td style="text-align:center;"> x </td>
   <td style="text-align:center;"> $R_m - R_f$ (시장위험 프리미엄) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 종속변수 </td>
   <td style="text-align:center;"> y </td>
   <td style="text-align:center;"> $R_i$ (개별주식의 수익률) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 회귀계수 </td>
   <td style="text-align:center;"> b </td>
   <td style="text-align:center;"> $\beta_i$ (개별주식의 베타) </td>
  </tr>
</tbody>
</table>

통계학에서 회귀계수는 $\beta = \frac{cov(x,y)}{\sigma_x^2}$ 형태로 구할 수 있으며, $x$와 $y$에 각각 시장수익률과 개별주식의 수익률을 대입할 경우 개별주식의 베타는 $\beta_i= \rho(i,m) \times\frac{\sigma_i}{\sigma_m}$  형태로 구할 수 있습니다. 그러나 이러한 수식을 모르더라도 R에서는 간단히 베타를 구할 수 있습니다.

### 베타 계산하기

베타를 구하는 방법을 알아보기 위해 주식시장에 대한 대용치로 KOSPI 200 ETF, 개별주식으로는 전통적 고베타주인 증권주를 이용하겠습니다.


```r
library(quantmod)
library(PerformanceAnalytics)
library(magrittr)

symbols = c('102110.KS', '039490.KS')
getSymbols(symbols)
```

```
## [1] "102110.KS" "039490.KS"
```

```r
prices = do.call(cbind,
                 lapply(symbols, function(x)Cl(get(x))))

ret = Return.calculate(prices)
ret = ret['2016-01::2018-12']
```

1. KOSPI 200 ETF인 TIGER 200(102110.KS), 증권주인 키움증권(039490.KS)의 티커를 입력합니다.
2. `getSymbols()` 함수를 이용하여 해당 티커들의 데이터를 다운로드 받습니다.
3. `lapply()` 함수 내에 `Cl()`과 `get()`함수를 사용하여 종가에 해당하는 데이터만 추출하며, 리스트 형태의 데이터를 열의 형태로 묶어주기 위해 `do.call()` 함수와 `cbind()` 함수를 사용해 줍니다.
4. `Return.calculate()` 함수를 통해 수익률을 계산해 줍니다.
5. xts 형식의 데이터는 대괄호 속에 ['시작일자::종료일자']와 같은 형태로, 원하는 날짜를 편리하게 선택할 수 있으며, 위에서는 2016년 1월부터 2018년 12월 까지 데이터를 선택합니다.


```r
rm = ret[, 1]
ri = ret[, 2]

reg = lm(ri ~ rm)
summary(reg)
```

```
## 
## Call:
## lm(formula = ri ~ rm)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -0.06890 -0.01296 -0.00171  0.01082  0.09541 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 0.000400   0.000728    0.55     0.58    
## rm          1.764722   0.091131   19.36   <2e-16 ***
## ---
## Signif. codes:  
## 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.0196 on 721 degrees of freedom
##   (8 observations deleted due to missingness)
## Multiple R-squared:  0.342,	Adjusted R-squared:  0.341 
## F-statistic:  375 on 1 and 721 DF,  p-value: <2e-16
```

증권주를 대상으로 베타를 구하기 위한 회귀분석을 실시합니다. 자산가격결정모형의 수식인 $R_i = R_f + \beta_i \times [R_m - R_f]$ 에서 편의를 위해 무위험 수익률인 $R_f$를 0으로 가정하면, $R_i = \beta_i \times R_m$의 형태로 나타낼 수 있습니다. 이 중 $R_m$는 독립변수인 주식시장의 수익률을 의미하고, $R_i$는 종속변수인 개별 주식의 수익률을 의미합니다.

1. 독립변수는 첫 번째 열인 KOSPI 200 ETF의 수익률을 선택하며, 종속변수는 두번째 열인 증권주의 수익률을 선택합니다.
2. `lm()` 함수를 통해 손쉽게 선형회귀분석을 실시할 수 있으며, 회귀분석의 결과를 reg 변수에 저장합니다.
3. `summary()` 함수는 데이터의 요약 정보를 나타내며, 해당 예시에서는 회귀분석 결과에 대한 정보를 보여줍니다.

회귀분석의 결과 중 가장 중요한 부분은 계수를 나타내는 Coefficients입니다. Intercept는 회귀분석의 상수항에 해당하는 부분으로서, 값이 거의 0에 가깝고 t값 또한 매우 작아 유의하지 않음이 보입니다. 우리가 원하는 베타에 해당하는 부분
은 $x$의 Estimate로서, 베타값이 1.76으로 증권주의 특성인 고베타주임이 확인되며, t값 또한 19.36로 매우 유의한 결과입니다. 조정된 결정계수(Adjusted R-square)는 0.34를 보입니다.

### 베타 시각화 ###

이제 구해진 베타를 그림으로 표현해보겠습니다.


```r
plot(as.numeric(rm), as.numeric(ri), pch = 4, cex = 0.3, 
     xlab = "KOSPI 200", ylab = "Individual Stock",
     xlim = c(-0.02, 0.02), ylim = c(-0.02, 0.02))
abline(a = 0, b = 1, lty = 2)
abline(reg, col = 'red')
```

<img src="09-factor_basic_files/figure-html/unnamed-chunk-7-1.png" width="70%" style="display: block; margin: auto;" />

1. `plot()` 함수를 통해 그림을 그려주며, x축과 y축에 주식시장 수익률과 개별 주식 수익률을 입력합니다. pch는 점들의 모양을, cex는 점들의 크기를 나타내며, xlab과 ylab은 각각 x축과 y축에 들어갈 문구를 나타냅니다. xlim과 ylim은 x
축과 y축의 최소 및 최대 범위를 지정해줍니다.
2. 첫번째 `abline()`에서 a는 상수, b는 직선의 기울기, lty는 선의 유형을 나타냅니다. 이를 통해 기울기, 즉 베타가 1일 경우의 선을 점선으로 표현합니다.
3. 두번째 `abline()`에 회귀분석 결과를 입력해주면 자동적으로 회귀식을 그려줍니다.

검은색의 점선이 기울기가 1인 경우이며, 주황색의 직선이 증권주의 회귀분석결과를 나타냅니다. 기울기가 1보다 훨씬 가파름이 확인되며, 즉 베타가 1보다 크다는 사실을 알 수 있습니다.

## 저변동성 전략

금융 시장에서 변동성은 수익률이 움직이는 정도로서, 일반적으로 표준편차가 사용됩니다. 표준편차는 자료가 평균을 중심으로 얼마나 퍼져 있는지를 나타내는 수치로서, 수식은 다음과 같습니다.

$$\sigma = \sqrt{\frac{\sum_{i=1}^{n}{(x_i - \bar{x})^2}}{n-1}}$$

관측값의 개수가 적을 경우에는 수식에 대입해 계산하는 것이 가능하지만, 관측값이 수백 혹은 수천 개로 늘어날 경우 컴퓨터를 이용하지 않고 계산하기는 사실상 불가능합니다. R에서는 복잡한 계산 과정 없이 `sd()` 함수를 이용해 간단하게 표준편차를 계산할 수 있습니다.


```r
example = c(85, 76, 73, 80, 72)
sd(example)
```

```
## [1] 5.357
```

개별 주식의 표준편차를 측정할 때는 주식의 가격이 아닌 수익률로 계산해야 합니다. 수익률의 표준편차가 크면 수익률이 위아래로 많이 움직여 위험한 종목으로 여겨집니다. 반면 표준편차가 작으면 수익률의 움직임이 적어 상대적으로 안전한 종목으로 여겨집니다.

전통적 금융 이론에서는 수익률의 변동성이 클수록 위험이 크고, 이런 위험에 대한 보상으로 기대수익률이 높아야 한다고 보았습니다. 따라서 고변동성 종목의 기대수익률이 크고, 저변동성 종목의 기대수익률이 낮은 고위험 고수익이 당연한 믿음이었습니다. 그러나 현실에서는 오히려 변동성이 낮은 종목들의 수익률이 변동성이 높은 종목들의 수익률보다 높은, 저변동성 효과가 발견되고 있습니다. 이러한 저변동성 효과가 발생하는 원인으로는 여러 가설이 있습니다.

1. 투자자들은 대체로 자신의 능력을 과신하는 경향이 있으며, 복권과 같이 큰 수익을 가져다 주는 고변동성 주식을 선호하는 경향이 있습니다. 이러한 결과로 고변동성 주식은 과대 평가되어 수익률이 낮은 반면, 과소 평가된 저변동성 주식들은 높은 수익률을 보이게 됩니다. [@brunnermeier2005optimal]

2. 대부분 기관투자가들이 레버리지 투자가 되지 않는 상황에서, 벤치마크 대비 높은 성과를 얻기 위해 고변동성 주식에 투자하는 경향이 있으며, 이 또한 고변동성 주식이 과대 평가되는 결과로 이어집니다. [@baker2011benchmarks]

3. 시장의 상승과 하락이 반복됨에 따라 고변동성 주식이 변동성 손실(Volatility Drag)로 인해 수익률이 하락하게 되는 이유도 있습니다. [@sefton2011low]

주식의 위험은 변동성뿐만 아니라 베타 등 여러 지표로도 측정할 수 있습니다. 저변동성 효과와 비슷하게 고유변동성이 낮은 주식의 수익률이 높은 저고유변동성 효과[@ang2009high], 베타가 낮은 주식의 수익률이 오히려 높은 저베타 효과[@baker2014low]도 발견되고 있으며, 이러한 효과들을 합쳐 저위험 효과라고 부르기도 합니다.

### 저변동성 포트폴리오 구하기: 일간 기준

먼저 최근 1년 일간 수익률 기준 변동성이 낮은 30종목을 선택하겠습니다.


```r
library(stringr)
library(xts)
library(PerformanceAnalytics)
library(magrittr)
library(ggplot2)
library(dplyr)

KOR_price = read.csv('data/KOR_price.csv', row.names = 1,
                     stringsAsFactors = FALSE) %>% as.xts()
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1,
                      stringsAsFactors = FALSE) 
KOR_ticker$'종목코드' = 
  str_pad(KOR_ticker$'종목코드', 6, 'left', 0)

ret = Return.calculate(KOR_price)
std_12m_daily = xts::last(ret, 252) %>% apply(., 2, sd) %>%
  multiply_by(sqrt(252))
```

1. 저장해둔 가격 정보와 티커 정보를 불러옵니다. 가격 정보는 `as.xts()` 함수를 통해 xts 형태로 변경합니다.
2. `Return.calculate()` 함수를 통해 수익률을 구합니다.
3. `last()` 함수는 마지막 n개 데이터를 선택해주는 함수이며, 1년 영업일 기준인 252개 데이터를 선택합니다. dplyr 패키지의 `last()` 함수와 이름이 같으므로, `xts::last()` 형식을 통해 xts 패키지의 함수임을 정의해줍니다.
4. `apply()` 함수를 통해 sd 즉 변동성을 계산해주며, 연율화를 해주기 위해 `multiply_by()` 함수를 통해 $\sqrt{252}$를 곱해줍니다.


```r
std_12m_daily %>% 
  data.frame() %>%
  ggplot(aes(x = (`.`))) +
  geom_histogram(binwidth = 0.01) +
  annotate("rect", xmin = -0.02, xmax = 0.02,
           ymin = 0,
           ymax = sum(std_12m_daily == 0, na.rm = TRUE) * 1.1,
           alpha=0.3, fill="red") +
  xlab(NULL)

std_12m_daily[std_12m_daily == 0] = NA
```

<img src="09-factor_basic_files/figure-html/unnamed-chunk-10-1.png" width="70%" style="display: block; margin: auto;" />

변동성을 히스토그램으로 나타내보면, 0에 위치하는 종목들이 다수 있습니다. 해당 종목들은 최근 1년간 거래정지로 인해 가격이 변하지 않았고, 이로 인해 변동성이 없는 종목들입니다. 해당 종목들은 NA로 처리해줍니다.


```r
std_12m_daily[rank(std_12m_daily) <= 30]
```

```
## X268280 X002840 X001720 X034950 X072710 X016800 X000480 
##  0.1730  0.2437  0.2262  0.2182  0.2476  0.1535  0.2382 
## X092130 X015360 X092230 X004890 X100250 X024090 X107590 
##  0.2478  0.2479  0.1935  0.2174  0.2157  0.2361  0.2351 
## X003460 X134380 X007330 X083660 X034590 X040420 X065560 
##  0.2236  0.1887  0.1906  0.1595  0.1791  0.2281  0.2350 
## X004080 X007590 X005190 X273060 X084670 X109860 X032790 
##  0.1380  0.2445  0.2464  0.1626  0.2514  0.2259  0.2482 
## X037440 X221980 
##  0.2504  0.2442
```

```r
std_12m_daily[rank(std_12m_daily) <= 30] %>%
  data.frame() %>%
  ggplot(aes(x = rep(1:30), y = `.`)) +
  geom_col() +
  xlab(NULL)
```

<img src="09-factor_basic_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />

`rank()` 함수를 통해 순위를 구할 수 있으며, R은 기본적으로 오름차순 즉 가장 낮은값의 순위가 1이 됩니다. 따라서 변동성이 낮을수록 높은 순위가 되며, 30위 이하의 순위를 선택하면 변동성이 낮은 30종목이 선택됩니다. 또한 `ggplot()` 함수를 이용해 해당 종목들의 변동성을 확인해볼 수도 있습니다.

이번에는 해당 종목들의 티커 및 종목명을 확인하겠습니다.


```r
invest_lowvol = rank(std_12m_daily) <= 30
KOR_ticker[invest_lowvol, ] %>%
  select(`종목코드`, `종목명`) %>%
  mutate(`변동성` = round(std_12m_daily[invest_lowvol], 4))
```

```
##    종목코드         종목명 변동성
## 1    268280     미원에스씨 0.1730
## 2    002840       미원상사 0.2437
## 3    001720       신영증권 0.2262
## 4    034950   한국기업평가 0.2182
## 5    072710     농심홀딩스 0.2476
## 6    016800         퍼시스 0.1535
## 7    000480       조선내화 0.2382
## 8    092130     이크레더블 0.2478
## 9    015360   예스코홀딩스 0.2479
## 10   092230      KPX홀딩스 0.1935
## 11   004890       동일산업 0.2174
## 12   100250     진양홀딩스 0.2157
## 13   024090         디씨엠 0.2361
## 14   107590     미원홀딩스 0.2351
## 15   003460       유화증권 0.2236
## 16   134380       미원화학 0.1887
## 17   007330   푸른저축은행 0.1906
## 18   083660     CSA 코스믹 0.1595
## 19   034590   인천도시가스 0.1791
## 20   040420 정상제이엘에스 0.2281
## 21   065560   녹원씨엔아이 0.2350
## 22   004080           신흥 0.1380
## 23   007590     동방아그로 0.2445
## 24   005190       동성화학 0.2464
## 25   273060     와이즈버즈 0.1626
## 26   084670       동양고속 0.2514
## 27   109860       동일금속 0.2259
## 28   032790     엠젠플러스 0.2482
## 29   037440           희림 0.2504
## 30   221980       케이디켐 0.2442
```

티커와 종목명, 연율화 변동성을 확인할 수 있습니다.

### 저변동성 포트폴리오 구하기: 주간 기준

이번에는 일간 변동성이 아닌 주간 변동성을 기준으로 저변동성 종목을 선택하겠습니다.


```r
std_12m_weekly = xts::last(ret, 252) %>%
  apply.weekly(Return.cumulative) %>%
  apply(., 2, sd) %>% multiply_by(sqrt(52))

std_12m_weekly[std_12m_weekly == 0] = NA
```

먼저 최근 252일 수익률울 선택한 후, `apply.weekly()` 함수 내 Return.cumulative를 입력해 주간 수익률을 계산하며, 연율화를 위해 연간 주수에 해당하는 $\sqrt{52}$를 곱해줍니다. 이 외에도 `apply.monthly()`, `apply.yearly()` 함수 등으로 일간 수익률을 월간, 연간 수익률 등으로 변환할 수 있습니다. 그 후 과정은 위와 동일합니다.



```r
std_12m_weekly[rank(std_12m_weekly) <= 30]
```

```
##  X363280  X332570  X268280  X016800  X002960  X000480 
## 0.122219 0.153579 0.148775 0.126700 0.221751 0.214828 
##  X337930  X294090  X291650  X323990  X092230  X347740 
## 0.151006 0.069247 0.147122 0.056324 0.215304 0.166159 
##  X304100  X117580  X282690  X003460  X134380  X007330 
## 0.181606 0.199567 0.224164 0.162748 0.209684 0.198693 
##  X347770  X318410  X034590  X040420  X004080  X273060 
## 0.029745 0.009323 0.153400 0.164772 0.094451 0.127582 
##  X109860  X332370  X115310  X221980  X043100  X347140 
## 0.182599 0.198642 0.195164 0.214238 0.203698 0.031163
```

```r
invest_lowvol_weekly = rank(std_12m_weekly) <= 30
KOR_ticker[invest_lowvol_weekly, ] %>%
  select(`종목코드`, `종목명`) %>%
  mutate(`변동성` =
           round(std_12m_weekly[invest_lowvol_weekly], 4))
```

```
##    종목코드                   종목명 변동성
## 1    363280             티와이홀딩스 0.1222
## 2    332570                   와이팜 0.1536
## 3    268280               미원에스씨 0.1488
## 4    016800                   퍼시스 0.1267
## 5    002960               한국쉘석유 0.2218
## 6    000480                 조선내화 0.2148
## 7    337930     브랜드엑스코퍼레이션 0.1510
## 8    294090               이오플로우 0.0692
## 9    291650           압타머사이언스 0.1471
## 10   323990               박셀바이오 0.0563
## 11   092230                KPX홀딩스 0.2153
## 12   347740 피엔케이피부임상연구센타 0.1662
## 13   304100                 솔트룩스 0.1816
## 14   117580               대성에너지 0.1996
## 15   282690               동아타이어 0.2242
## 16   003460                 유화증권 0.1627
## 17   134380                 미원화학 0.2097
## 18   007330             푸른저축은행 0.1987
## 19   347770                     핌스 0.0297
## 20   318410                   비비씨 0.0093
## 21   034590             인천도시가스 0.1534
## 22   040420           정상제이엘에스 0.1648
## 23   004080                     신흥 0.0945
## 24   273060               와이즈버즈 0.1276
## 25   109860                 동일금속 0.1826
## 26   332370                 아이디피 0.1986
## 27   115310                 인포바인 0.1952
## 28   221980                 케이디켐 0.2142
## 29   043100               솔고바이오 0.2037
## 30   347140        케이프이에스제4호 0.0312
```

주간 수익률의 변동성이 낮은 30종목을 선택해 종목코드, 종목명, 연율화 변동성을 확인합니다.


```r
intersect(KOR_ticker[invest_lowvol, '종목명'],
          KOR_ticker[invest_lowvol_weekly, '종목명'])
```

```
##  [1] "미원에스씨"     "퍼시스"         "조선내화"      
##  [4] "KPX홀딩스"      "유화증권"       "미원화학"      
##  [7] "푸른저축은행"   "인천도시가스"   "정상제이엘에스"
## [10] "신흥"           "와이즈버즈"     "동일금속"      
## [13] "케이디켐"
```

`intersect()` 함수를 통해 일간 변동성 기준과 주간 변동성 기준 모두에 포함되는 종목을 찾을 수 있습니다.

## 모멘텀 전략

투자에서 모멘텀이란 주가 혹은 이익의 추세로서, 상승 추세의 주식은 지속적으로 상승하며 하락 추세의 주식은 지속적으로 하락하는 현상을 말합니다. 모멘텀 현상이 발생하는 가장 큰 원인은 투자자들의 스스로에 대한 과잉 신뢰 때문입니다. 사람들은 자신의 판단을 지지하는 정보에 대해서는 과잉 반응하고, 자신의 판단을 부정하는 정보에 대해서는 과소 반응하는 경향이 있습니다. 이러한 투자자들의 비합리성으로 인해모멘텀 현상이 생겨나게 됩니다.

모멘텀의 종류는 크게 기업의 이익에 대한 추세를 나타내는 이익 모멘텀[@rendleman1982empirical]과, 주가의 모멘텀에 대한 가격 모멘텀이 있습니다. 또한 가격 모멘텀도 1주일[@lehmann1990fads] 혹은 1개월 이하[@jegadeesh1990evidence]를 의미하는 단기 모멘텀, 3개월에서 12개월을 의미하는 중기 모멘텀[@jegadeesh1993returns], 3년에서 5년을 의미하는 장기 모멘텀[@de1985does]이 있으며, 이 중에서도 3개월에서 12개월 가격 모멘텀을 흔히 모멘텀이라고 합니다.

### 모멘텀 포트폴리오 구하기: 12개월 모멘텀

먼저 최근 1년 동안의 수익률이 높은 30종목을 선택하겠습니다.


```r
library(stringr)
library(xts)
library(PerformanceAnalytics)
library(magrittr)
library(dplyr)

KOR_price = read.csv('data/KOR_price.csv', row.names = 1,
                     stringsAsFactors = FALSE) %>% as.xts()
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1,
                      stringsAsFactors = FALSE) 
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, 'left', 0)

ret = Return.calculate(KOR_price) %>% xts::last(252) 
ret_12m = ret %>% sapply(., function(x) {
  prod(1+x) - 1
  })
```

1. 가격 정보와 티커 정보를 불러온 후 `Return.calculate()` 함수를 통해 수익률을 계산합니다. 그 후 최근 252일 수익률을 선택합니다.
2. `sapply()` 함수 내부에 `prod()` 함수를 이용해 각 종목의 누적수익률을 계산해줍니다.


```r
ret_12m[rank(-ret_12m) <= 30]
```

```
## X019170 X096530 X196170 X285130 X011000 X268600 X237690 
##  21.479  10.121   8.685   5.290   7.931   4.013   3.097 
## X290650 X131370 X101490 X253840 X042040 X018000 X057880 
##   4.949   3.878   2.939   5.542   3.111   4.048   2.922 
## X205470 X037270 X084650 X131290 X241820 X012790 X109820 
##   7.191   5.734   6.177   3.223   4.256   3.167   4.222 
## X068330 X138610 X033310 X045660 X058110 X127120 X101360 
##   2.838   2.953   3.008   2.776   9.029   4.330   5.071 
## X094860 X225220 
##   3.944   4.615
```

`rank()` 함수를 통해 순위를 구합니다. 모멘텀의 경우 높을수록 좋은 내림차순으로 순위를 계산해야 하므로 수익률 앞에 마이너스(-)를 붙여줍니다. 12개월 누적수익률이 높은 종목들이 선택됨이 확인됩니다.


```r
invest_mom = rank(-ret_12m) <= 30
KOR_ticker[invest_mom, ] %>%
  select(`종목코드`, `종목명`) %>%
  mutate(`수익률` = round(ret_12m[invest_mom], 4))
```

```
##    종목코드           종목명 수익률
## 1    019170         신풍제약 21.479
## 2    096530             씨젠 10.121
## 3    196170         알테오젠  8.684
## 4    285130         SK케미칼  5.290
## 5    011000     진원생명과학  7.931
## 6    268600         셀리버리  4.013
## 7    237690         에스티팜  3.097
## 8    290650     엘앤씨바이오  4.949
## 9    131370         알서포트  3.878
## 10   101490     에스앤에스텍  2.939
## 11   253840           수젠텍  5.542
## 12   042040     케이피엠테크  3.111
## 13   018000           유니슨  4.048
## 14   057880 필로시스헬스케어  2.922
## 15   205470         휴마시스  7.191
## 16   037270          YG PLUS  5.734
## 17   084650       랩지노믹스  6.177
## 18   131290         티에스이  3.223
## 19   241820           피씨엘  4.256
## 20   012790         신일제약  3.167
## 21   109820       진매트릭스  4.222
## 22   068330       일신바이오  2.838
## 23   138610           나이벡  2.953
## 24   033310           엠투엔  3.008
## 25   045660           에이텍  2.776
## 26   058110     멕아이씨에스  9.029
## 27   127120     디엔에이링크  4.330
## 28   101360         이엔드디  5.071
## 29   094860       코닉글로리  3.944
## 30   225220         제놀루션  4.615
```

티커와 종목명, 누적수익률을 확인할 수 있습니다.

### 모멘텀 포트폴리오 구하기: 위험조정 수익률

단순히 과거 수익률로만 모멘텀 종목을 선택하면 각종 테마나 이벤트에 따른 급등으로 인해 변동성이 지나치게 높은 종목이 있을 수도 있습니다. 누적수익률을 변동성으로 나누어 위험을 고려해줄 경우, 이러한 종목은 제외되며 상대적으로 안정적인 모멘텀 종목을 선택할 수 있습니다.


```r
ret = Return.calculate(KOR_price) %>% xts::last(252) 
ret_12m = ret %>% sapply(., function(x) {
  prod(1+x) - 1
  })
std_12m = ret %>% apply(., 2, sd) %>% multiply_by(sqrt(252))
sharpe_12m = ret_12m / std_12m
```

1. 최근 1년에 해당하는 수익률을 선택합니다.
2. `sapply()`와 `prod()` 함수를 이용해 분자에 해당하는 누적수익률을 계산합니다.
3. `apply()`와 `multiply_by()` 이용해 분모에 해당하는 연율화 변동성을 계산합니다.
4. 수익률을 변동성으로 나누어 위험조정 수익률을 계산해줍니다.

이를 통해 수익률이 높으면서 변동성이 낮은 종목을 선정할 수 있습니다.


```r
invest_mom_sharpe = rank(-sharpe_12m) <= 30
KOR_ticker[invest_mom_sharpe, ] %>%
  select(`종목코드`, `종목명`) %>%
  mutate(`수익률` = round(ret_12m[invest_mom_sharpe], 2),
         `변동성` = round(std_12m[invest_mom_sharpe], 2),
         `위험조정 수익률` =
           round(sharpe_12m[invest_mom_sharpe], 2)) %>%
  as_tibble() %>%
  print(n = Inf)
```

```
## # A tibble: 30 x 5
##    종목코드 종목명        수익률 변동성 `위험조정 수익률`…
##    <chr>    <chr>          <dbl>  <dbl>            <dbl>
##  1 035720   카카오          1.61   0.39             4.13
##  2 019170   신풍제약       21.5    1.34            16   
##  3 096530   씨젠           10.1    1.03             9.86
##  4 196170   알테오젠        8.68   0.97             8.91
##  5 285130   SK케미칼        5.29   0.85             6.24
##  6 011000   진원생명과학    7.93   1.48             5.35
##  7 112610   씨에스윈드      2      0.61             3.3 
##  8 268600   셀리버리        4.01   1                4.02
##  9 060250   NHN한국사이버결제…   2.03   0.56             3.61
## 10 237690   에스티팜        3.1    0.75             4.13
## 11 290650   엘앤씨바이오    4.95   0.71             7   
## 12 131370   알서포트        3.88   1.03             3.75
## 13 101490   에스앤에스텍    2.94   0.73             4.03
## 14 253840   수젠텍          5.54   1.33             4.16
## 15 018000   유니슨          4.05   0.97             4.19
## 16 205470   휴마시스        7.19   1.33             5.42
## 17 037270   YG PLUS         5.73   0.85             6.73
## 18 084650   랩지노믹스      6.18   1.28             4.84
## 19 131290   티에스이        3.22   0.75             4.27
## 20 241820   피씨엘          4.26   1.23             3.46
## 21 065680   우주일렉트로    2.74   0.79             3.46
## 22 016710   대성홀딩스      1.42   0.28             5   
## 23 138610   나이벡          2.95   0.89             3.3 
## 24 045660   에이텍          2.78   0.78             3.56
## 25 058110   멕아이씨에스    9.03   1.26             7.14
## 26 127120   디엔에이링크    4.33   1.01             4.28
## 27 101360   이엔드디        5.07   1.04             4.85
## 28 094860   코닉글로리      3.94   0.85             4.66
## 29 225220   제놀루션        4.62   0.88             5.27
## 30 080580   오킨스전자      2.5    0.64             3.91
```

티커와 종목명, 누적수익률, 변동성, 위험조정 수익률을 확인할 수 있습니다.


```r
intersect(KOR_ticker[invest_mom, '종목명'],
          KOR_ticker[invest_mom_sharpe, '종목명'])
```

```
##  [1] "신풍제약"     "씨젠"         "알테오젠"    
##  [4] "SK케미칼"     "진원생명과학" "셀리버리"    
##  [7] "에스티팜"     "엘앤씨바이오" "알서포트"    
## [10] "에스앤에스텍" "수젠텍"       "유니슨"      
## [13] "휴마시스"     "YG PLUS"      "랩지노믹스"  
## [16] "티에스이"     "피씨엘"       "나이벡"      
## [19] "에이텍"       "멕아이씨에스" "디엔에이링크"
## [22] "이엔드디"     "코닉글로리"   "제놀루션"
```

`intersect()` 함수를 통해 단순 수익률 및 위험조정 수익률 기준 모두에 포함되는 종목을 찾을 수 있습니다. 다음은 위험조정 수익률 상위 30종목의 가격 그래프입니다.


```r
library(xts)
library(tidyr)
library(ggplot2)

KOR_price[, invest_mom_sharpe] %>%
  fortify.zoo() %>%
  gather(ticker, price, -Index) %>%
  ggplot(aes(x = Index, y = price)) +
  geom_line() +
  facet_wrap(. ~ ticker, scales = 'free') +
  xlab(NULL) +
  ylab(NULL) +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank())
```

<img src="09-factor_basic_files/figure-html/unnamed-chunk-22-1.png" width="70%" style="display: block; margin: auto;" />

## 밸류 전략

가치주 효과란 내재 가치 대비 낮은 가격의 주식(저PER, 저PBR 등)이, 내재 가치 대비 비싼 주식보다 수익률이 높은 현상[@basu1977investment]을 뜻합니다. 가치 효과가 발생하는 원인에 대한 이론은 다음과 같습니다.

1. 위험한 기업은 시장에서 상대적으로 낮은 가격에 거래되며, 이러한 위험을 감당하는 대가로 수익이 발생합니다.
2. 투자자들의 성장주에 대한 과잉 반응으로 인해 가치주는 시장에서 소외되며, 제자리를 찾아가는 과정에서 수익이 발생합니다.

기업의 가치를 나타내는 지표는 굉장히 많지만, 일반적으로 PER, PBR, PCR, PSR이 많이 사용됩니다.

### 밸류 포트폴리오 구하기: 저PBR 

먼저 기업의 가치 여부를 판단할 때 가장 많이 사용되는 지표인 PBR을 이용한 포트폴리오를 구성하겠습니다.


```r
library(stringr)
library(ggplot2)
library(dplyr)

KOR_value = read.csv('data/KOR_value.csv', row.names = 1,
                     stringsAsFactors = FALSE)
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1,
                      stringsAsFactors = FALSE) 
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, 'left', 0)

invest_pbr = rank(KOR_value$PBR) <= 30
KOR_ticker[invest_pbr, ] %>%
  select(`종목코드`, `종목명`) %>%
  mutate(`PBR` = round(KOR_value[invest_pbr, 'PBR'], 4))
```

```
##    종목코드         종목명    PBR
## 1    001040             CJ 0.1579
## 2    000880           한화 0.0981
## 3    138930    BNK금융지주 0.1773
## 4    088350       한화생명 0.0903
## 5    139130    DGB금융지주 0.1686
## 6    000150           두산 0.1076
## 7    003380       하림지주 0.1727
## 8    032190     다우데이타 0.1759
## 9    001430     세아베스틸 0.1700
## 10   058650     세아홀딩스 0.0919
## 11   002240       고려제강 0.1748
## 12   003300     한일홀딩스 0.1500
## 13   036530      S&T홀딩스 0.1439
## 14   006840       AK홀딩스 0.1552
## 15   001940    KISCO홀딩스 0.1628
## 16   005720           넥센 0.1033
## 17   092230      KPX홀딩스 0.1545
## 18   003030   세아제강지주 0.1256
## 19   002030         아세아 0.1126
## 20   200880       서연이화 0.1672
## 21   000860   강남제비스코 0.1749
## 22   009200     무림페이퍼 0.1403
## 23   012320   경동인베스트 0.1509
## 24   036000         예림당 0.1635
## 25   005010         휴스틸 0.1265
## 26   040610           SG&G 0.0737
## 27   025530      SJM홀딩스 0.1521
## 28   006200 한국전자홀딩스 0.1196
## 29   058220         아리온 0.0184
## 30   114570 지스마트글로벌 0.1483
```

가치지표들을 저장한 데이터와 티커 데이터를 불러오며, `rank()`를 통해 PBR이 낮은 30종목을 선택합니다. 그 후 종목코드와 종목명, PBR을 확인합니다. 홀딩스 등 지주사가 그 특성상 저PBR 포트폴리오에 많이 구성되어 있습니다.

### 각 지표 결합하기

저PBR 하나의 지표만으로도 우수한 성과를 거둘 수 있음은 오랜 기간 증명되고 있습니다. 그러나 저평가 주식이 계속해서 저평가에 머무르는 가치 함정에 빠지지 않으려면 여러 지표를 동시에 볼 필요도 있습니다.


```r
library(corrplot)

rank_value = KOR_value %>% 
  mutate_all(list(~min_rank(.)))

cor(rank_value, use = 'complete.obs') %>%
  round(., 2) %>%
  corrplot(method = 'color', type = 'upper',
           addCoef.col = 'black', number.cex = 1,
           tl.cex = 0.6, tl.srt=45, tl.col = 'black',
           col = colorRampPalette(
             c('blue', 'white', 'red'))(200),
           mar=c(0,0,0.5,0))
```

<img src="09-factor_basic_files/figure-html/unnamed-chunk-24-1.png" width="70%" style="display: block; margin: auto;" />

먼저 `mutate_all()` 함수를 이용해 모든 열에 함수를 적용해주며, `min_rank()`를 통해 순위를 구합니다.

각 열에 해당하는 가치지표별 랭킹을 구한 후 상관관계를 확인하며, NA 종목은 삭제해주기 위해 `use = 'complete.obs'`를 입력합니다.

`corrplot` 패키지의 `corrplot()` 함수를 이용해 상관관계를 그려보면, 같은 가치지표임에도 불구하고 서로 간의 상관관계가 꽤 낮은 지표도 있습니다. 따라서 지표를 통합적으로 고려하면 분산효과를 기대할 수도 있습니다.


```r
rank_sum = rank_value %>%
  rowSums()

invest_value = rank(rank_sum) <= 30

KOR_ticker[invest_value, ] %>%
  select(`종목코드`, `종목명`) %>%
  cbind(round(KOR_value[invest_value, ], 2))
```

```
##      종목코드           종목명   PER  PBR  PCR  PSR
## 89     078930               GS  5.22 0.26 1.79 0.16
## 101    001040               CJ  8.64 0.16 0.60 0.07
## 259    000150             두산  1.75 0.11 0.94 0.04
## 272    003240         태광산업  5.22 0.20 1.91 0.24
## 315    003380         하림지주 10.71 0.17 1.37 0.08
## 378    009970   영원무역홀딩스  4.06 0.19 1.74 0.18
## 491    084690       대상홀딩스  4.70 0.28 1.72 0.10
## 546    004690           삼천리  8.21 0.22 0.98 0.09
## 595    058650       세아홀딩스  9.05 0.09 0.76 0.06
## 618    015750       성우하이텍  6.68 0.20 0.69 0.08
## 636    001390         KG케미칼  2.51 0.18 1.64 0.12
## 677    036530        S&T홀딩스  3.74 0.14 2.62 0.15
## 706    006840         AK홀딩스  7.84 0.16 0.81 0.06
## 729    001940      KISCO홀딩스  4.86 0.16 3.20 0.18
## 748    005720             넥센  3.52 0.10 0.64 0.09
## 760    008060             대덕  3.15 0.20 1.14 0.19
## 842    092230        KPX홀딩스  5.32 0.15 2.02 0.18
## 883    002030           아세아  3.41 0.11 0.73 0.11
## 1095   003960         사조대림  1.54 0.30 1.64 0.10
## 1106   003480 한진중공업홀딩스  3.89 0.33 1.76 0.13
## 1183   115160           휴맥스  5.58 0.26 1.38 0.09
## 1201   013520     화승알앤에이  5.01 0.44 1.14 0.07
## 1210   013570           디와이  6.58 0.23 1.35 0.13
## 1224   267290     경동도시가스  4.32 0.31 3.11 0.07
## 1227   005990       매일홀딩스  4.77 0.19 1.07 0.07
## 1235   005710         대원산업  2.65 0.33 2.93 0.16
## 1440   009440     KC그린홀딩스  9.84 0.27 0.85 0.12
## 1457   002920         유성기업  3.85 0.22 2.17 0.26
## 1536   101330         모베이스  1.55 0.21 0.86 0.11
## 1699   010100       한국프랜지  4.94 0.25 1.05 0.06
```

`rowSums()` 함수를 이용해 종목별 랭킹들의 합을 구해줍니다. 그 후 네 개 지표 랭킹의 합 기준 랭킹이 낮은 30종목을 선택합니다. 즉 하나의 지표보다 네 개 지표가 골고루 낮은 종목을 선택합니다. 해당 종목들의 티커, 종목명과 가치지표를 확인할 수 있습니다.



```r
intersect(KOR_ticker[invest_pbr, '종목명'],
          KOR_ticker[invest_value, '종목명'])
```

```
##  [1] "CJ"          "두산"        "하림지주"   
##  [4] "세아홀딩스"  "S&T홀딩스"   "AK홀딩스"   
##  [7] "KISCO홀딩스" "넥센"        "KPX홀딩스"  
## [10] "아세아"
```

단순 저PBR 기준 선택된 종목과 비교해봤을 때 겹치는 종목이 상당히 줄어들었습니다.

## 퀄리티 전략

기업의 우량성, 즉 퀄리티는 투자자들이 매우 중요하게 생각하는 요소입니다. 그러나 어떠한 지표가 기업의 퀄리티를 나타내는지 한 마디로 정의하기에는 너무나 주관적이고 광범위해 쉽지 않습니다. 학계 혹은 업계에서 사용되는 우량성 관련 지표는 다음과 같이 요약할 수 있습니다. [@hsu2019quality]

1. Profitability (수익성)
2. Earnings stability (수익의 안정성)
3. Capital structure (기업 구조)
4. Growth (수익의 성장성)
5. Accounting quality (회계적 우량성)
6. Payout/dilution (배당) 
7. Investment (투자)

퀄리티 전략에는 재무제표 데이터가 주로 사용됩니다.

### F-Score

F-Score 지표는 조셉 피오트로스키 교수가 발표[@piotroski2000value]한 지표입니다. 그는 논문에서, 저PBR을 이용한 밸류 전략은 높은 성과를 기록하지만 재무 상태가 불량한 기업이 많으며, 저PBR 종목 중 재무적으로 우량한 기업을 선정해 투자한다면 성과를 훨씬 개선할 수 있다고 보았습니다.

F-Score에서는 재무적 우량 정도를 수익성(Profitability), 재무 성과(Financial Performance), 운영 효율성(Operating Efficiency)으로 구분해 총 9개의 지표를 선정합니다. 표 \@ref(tab:fscore)는 이를 요약한 테이블입니다.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:fscore)F-Score 요약</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> 지표 </th>
   <th style="text-align:center;"> 항목 </th>
   <th style="text-align:center;"> 점수 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="4"> Profitability </td>
   <td style="text-align:center;"> $ROA$ </td>
   <td style="text-align:center;"> ROA가 양수면 1점 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> $CFO$ </td>
   <td style="text-align:center;"> CFO가 양수면 1점 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> $\Delta ROA$ </td>
   <td style="text-align:center;"> ROA가 증가했으면 1점 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> $ACCRUAL$ </td>
   <td style="text-align:center;"> CFO &gt; ROA면 1점 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> Financial Performance </td>
   <td style="text-align:center;"> $\Delta LEVER$ </td>
   <td style="text-align:center;"> 레버리지가 감소했으면 1점 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> $\Delta LIQUID$ </td>
   <td style="text-align:center;"> 유동성이 증가했으면 1점 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> $EQ\_OFFER$ </td>
   <td style="text-align:center;"> 발행주식수가 감소했으면 1점 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="2"> Operating Efficiency </td>
   <td style="text-align:center;"> $\Delta MARGIN$ </td>
   <td style="text-align:center;"> 매출총이익률이 증가했으면 1점 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> $\Delta TURN$ </td>
   <td style="text-align:center;"> 회전율이 증가했으면 1점 </td>
  </tr>
</tbody>
</table>

각 지표가 우수할 경우 1점, 그렇지 않을 경우 0점을 매겨, 총 0점부터 9점까지의 포트폴리오를 구성합니다.

\begin{scriptsize}
\begin{equation*} 
\begin{split}
F\_SCORE &= F\_ROA + F\_\Delta ROA + F\_CFO + F\_ACCRUAL + F\_\Delta MARGIN \\
 &+ F\_ \Delta TURN + F\_\Delta LEVER + F\_\Delta LIQUID + F\_EQ\_OFFER
\end{split}
\end{equation*} 
\end{scriptsize}


```r
library(stringr)
library(ggplot2)
library(dplyr)

KOR_fs = readRDS('data/KOR_fs.Rds')
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1,
                      stringsAsFactors = FALSE) 
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, 'left', 0)
```

먼저 재무제표와 티커 파일을 불러옵니다. 재무제표 데이터는 Rds 형태로 저장되어 있으며, `readRDS()` 함수를 이용해 리스트 형태 그대로 불러올 수 있습니다.


```r
# 수익성
ROA = KOR_fs$'지배주주순이익' / KOR_fs$'자산'
CFO = KOR_fs$'영업활동으로인한현금흐름' / KOR_fs$'자산'
ACCURUAL = CFO - ROA

# 재무성과
LEV = KOR_fs$'장기차입금' / KOR_fs$'자산'
LIQ = KOR_fs$'유동자산' / KOR_fs$'유동부채'
OFFER = KOR_fs$'유상증자'

# 운영 효율성
MARGIN = KOR_fs$'매출총이익' / KOR_fs$'매출액'
TURN = KOR_fs$'매출액' / KOR_fs$'자산'
```

지표에 해당하는 내용을 계산해줍니다.

1. ROA는 지배주주순이익을 자산으로 나누어 계산합니다.
2. CFO는 영업활동현금흐름을 자산으로 나누어 계산합니다.
3. ACCURUAL은 CFO와 ROA의 차이를 이용해 계산합니다.
4. LEV(Leverage)는 장기차입금을 자산으로 나누어 계산합니다.
5. LIQ(Liquidity)는 유동자산을 유동부채로 나누어 계산합니다.
6. 우리가 받은 데이터에서는 발행주식수 데이터를 구할 수 없으므로, OFFER에 대한 대용치로 유상증자 여부를 사용합니다.
7. MARGIN은 매출총이익을 매출액으로 나누어 계산합니다.
8. TURN(Turnover)은 매출액을 자산으로 나누어 계산합니다.

다음으로 각 지표들이 조건을 충족하는지 여부를 판단해, 지표별로 1점 혹은 0점을 부여합니다.


```r
if ( lubridate::month(Sys.Date()) %in% c(1,2,3,4) ) {
  num_col = ncol(KOR_fs[[1]]) - 1
} else {
  num_col = ncol(KOR_fs[[1]]) 
}

F_1 = as.integer(ROA[, num_col] > 0)
F_2 = as.integer(CFO[, num_col] > 0)
F_3 = as.integer(ROA[, num_col] - ROA[, (num_col-1)] > 0)
F_4 = as.integer(ACCURUAL[, num_col] > 0) 
F_5 = as.integer(LEV[, num_col] - LEV[, (num_col-1)] <= 0) 
F_6 = as.integer(LIQ[, num_col] - LIQ[, (num_col-1)] > 0)
F_7 = as.integer(is.na(OFFER[,num_col]) |
                   OFFER[,num_col] <= 0)
F_8 = as.integer(MARGIN[, num_col] -
                   MARGIN[, (num_col-1)] > 0)
F_9 = as.integer(TURN[,num_col] - TURN[,(num_col-1)] > 0)
```

`ncol()` 함수를 이용해 열 개수를 구해줍니다. 가장 최근년도의 재무제표가 가장 오른쪽에 위치하고 있으므로, 해당 변수를 통해 최근년도 데이터만을 선택할 수 있습니다. **그러나 1월~4월의 경우 전년도 재무제표가 일부만 들어오는 경향이 있으므로, 을 통해 전전년도 데이터를 사용해야 합니다.** 따라서 `Sys.Date()` 함수를 통해 현재 날짜를 추출한 후, lubridate 패키지의 `month()` 함수를 이용해 해당 월을 계산합니다. 만일 현재 날짜가 1~4월 일 경우 `ncol(KOR_fs[[1]]) - 1`을 이용해 전전년도 데이터를 선택하며, 그렇지 않을 경우(5~12월) 전년도 데이터를 선택합니다.

`as.integer()` 함수는 TRUE일 경우 1을 반환하고 FALSE일 경우 0을 반환하는 함수로서, F-Score 지표의 점수를 매기는 데 매우 유용합니다. 점수 기준은 다음과 같습니다.

1. ROA가 양수면 1점, 그렇지 않으면 0점
2. 영업활동현금흐름이 양수면 1점, 그렇지 않으면 0점
3. 최근 ROA가 전년 대비 증가했으면 1점, 그렇지 않으면 0점
4. ACCURUAL(CFO - ROA)이 양수면 1점, 그렇지 않으면 0점
5. 레버리지가 전년 대비 감소했으면 1점, 그렇지 않으면 0점
6. 유동성이 전년 대비 증가했으면 1점, 그렇지 않으면 0점
7. 유상증자 항목이 없거나 0보다 작으면 1점, 그렇지 않으면 0점
8. 매출총이익률이 전년 대비 증가했으면 1점, 그렇지 않으면 0점
9. 회전율이 전년 대비 증가했으면 1점, 그렇지 않으면 0점


```r
F_Table = cbind(F_1, F_2, F_3, F_4, F_5, F_6, F_7, F_8, F_9) 
F_Score = F_Table %>%
  apply(., 1, sum, na.rm = TRUE) %>%
  setNames(KOR_ticker$`종목명`)
```

1. `cbind()` 함수를 통해 열의 형태로 묶어줍니다.
2. `apply()` 함수를 통해 종목별 지표의 합을 더해 F-Score를 계산해줍니다.
3. `setNanmes()` 함수를 통해 종목명을 입력합니다.


```r
(F_dist = prop.table(table(F_Score)) %>% round(3))
```

```
## F_Score
##     0     1     2     3     4     5     6     7     8 
## 0.003 0.051 0.078 0.157 0.193 0.182 0.159 0.109 0.057 
##     9 
## 0.012
```

```r
F_dist %>%
  data.frame() %>%
  ggplot(aes(x = F_Score, y = Freq,
             label = paste0(Freq * 100, '%'))) +
  geom_bar(stat = 'identity') +
  geom_text(color = 'black', size = 3, vjust = -0.4) +
  scale_y_continuous(expand = c(0, 0, 0, 0.05),
                     labels = scales::percent) +
  ylab(NULL) +
  theme_classic() 
```

<img src="09-factor_basic_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />

`table()` 함수를 통해 각 스코어별 개수를 구한 후 `prop.table()`을 통해 비중으로 변환합니다. 이를 통해 점수별 비중을 살펴보면 3~6점에 상당히 많은 종목이 분포하고 있음이 확인됩니다.


```r
invest_F_Score = F_Score %in% c(9)
KOR_ticker[invest_F_Score, ] %>% 
  select(`종목코드`, `종목명`) %>%
  mutate(`F-Score` = F_Score[invest_F_Score])
```

```
##    종목코드         종목명 F-Score
## 1    007570       일양약품       9
## 2    034230     파라다이스       9
## 3    204270     제이앤티씨       9
## 4    014830         유니드       9
## 5    008730       율촌화학       9
## 6    082920       비츠로셀       9
## 7    025320       시노펙스       9
## 8    234080     JW생명과학       9
## 9    002990       금호산업       9
## 10   047310     파워로직스       9
## 11   067900       와이엔텍       9
## 12   089470      HDC현대EP       9
## 13   104460 디와이피엔에프       9
## 14   014970       삼륭물산       9
## 15   011390       부산산업       9
## 16   051360         토비스       9
## 17   045060           오공       9
## 18   123410   코리아에프티       9
## 19   053620           태양       9
## 20   221840     하이즈항공       9
## 21   021650       한국큐빅       9
## 22   089850     유비벨록스       9
## 23   008370           원풍       9
## 24   030720       동원수산       9
## 25   054040     한국컴퓨터       9
```

F-Score가 9점인 종목의 티커와 종목명을 확인해봅니다. 재무적으로 우량하다고 판단되는 F-Score 9점인 종목은 총 25개가 있습니다.

### 각 지표를 결합하기

이번에는 퀄리티를 측정하는 요소 중 가장 널리 사용되는 수익성 지표를 결합한 포트폴리오를 만들어보겠습니다. 여기서 사용되는 지표는 **자기자본이익률(ROE), 매출총이익(Gross Profit), 영업활동현금흐름(Cash Flow From Operating)**입니다.


```r
library(stringr)
library(ggplot2)
library(dplyr)
library(tidyr)

KOR_fs = readRDS('data/KOR_fs.Rds')
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1,
                      stringsAsFactors = FALSE) 

KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, 'left', 0)
```


```r
if ( lubridate::month(Sys.Date()) %in% c(1,2,3,4) ) {
  num_col = ncol(KOR_fs[[1]]) - 1
} else {
  num_col = ncol(KOR_fs[[1]]) 
}

quality_roe = (KOR_fs$'지배주주순이익' / KOR_fs$'자본')[num_col]
quality_gpa = (KOR_fs$'매출총이익' / KOR_fs$'자산')[num_col]
quality_cfo =
  (KOR_fs$'영업활동으로인한현금흐름' / KOR_fs$'자산')[num_col]

quality_profit =
  cbind(quality_roe, quality_gpa, quality_cfo) %>%
  setNames(., c('ROE', 'GPA', 'CFO'))
```

먼저 재무제표와 티커 파일을 불러온 후 세 가지 지표에 해당하는 값을 구한 뒤 최근년도 데이터만 선택합니다. 그런 다음 `cbind()` 함수를 이용해 지표들을 하나로 묶어줍니다. **역시나 1~4월의 경우 `ncol(KOR_fs[[1]]) - 1 `를 통해 보수적으로 전년도가 아닌 전전년도 회계 데이터를 사용합니다.**



```r
rank_quality = quality_profit %>% 
  mutate_all(list(~min_rank(desc(.))))

cor(rank_quality, use = 'complete.obs') %>%
  round(., 2) %>%
  corrplot(method = 'color', type = 'upper',
           addCoef.col = 'black', number.cex = 1,
           tl.cex = 0.6, tl.srt = 45, tl.col = 'black',
           col =
             colorRampPalette(c('blue', 'white', 'red'))(200),
           mar=c(0,0,0.5,0))
```

<img src="09-factor_basic_files/figure-html/unnamed-chunk-35-1.png" width="70%" style="display: block; margin: auto;" />

`mutate_all()` 함수와 `min_rank()` 함수를 통해 지표별 랭킹을 구하며, 퀄리티 지표는 높을수록 좋은 내림차순으로 계산해야 하므로 `desc()`를 추가합니다.

수익성 지표 역시 서로 간의 상관관계가 낮아, 지표를 통합적으로 고려 시 분산효과를 기대할 수 있습니다.


```r
rank_sum = rank_quality %>%
  rowSums()

invest_quality = rank(rank_sum) <= 30

KOR_ticker[invest_quality, ] %>%
  select(`종목코드`, `종목명`) %>%
  cbind(round(quality_profit[invest_quality, ], 4))
```

```
##      종목코드               종목명    ROE    GPA    CFO
## 10     051900           LG생활건강 0.1836 0.7343 0.1755
## 46     021240               코웨이 0.3090 0.7035 0.1889
## 95     263750             펄어비스 0.2677 0.6178 0.1941
## 117    282330            BGF리테일 0.2432 0.4863 0.2453
## 165    007700                  F&F 0.2278 0.9015 0.2361
## 188    030190         NICE평가정보 0.1820 1.2877 0.1930
## 224    230360           에코마케팅 0.2888 0.7980 0.1526
## 253    214150             클래시스 0.3800 0.5620 0.3430
## 303    067160           아프리카TV 0.2824 0.7348 0.2661
## 308    097520             엠씨넥스 0.3762 0.3863 0.2434
## 316    138080           오이솔루션 0.3309 0.4740 0.2316
## 426    034950         한국기업평가 0.1640 0.5783 0.2015
## 449    119860               다나와 0.2151 1.0830 0.3061
## 594    092130           이크레더블 0.2551 0.6534 0.2268
## 597    220630     해마로푸드서비스 0.1716 0.5911 0.1780
## 621    089970           에이피티씨 0.2387 0.4000 0.1802
## 631    143240       사람인에이치알 0.2291 0.7161 0.2242
## 644    207760           미스터블루 0.2797 1.0257 0.2777
## 685    337930 브랜드엑스코퍼레이션 0.5352 0.9351 0.1346
## 766    248170             샘표식품 0.1707 0.5806 0.1882
## 838    290520             신도기연 0.3101 0.3629 0.1945
## 960    130580         나이스디앤비 0.1764 0.9822 0.1703
## 961    306040         에스제이그룹 0.1902 0.8847 0.1654
## 973    036120          SCI평가정보 0.2008 1.6335 0.2950
## 1139   060850       영림원소프트랩 0.4257 0.5921 0.1908
## 1146   347770                 핌스 0.3691 0.4194 0.1792
## 1189   225330         씨엠에스에듀 0.1576 0.8025 0.2317
## 1290   058630               엠게임 0.1975 0.7753 0.1629
## 1363   225190           삼양옵틱스 0.3461 0.5838 0.2384
## 1509   049720         고려신용정보 0.2933 2.3922 0.1520
```

`rowSums()` 함수를 이용해 종목별 랭킹들의 합을 구합니다. 그 후 세 개 지표 랭킹의 합 기준 랭킹이 낮은 30종목을 선택합니다. 즉 세 가지 수익 지표가 골고루 높은 종목을 선택합니다. 해당 종목들의 티커, 종목명, ROE, GPA, CFO을 출력해 확인합니다.
