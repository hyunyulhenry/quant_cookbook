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
## X268280 X001720 X072710 X016800 X000480 X015360 X004890 
##  0.1960  0.2435  0.2348  0.1514  0.2099  0.2515  0.2178 
## X100250 X117580 X134380 X171120 X024090 X003460 X007330 
##  0.2159  0.2033  0.1820  0.2565  0.2383  0.2345  0.2053 
## X003650 X034590 X040420 X273060 X007590 X005190 X109860 
##  0.2567  0.1846  0.2383  0.1916  0.2417  0.2543  0.2315 
## X084670 X339950 X037440 X221980 X168330 X043100 X033790 
##  0.2523  0.1776  0.2421  0.2448  0.1563  0.1462  0.1878 
## X028040 X069330 
##  0.2143  0.2196
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
##    종목코드               종목명 변동성
## 1    268280           미원에스씨 0.1960
## 2    001720             신영증권 0.2435
## 3    072710           농심홀딩스 0.2348
## 4    016800               퍼시스 0.1514
## 5    000480             조선내화 0.2099
## 6    015360         예스코홀딩스 0.2515
## 7    004890             동일산업 0.2178
## 8    100250           진양홀딩스 0.2159
## 9    117580           대성에너지 0.2033
## 10   134380             미원화학 0.1820
## 11   171120           라이온켐텍 0.2565
## 12   024090               디씨엠 0.2383
## 13   003460             유화증권 0.2345
## 14   007330         푸른저축은행 0.2053
## 15   003650             미창석유 0.2567
## 16   034590         인천도시가스 0.1846
## 17   040420       정상제이엘에스 0.2383
## 18   273060           와이즈버즈 0.1916
## 19   007590           동방아그로 0.2417
## 20   005190             동성화학 0.2543
## 21   109860             동일금속 0.2315
## 22   084670             동양고속 0.2523
## 23   339950           아이비김영 0.1776
## 24   037440                 희림 0.2421
## 25   221980             케이디켐 0.2448
## 26   168330         내츄럴엔도텍 0.1563
## 27   043100           솔고바이오 0.1462
## 28   033790 스카이문스테크놀로지 0.1878
## 29   028040              미래SCI 0.2143
## 30   069330             유아이디 0.2196
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
## X268280 X347860 X339770 X072710 X016800 X000480 X199820 
## 0.18197 0.21093 0.19537 0.23357 0.11837 0.21710 0.23833 
## X129890 X356860 X337930 X053080 X100250 X117580 X134380 
## 0.16439 0.22045 0.23000 0.18735 0.23116 0.20788 0.22721 
## X003460 X244920 X007330 X034590 X318410 X040420 X273060 
## 0.17398 0.11117 0.20719 0.16121 0.16810 0.18686 0.15794 
## X005190 X004450 X109860 X339950 X115310 X037440 X168330 
## 0.23732 0.23913 0.16608 0.22903 0.18706 0.21701 0.18646 
## X043100 X347140 
## 0.15252 0.03673
```

```r
invest_lowvol_weekly = rank(std_12m_weekly) <= 30
KOR_ticker[invest_lowvol_weekly, ] %>%
  select(`종목코드`, `종목명`) %>%
  mutate(`변동성` =
           round(std_12m_weekly[invest_lowvol_weekly], 4))
```

```
##    종목코드               종목명 변동성
## 1    268280           미원에스씨 0.1820
## 2    347860               알체라 0.2109
## 3    339770         교촌에프앤비 0.1954
## 4    072710           농심홀딩스 0.2336
## 5    016800               퍼시스 0.1184
## 6    000480             조선내화 0.2171
## 7    199820         제일전기공업 0.2383
## 8    129890                 앱코 0.1644
## 9    356860               티엘비 0.2205
## 10   337930 브랜드엑스코퍼레이션 0.2300
## 11   053080             원방테크 0.1873
## 12   100250           진양홀딩스 0.2312
## 13   117580           대성에너지 0.2079
## 14   134380             미원화학 0.2272
## 15   003460             유화증권 0.1740
## 16   244920       에이플러스에셋 0.1112
## 17   007330         푸른저축은행 0.2072
## 18   034590         인천도시가스 0.1612
## 19   318410               비비씨 0.1681
## 20   040420       정상제이엘에스 0.1869
## 21   273060           와이즈버즈 0.1579
## 22   005190             동성화학 0.2373
## 23   004450             삼화왕관 0.2391
## 24   109860             동일금속 0.1661
## 25   339950           아이비김영 0.2290
## 26   115310             인포바인 0.1871
## 27   037440                 희림 0.2170
## 28   168330         내츄럴엔도텍 0.1865
## 29   043100           솔고바이오 0.1525
## 30   347140    케이프이에스제4호 0.0367
```

주간 수익률의 변동성이 낮은 30종목을 선택해 종목코드, 종목명, 연율화 변동성을 확인합니다.


```r
intersect(KOR_ticker[invest_lowvol, '종목명'],
          KOR_ticker[invest_lowvol_weekly, '종목명'])
```

```
##  [1] "미원에스씨"     "농심홀딩스"     "퍼시스"        
##  [4] "조선내화"       "진양홀딩스"     "대성에너지"    
##  [7] "미원화학"       "유화증권"       "푸른저축은행"  
## [10] "인천도시가스"   "정상제이엘에스" "와이즈버즈"    
## [13] "동성화학"       "동일금속"       "아이비김영"    
## [16] "희림"           "내츄럴엔도텍"   "솔고바이오"
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
## X068760 X019170 X096530 X196170 X285130 X336260 X003090 
##   3.983  15.835   4.502   3.701   4.369   5.697   4.000 
## X235980 X011000 X100090 X222080 X156100 X018000 X001470 
##   4.144   7.598   3.673   4.528   7.964   3.608   4.481 
## X101360 X109820 X025950 X241840 X083420 X256940 X033310 
##   5.593   7.341   6.727   3.618   3.876   3.877   3.563 
## X217330 X050960 X205470 X058110 X080580 X023960 X045340 
##   4.535   5.594   4.294   7.849  11.487   4.694   6.663 
## X051980 X013720 
##   3.864   4.032
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
## 1    068760     셀트리온제약  3.983
## 2    019170         신풍제약 15.835
## 3    096530             씨젠  4.502
## 4    196170         알테오젠  3.701
## 5    285130         SK케미칼  4.369
## 6    336260       두산퓨얼셀  5.697
## 7    003090             대웅  4.000
## 8    235980         메드팩토  4.144
## 9    011000     진원생명과학  7.598
## 10   100090       삼강엠앤티  3.673
## 11   222080       씨아이에스  4.528
## 12   156100   엘앤케이바이오  7.964
## 13   018000           유니슨  3.608
## 14   001470         삼부토건  4.481
## 15   101360         이엔드디  5.593
## 16   109820       진매트릭스  7.341
## 17   025950         동신건설  6.727
## 18   241840       에이스토리  3.618
## 19   083420       그린케미칼  3.876
## 20   256940       케이피에스  3.877
## 21   033310           엠투엔  3.563
## 22   217330         싸이토젠  4.535
## 23   050960     수산아이앤티  5.594
## 24   205470         휴마시스  4.294
## 25   058110     멕아이씨에스  7.849
## 26   080580       오킨스전자 11.487
## 27   023960 에쓰씨엔지니어링  4.694
## 28   045340       토탈소프트  6.663
## 29   051980     센트럴바이오  3.864
## 30   013720         청보산업  4.032
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
##  1 035720   카카오          1.67   0.42             4.02
##  2 068760   셀트리온제약    3.98   0.88             4.55
##  3 019170   신풍제약       15.8    1.43            11.1 
##  4 011200   HMM             2.84   0.63             4.51
##  5 096530   씨젠            4.5    1.07             4.22
##  6 285130   SK케미칼        4.37   0.83             5.27
##  7 247540   에코프로비엠    2.48   0.61             4.08
##  8 336260   두산퓨얼셀      5.7    0.99             5.73
##  9 112610   씨에스윈드      3.44   0.7              4.94
## 10 235980   메드팩토        4.14   0.85             4.88
## 11 011000   진원생명과학    7.6    1.49             5.1 
## 12 100090   삼강엠앤티      3.67   0.83             4.44
## 13 222080   씨아이에스      4.53   0.82             5.53
## 14 156100   엘앤케이바이오…   7.96   0.91             8.72
## 15 002840   미원상사        1.21   0.26             4.57
## 16 001470   삼부토건        4.48   0.78             5.77
## 17 016710   대성홀딩스      2.42   0.3              8.13
## 18 101360   이엔드디        5.59   0.87             6.43
## 19 109820   진매트릭스      7.34   1.33             5.51
## 20 025950   동신건설        6.73   1.14             5.89
## 21 241840   에이스토리      3.62   0.88             4.11
## 22 083420   그린케미칼      3.88   0.7              5.53
## 23 023800   인지컨트롤스    3.54   0.81             4.39
## 24 217330   싸이토젠        4.53   0.84             5.38
## 25 050960   수산아이앤티    5.59   0.91             6.14
## 26 058110   멕아이씨에스    7.85   1.31             6   
## 27 080580   오킨스전자     11.5    0.86            13.4 
## 28 023960   에쓰씨엔지니어링…   4.69   0.94             5   
## 29 045340   토탈소프트      6.66   0.89             7.51
## 30 013720   청보산업        4.03   0.68             5.94
```

티커와 종목명, 누적수익률, 변동성, 위험조정 수익률을 확인할 수 있습니다.


```r
intersect(KOR_ticker[invest_mom, '종목명'],
          KOR_ticker[invest_mom_sharpe, '종목명'])
```

```
##  [1] "셀트리온제약"     "신풍제약"        
##  [3] "씨젠"             "SK케미칼"        
##  [5] "두산퓨얼셀"       "메드팩토"        
##  [7] "진원생명과학"     "삼강엠앤티"      
##  [9] "씨아이에스"       "엘앤케이바이오"  
## [11] "삼부토건"         "이엔드디"        
## [13] "진매트릭스"       "동신건설"        
## [15] "에이스토리"       "그린케미칼"      
## [17] "싸이토젠"         "수산아이앤티"    
## [19] "멕아이씨에스"     "오킨스전자"      
## [21] "에쓰씨엔지니어링" "토탈소프트"      
## [23] "청보산업"
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
## 1    000210       대림산업 0.1902
## 2    088350       한화생명 0.1905
## 3    000880           한화 0.1281
## 4    138930    BNK금융지주 0.2087
## 5    000150           두산 0.1430
## 6    032190     다우데이타 0.1827
## 7    009970 영원무역홀딩스 0.2001
## 8    001430     세아베스틸 0.2170
## 9    003300     한일홀딩스 0.1753
## 10   058650     세아홀딩스 0.1001
## 11   001940    KISCO홀딩스 0.2011
## 12   005720           넥센 0.1232
## 13   092230      KPX홀딩스 0.2049
## 14   036530      S&T홀딩스 0.1539
## 15   002030         아세아 0.1383
## 16   003030   세아제강지주 0.1409
## 17   054800 아이디스홀딩스 0.2099
## 18   005990     매일홀딩스 0.2044
## 19   009200     무림페이퍼 0.1633
## 20   040610           SG&G 0.1589
## 21   016250  SGC이테크건설 0.1630
## 22   050120   라이브플렉스 0.1025
## 23   012320   경동인베스트 0.1709
## 24   036000         예림당 0.2189
## 25   005010         휴스틸 0.1459
## 26   025530      SJM홀딩스 0.1887
## 27   006200 한국전자홀딩스 0.1793
## 28   058220         아리온 0.0184
## 29   114570 지스마트글로벌 0.1483
## 30   158310   스타모빌리티 0.2081
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
## 83     078930               GS  6.79 0.34 2.33 0.21
## 105    001040               CJ 12.73 0.23 0.88 0.10
## 109    000210         대림산업  1.93 0.19 1.35 0.13
## 277    000150             두산  2.32 0.14 1.24 0.05
## 284    003380         하림지주 14.65 0.24 1.88 0.11
## 411    009970   영원무역홀딩스  4.26 0.20 1.82 0.19
## 473    093050               LF  6.42 0.31 2.84 0.23
## 517    084690       대상홀딩스  5.38 0.32 1.97 0.11
## 606    004690           삼천리  8.89 0.24 1.06 0.10
## 607    006840         AK홀딩스 12.31 0.24 1.27 0.09
## 648    001390         KG케미칼  3.17 0.23 2.08 0.15
## 657    058650       세아홀딩스  9.86 0.10 0.83 0.06
## 731    001940      KISCO홀딩스  6.00 0.20 3.96 0.23
## 779    005720             넥센  4.20 0.12 0.77 0.11
## 784    092230        KPX홀딩스  7.06 0.20 2.67 0.24
## 787    008060             대덕  3.66 0.23 1.32 0.22
## 791    036530        S&T홀딩스  4.00 0.15 2.81 0.17
## 905    002030           아세아  4.19 0.14 0.90 0.13
## 996    065130     탑엔지니어링  4.78 0.46 3.57 0.13
## 1092   003960         사조대림  1.89 0.37 2.02 0.12
## 1206   003480 한진중공업홀딩스  4.69 0.39 2.12 0.16
## 1207   013570           디와이  8.07 0.28 1.66 0.15
## 1337   005710         대원산업  2.94 0.37 3.25 0.17
## 1352   005990       매일홀딩스  5.19 0.20 1.17 0.07
## 1365   267290     경동도시가스  4.55 0.33 3.28 0.08
## 1447   101330         모베이스  2.15 0.29 1.20 0.15
## 1478   002880       대유에이텍  9.68 0.41 2.38 0.08
## 1571   016250    SGC이테크건설  4.36 0.16 0.89 0.05
## 1643   002920         유성기업  4.55 0.26 2.56 0.30
## 1734   012320     경동인베스트  7.78 0.17 2.19 0.26
```

`rowSums()` 함수를 이용해 종목별 랭킹들의 합을 구해줍니다. 그 후 네 개 지표 랭킹의 합 기준 랭킹이 낮은 30종목을 선택합니다. 즉 하나의 지표보다 네 개 지표가 골고루 낮은 종목을 선택합니다. 해당 종목들의 티커, 종목명과 가치지표를 확인할 수 있습니다.



```r
intersect(KOR_ticker[invest_pbr, '종목명'],
          KOR_ticker[invest_value, '종목명'])
```

```
##  [1] "대림산업"       "두산"           "영원무역홀딩스"
##  [4] "세아홀딩스"     "KISCO홀딩스"    "넥센"          
##  [7] "KPX홀딩스"      "S&T홀딩스"      "아세아"        
## [10] "매일홀딩스"     "SGC이테크건설"  "경동인베스트"
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
  num_col = str_which(colnames(KOR_fs[[1]]), as.character(lubridate::year(Sys.Date()) - 2))
} else {
  num_col = str_which(colnames(KOR_fs[[1]]), as.character(lubridate::year(Sys.Date()) - 1))
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

`num_col` 변수에 원하는 열의 위치를 구해줍니다. **1월~4월에 데이터를 받을 경우 전년도 재무제표가 일부만 들어오는 경향이 있으므로, 전전년도 데이터를 사용해야 합니다.** 따라서 `Sys.Date()` 함수를 통해 현재 날짜를 추출한 후, lubridate 패키지의 `month()` 함수를 이용해 해당 월을 계산합니다. `str_which()` 함수를 이용해, 만일 현재 날짜가 1~4월인 경우 열 이름이 2년전 년도를 포함하는 부분을(예: 만일 오늘이 2021년 1월 이라면 열 이름중 2019가 포함된 곳), 그렇지 않을 경우(5~12월) 열 이름이 1년전 년도를 포함하는 부분을(예: 만일 오늘이 2021년 5월 이라면 열 이름중 2020가 포함된 곳) 선택합니다.

`as.integer()` 함수는 TRUE일 경우 1을 반환하고 FALSE일 경우 0을 반환하는 함수로서, F-Score 지표의 점수를 매기는 데 매우 유용합니다. 점수 기준은 다음과 같습니다.

1. ROA가 양수면 1점, 그렇지 않으면 0점
2. 영업활동현금흐름이 양수면 1점, 그렇지 않으면 0점
3. 최근 ROA가 전년 대비 증가했으면ROA[, num_col] > 0 1점, 그렇지 않으면 0점
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
## 0.003 0.051 0.078 0.157 0.193 0.179 0.158 0.110 0.058 
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
## 1    009900       명신산업       9
## 2    034230     파라다이스       9
## 3    007570       일양약품       9
## 4    204270     제이앤티씨       9
## 5    008730       율촌화학       9
## 6    014830         유니드       9
## 7    002990       금호산업       9
## 8    234080     JW생명과학       9
## 9    082920       비츠로셀       9
## 10   047310     파워로직스       9
## 11   025320       시노펙스       9
## 12   067900       와이엔텍       9
## 13   089470      HDC현대EP       9
## 14   104460 디와이피엔에프       9
## 15   014970       삼륭물산       9
## 16   051360         토비스       9
## 17   011390       부산산업       9
## 18   123410   코리아에프티       9
## 19   221840     하이즈항공       9
## 20   045060           오공       9
## 21   089850     유비벨록스       9
## 22   053620           태양       9
## 23   021650       한국큐빅       9
## 24   008370           원풍       9
## 25   054040     한국컴퓨터       9
## 26   030720       동원수산       9
```

F-Score가 9점인 종목의 티커와 종목명을 확인해봅니다. 재무적으로 우량하다고 판단되는 F-Score 9점인 종목은 총 26개가 있습니다.

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
  num_col = str_which(colnames(KOR_fs[[1]]), as.character(lubridate::year(Sys.Date()) - 2))
} else {
  num_col = str_which(colnames(KOR_fs[[1]]), as.character(lubridate::year(Sys.Date()) - 1))
}

quality_roe = (KOR_fs$'지배주주순이익' / KOR_fs$'자본')[num_col]
quality_gpa = (KOR_fs$'매출총이익' / KOR_fs$'자산')[num_col]
quality_cfo =
  (KOR_fs$'영업활동으로인한현금흐름' / KOR_fs$'자산')[num_col]

quality_profit =
  cbind(quality_roe, quality_gpa, quality_cfo) %>%
  setNames(., c('ROE', 'GPA', 'CFO'))
```

먼저 재무제표와 티커 파일을 불러온 후 세 가지 지표에 해당하는 값을 구한 뒤 최근년도 데이터만 선택합니다. 그런 다음 `cbind()` 함수를 이용해 지표들을 하나로 묶어줍니다. **역시나 1~4월의 경우 전년도가 아닌 전전년도 회계 데이터를 사용합니다.**



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
## 15     051900           LG생활건강 0.1836 0.7343 0.1755
## 50     352820               빅히트 0.4254 0.5551 0.2526
## 53     021240               코웨이 0.3090 0.7035 0.1889
## 89     263750             펄어비스 0.2677 0.6178 0.1941
## 121    282330            BGF리테일 0.2432 0.4863 0.2453
## 169    007700                  F&F 0.2278 0.9015 0.2361
## 180    030190         NICE평가정보 0.1820 1.2877 0.1930
## 235    214150             클래시스 0.3800 0.5620 0.3430
## 251    230360           에코마케팅 0.2888 0.7980 0.1526
## 257    097520             엠씨넥스 0.3762 0.3863 0.2434
## 293    067160           아프리카TV 0.2824 0.7348 0.2661
## 370    138080           오이솔루션 0.3309 0.4740 0.2316
## 459    339770         교촌에프앤비 0.3678 0.6078 0.2758
## 514    119860               다나와 0.2151 1.0830 0.3061
## 680    143240       사람인에이치알 0.2291 0.7161 0.2242
## 726    207760           미스터블루 0.2797 1.0257 0.2777
## 733    092130           이크레더블 0.2551 0.6534 0.2268
## 876    337930 브랜드엑스코퍼레이션 0.5352 0.9351 0.1346
## 1006   306040         에스제이그룹 0.1902 0.8847 0.1654
## 1111   130580         나이스디앤비 0.1764 0.9822 0.1703
## 1118   036120          SCI평가정보 0.2008 1.6335 0.2950
## 1221   335890                 비올 0.3763 0.6860 0.4132
## 1251   317240           TS트릴리온 0.2459 1.3571 0.1460
## 1275   244920       에이플러스에셋 0.1989 1.0933 0.1457
## 1303   060850       영림원소프트랩 0.4257 0.5921 0.1908
## 1305   058630               엠게임 0.1975 0.7753 0.1629
## 1508   225330         씨엠에스에듀 0.1576 0.8025 0.2317
## 1518   225190           삼양옵틱스 0.3461 0.5838 0.2384
## 1616   049720         고려신용정보 0.2933 2.3922 0.1520
## 1769   339950           아이비김영 0.4188 0.9356 0.3723
```

`rowSums()` 함수를 이용해 종목별 랭킹들의 합을 구합니다. 그 후 세 개 지표 랭킹의 합 기준 랭킹이 낮은 30종목을 선택합니다. 즉 세 가지 수익 지표가 골고루 높은 종목을 선택합니다. 해당 종목들의 티커, 종목명, ROE, GPA, CFO을 출력해 확인합니다.
