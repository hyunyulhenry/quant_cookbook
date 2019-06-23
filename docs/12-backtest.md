# 포트폴리오 백테스트

백테스트란 현재 생각하는 전략을 과거부터 실행하였을 시, 어떠한 성과가 발생하는지 테스트해보는 과정입니다. 과거의 데이터를 기반으로 전략을 실행하는 퀀트 투자에 있어서, 이는 핵심 단계이기도 합니다. 백테스트 결과를 통해 해당 전략의 손익뿐만 아니라 각종 위험을 대략적으로 판단할 수 있으며, 어떤 구간에서 전략이 좋았는지 혹은 나빴는지에 대한 이해도 키울 수 있습니다. 이러한 이해를 바탕으로 퀀트 투자를 지속한다면 단기적으로 수익이 나쁜 구간에서도 그 이유에 대한 객관적인 안목을 키울 수 있으며, 확신을 가지고 전략을 지속할 수 있습니다.

그러나 백테스트를 아무리 보수적으로 혹은 엄밀하게 진행하더라도 이미 일어난 결과를 대상으로 한다는 점에서 정답을 보고 답지를 쓰는 격이라는 점을 항상 명심해야 합니다. 백테스트 수익률만을 보고 투자에 대한 판단을 하거나, 혹은 동일한 수익률이 미래에도 반복될 것이라 믿는다면 이는 백미러를 보고 운전을 하는 매우 위험한 결과를 초래할 수도 있습니다.

R에서 백테스트는 `PerformanceAnalytics` 패키지 내의 `Return.portfolio()` 함수를 사용하여 매우 간단하게 수행할 수 있습니다. 이번 장에서는 해당 함수에 대한 이해와 더불어, 구체적인 사용 방법에 대한 예시로써 **전통적인 주식 60% & 채권 40% 포트폴리오**, **시점 선택 전략**, **동적 자산배분**에 대한 백테스트를 실행합니다.

## `Return.Portfolio()` 함수

프로그래밍을 이용하여 백테스트를 할 경우, 전략이 단순하다면 단 몇 줄 만으로도 테스트가 가능합니다. 그러나 전략이 복잡해지거나 적용해야 할 요소가 많아질 경우, 패키지를 이용하는 것이 효율적인 방법입니다.

`PerformanceAnalytics` 패키지의 `Return.portfolio()` 함수는 백테스트 과정에서 가장 대중적으로 사용되는 함수입니다. 해당 함수의 가장 큰 장점은 각 자산의 수익률과 리밸런싱 비중만 있으면 백테스트 수익률, 턴오버 등을 쉽게 계산할 수 있다는 점이며, 리밸런싱 시점과 수익률의 시점이 일치하지 않아도 된다는 점입니다. 즉, 수익률 데이터는 일간, 리밸런싱 시점은 분기 혹은 연간으로 된 경우에도 매우 쉽게 백테스트를 수행할 수 있습니다.


### 인자목록 살펴보기

먼저 `Return.portfolio()` 함수는 다음과 같은 형태로 구성되어 있으며, 표 \@ref(tab:returnportarg)는 인자의 내용을 정리한 것입니다.


```r
Return.portfolio(R, weights = NULL, wealth.index = FALSE,
  contribution = FALSE, geometric = TRUE, rebalance_on = c(NA, "years",
  "quarters", "months", "weeks", "days"), value = 1, verbose = FALSE, ...)
```


Table: (\#tab:returnportarg)`Return.portfolio()` 함수 내 인자 설명

인자           내용                                                                                                                                                                                                   
-------------  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
R              각 자산 수익률 데이터                                                                                                                                                                                  
weights        각 리밸런싱 시기의 자산 별 목표 비중. 미 입력시 동일비중 포트폴리오를 가정하여 백테스트가 이루짐                                                                                                       
wealth.index   포트폴리오 시작점이 1인 wealth index에 대한 생성여부이며, 디폴트는 FALSE로 설정                                                                                                                        
contribution   포트폴리오 내에서 각 자산 별 성과기여를 나타내는지에 대한 여부이며, 디폴트는 FALSE로 설정                                                                                                              
geometric      포트폴리오 수익률 계산시 복리(기하)수익률 적용 여부이며, 디폴트는 TRUE로써 복리수익률을 계산                                                                                                           
rebalance_on   weight 값이 미입력 혹은 매번 같은 비중일 경우, 리밸런싱 주기를 선택할 수 있음                                                                                                                          
value          초기 포트폴리오 가치를 의미하며, 디폴트는 1                                                                                                                                                            
verbose        부가적인 결과를 표시할지에 대한 여부. 디폴트인 FALSE를 입력할 경우 포트폴리오 수익률만이 시계열 형태로 표시되며, TRUE를 입력할 경우 수익률 외에 자산 별 성과기여, 비중, 성과 등이 리스트 형태로 표현됨 

이 중 가장 중요한 인자는 개별 자산의 수익률인 R과 리밸런싱 시기의 자산 별 목표 비중인 weights 입니다. 매 리밸런싱 시점마다 적용되는 자산 별 비중이 동일할 경우(예: 매월 말 60%대 40% 비중으로 리밸런싱) 상수 형태로 입력하여도 되지만, 시점마다 자산 별 목표비중이 다를 경우 weights는 시계열 형태로 입력되어야 합니다.  

목표 비중을 시계열 형태로 입력할 경우 주의해야 할 점은 다음과 같습니다.

1. 시계열 형태로 인식할 수 있도록, 행이름 혹은 인덱스가 날짜 형태로 입력되어야 합니다.
2. 수익률 데이터와 비중 데이터의 열 개수는 동일해야 하며, 각 열에 해당하는 자산은 동일해야 합니다. 즉, 수익률 데이터의 첫번째 열에 A주식 데이터가 있다면, 비중 데이터의 첫번째 열도 목표 A주식 비중을 입력해야 합니다.
3. 각 시점의 비중의 합은 1이 되어야 합니다. 그렇지 않을 경우 제대로된 수익률이 계산되지 않습니다.

weights에 값을 입력하지 않을 동일비중 포트폴리오를 구성하며, 포트폴리오 리밸런싱은 하지 않습니다. 

### 출력값 살펴보기

해당 함수는 verbose를 TRUE로 설정할 경우 다양한 결과값을 리스트 형태로 반환합니다.


Table: (\#tab:unnamed-chunk-2)`Return.portfolio()` 함수 반환값

결과           내용                                                                                              
-------------  --------------------------------------------------------------------------------------------------
returns        포트폴리오 수익률                                                                                 
contribution   일자 별 개별 자산의 포트폴리오 수익률 기여도                                                      
BOP.Weight     일자 별 개별 자산의 포트폴리오 내 비중 (시작시점). 리밸런싱이 없을 시 직전 기간 EOP.Weight와 동일 
EOP.Weight     일자 별 개별 자산의 포트폴리오 내 비중 (종료시점)                                                 
BOP.Value      일자 별 개별 자산의 가치 (시작시점). 리밸런싱이 없을 시 직전 기간 EOP.Value와 동일                
EOP.Value      일자 별 개별 자산의 가치 (종료시점)                                                               

## 전통적인 60대 40 포트폴리오 백테스트

`Return.portfolio()` 함수의 가장 간단한 예제로써 전통적인 60대 40 포트폴리오를 백테스트 하도록 합니다. 해당 포트폴리오는 주식과 채권에 각각 60%와 40%를 투자하며, 특정 시점 마다 해당 비중을 맞춰주기 위해 리밸런싱을 수행합니다. 매해 말 리밸런싱을 가정하는 예제를 살펴보도록 하겠습니다.


```r
library(quantmod)
library(PerformanceAnalytics)
library(magrittr)

ticker = c('SPY', 'TLT')
getSymbols(ticker)
```

```
## [1] "SPY" "TLT"
```

```r
prices = do.call(cbind, lapply(ticker, function(x) Ad(get(x))))
rets = Return.calculate(prices) %>% na.omit()
```

글로벌 자산의 ETF 데이터 중 주식(S&P 500)과 채권(미국 장기채)에 해당하는 데이터를 다운로드 받은 후, 수익률을 계산하도록 합니다.


```r
cor(rets)
```

```
##              SPY.Adjusted TLT.Adjusted
## SPY.Adjusted     1.000000    -0.434726
## TLT.Adjusted    -0.434726     1.000000
```

`cor()` 함수를 통해 두 자산간의 상관관계를 확인해보면 -0.43로써 매우 낮은 상관관계를 보이며, 강한 분산효과를 기대해볼 수 있습니다.


```r
portfolio = Return.portfolio(R = rets,
                             weights = c(0.6, 0.4),
                             rebalance_on = 'years',
                             verbose = TRUE)
```

`Return.portfolio()` 함수를 이용하여 백테스트를 실행합니다.

1. 자산의 수익률인 R에는 수익률 테이블인 rets 를 입력합니다.
2. 리밸런싱 비중인 weights에는 60%와 40%를 의미하는 c(0.6, 0.4)를 입력합니다.
3. 리밸런싱 시기인 rebalance_on에는 연간 리밸런싱에 해당하는 'years'를 입력합니다. 리밸런싱 주기는 이 외에도 'quarters', 'months', 'weeks', 'days'도 입력이 가능합니다.
4. 결과물들을 리스트로 확인하기 위해 verbose를 TRUE로 설정합니다.

위 과정을 통해 주식과 채권 투자 비중을 각각 60%와 40%로 리밸런싱하는 포트폴리오의 백테스트가 실행됩니다. 표 \@ref(tab:portreturn)는 함수 내에서 포트폴리오의 수익률이 어떻게 계산되는지를 요약한 과정입니다.



<table class="table table-striped table-hover table-bordered table-condensed" style="font-size: 8.5px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">(\#tab:portreturn)`Return.portfolio()` 계산 과정</caption>
 <thead>
<tr>
<th style="border-bottom:hidden" colspan="1"></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">시작금액</div></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="1"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">시작합계</div></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">시작비중</div></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">수익률</div></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">종료금액</div></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="1"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">종료합계</div></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">종료비중</div></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="1"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">최종수익률</div></th>
</tr>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> 1.주식 </th>
   <th style="text-align:right;"> 2.채권 </th>
   <th style="text-align:right;"> 3.1+2 </th>
   <th style="text-align:right;"> 4.주식 </th>
   <th style="text-align:right;"> 5.채권 </th>
   <th style="text-align:right;"> 6.주식 </th>
   <th style="text-align:right;"> 7.채권 </th>
   <th style="text-align:right;"> 8.주식 </th>
   <th style="text-align:right;"> 9.채권 </th>
   <th style="text-align:right;"> 10.8+9 </th>
   <th style="text-align:right;"> 11.주식 </th>
   <th style="text-align:right;"> 12.채권 </th>
   <th style="text-align:right;"> 13.수익률 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2017-12-26 </td>
   <td style="text-align:right;"> 1.603 </td>
   <td style="text-align:right;"> 0.940 </td>
   <td style="text-align:right;"> 2.543 </td>
   <td style="text-align:right;"> 0.630 </td>
   <td style="text-align:right;"> 0.370 </td>
   <td style="text-align:right;"> -0.001 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 1.601 </td>
   <td style="text-align:right;"> 0.943 </td>
   <td style="text-align:right;"> 2.544 </td>
   <td style="text-align:right;"> 0.629 </td>
   <td style="text-align:right;"> 0.371 </td>
   <td style="text-align:right;"> 0.000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2017-12-27 </td>
   <td style="text-align:right;"> 1.601 </td>
   <td style="text-align:right;"> 0.943 </td>
   <td style="text-align:right;"> 2.544 </td>
   <td style="text-align:right;"> 0.629 </td>
   <td style="text-align:right;"> 0.371 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 0.013 </td>
   <td style="text-align:right;"> 1.602 </td>
   <td style="text-align:right;"> 0.956 </td>
   <td style="text-align:right;"> 2.557 </td>
   <td style="text-align:right;"> 0.626 </td>
   <td style="text-align:right;"> 0.374 </td>
   <td style="text-align:right;"> 0.005 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2017-12-28 </td>
   <td style="text-align:right;"> 1.602 </td>
   <td style="text-align:right;"> 0.956 </td>
   <td style="text-align:right;"> 2.557 </td>
   <td style="text-align:right;"> 0.626 </td>
   <td style="text-align:right;"> 0.374 </td>
   <td style="text-align:right;"> 0.002 </td>
   <td style="text-align:right;"> -0.001 </td>
   <td style="text-align:right;"> 1.605 </td>
   <td style="text-align:right;"> 0.955 </td>
   <td style="text-align:right;"> 2.560 </td>
   <td style="text-align:right;"> 0.627 </td>
   <td style="text-align:right;"> 0.373 </td>
   <td style="text-align:right;"> 0.001 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2017-12-29 </td>
   <td style="text-align:right;"> 1.605 </td>
   <td style="text-align:right;"> 0.955 </td>
   <td style="text-align:right;"> 2.560 </td>
   <td style="text-align:right;"> 0.627 </td>
   <td style="text-align:right;"> 0.373 </td>
   <td style="text-align:right;"> -0.004 </td>
   <td style="text-align:right;"> 0.002 </td>
   <td style="text-align:right;"> 1.599 </td>
   <td style="text-align:right;"> 0.956 </td>
   <td style="text-align:right;"> 2.555 </td>
   <td style="text-align:right;"> 0.626 </td>
   <td style="text-align:right;"> 0.374 </td>
   <td style="text-align:right;"> -0.002 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 2018-01-02 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 1.533 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 1.022 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 2.555 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 0.600 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 0.400 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 0.007 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> -0.011 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 1.544 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 1.011 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 2.555 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 0.604 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 0.396 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #D7261E !important;"> 0.000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2018-01-03 </td>
   <td style="text-align:right;"> 1.544 </td>
   <td style="text-align:right;"> 1.011 </td>
   <td style="text-align:right;"> 2.555 </td>
   <td style="text-align:right;"> 0.604 </td>
   <td style="text-align:right;"> 0.396 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 1.554 </td>
   <td style="text-align:right;"> 1.016 </td>
   <td style="text-align:right;"> 2.570 </td>
   <td style="text-align:right;"> 0.605 </td>
   <td style="text-align:right;"> 0.395 </td>
   <td style="text-align:right;"> 0.006 </td>
  </tr>
</tbody>
</table>

먼저 2017-12-27일에 해당하는 데이터를 보면 시작시점에 주식과 채권에는 각각 1.601과 0.943이 투자되어 있으며, 이를 합하면 2.544이 됩니다. 이를 포트폴리오 내 비중으로 환산하면 비중은 각각 0.629과 0.371가 됩니다.

해당일의 주식과 채권의 수익률은 각각 0, 0.013이 되며, 이를 시작금액에 곱하면 종료시점의 금액은 1.602과 0.956가 됩니다. 각각의 금액을 종료금액의 합인 2.557으로 나누게 되면, 포트폴리오 내 비중은 0.626, 0.374로 변하게 됩니다. 포트폴리오 수익률은 2017-12-27 포트폴리오 금액인 2.557을 전일의 포트폴리오 금액인 2.544로 나누어 계산된 값인 0.005가 됩니다.

리밸런싱이 없다면 2017-12-27일의 종료금액과 종료비중은 2017-12-28일의 시작금액과 시작비중에 그대로 적용되며, 위와 동일한 단계를 통해 포트폴리오 수익률이 계산됩니다.

그러나 매해 리밸런싱을 가정했으므로, 첫 영업일인 2018-01-02일에는 포트폴리오 리밸런싱이 이루어집니다. 따라서 전일 2017-12-29일의 종료금액의 합인 2.555을 사전에 정의한 0.6과 0.4에 맞게 각 자산을 시작시점에 매수 혹은 매도하게 됩니다. 이후에는 기존과 동일하게 해당일의 수익률을 곱해 종료시점의 금액과 비중을 구한 후, 포트폴리오 수익률을 계산하게 됩니다.

리밸런싱 전일 종료시점의 비중과 리밸런싱 당일 시작시점의 비중 차이의 절대값을 합하면, 포트폴리오의 턴오버를 계산할 수도 있습니다. 해당 예제에서는 2017-12-29일 종료시점의 비중인 0.626, 0.374와 2018-01-02일 시작시점의 비중인 0.6, 0.4의 차이인 0.026, -0.026의 절대값의 합계인 0.052가 턴오버가 됩니다.

이처럼 리밸런싱을 원하는 시점과 비중을 정의하면, `Return.portfolio()` 함수 내에서는 위의 단계를 거쳐 포트폴리오의 수익률, 시작과 종료시점의 금액 및 비중이 계산되며, 이를 응용하여 턴오버를 계산할 수도 있습니다.


```r
portfolios = cbind(rets, portfolio$returns)
charts.PerformanceSummary(portfolios, main = '60대 40 포트폴리오')
```

<img src="12-backtest_files/figure-html/unnamed-chunk-7-1.png" width="50%" style="display: block; margin: auto;" />

`PerformanceAnalytics` 패키지의 `charts.PerformanceSummary()` 함수는 기간별 수익률을 입력시 누적수익률, 일별수익률, 드로우다운 그래프를 자동으로 그려줍니다. 

검은색 그래프는 주식 수익률(SPY), 붉은색 그래프는 채권 수익률(TLT), 초록색 그래프는 60대 40 포트폴리오 수익률을 의미합니다. 주식과 채권은 상반되는 움직임을 보이며 상승하며, 분산투자 포트폴리오는 각 개별 자산에 비해 훨씬 안정적인 수익률을 보입니다. 


```r
turnover = xts(rowSums(abs(portfolio$BOP.Weight - lag(portfolio$EOP.Weight)), na.rm = TRUE),
               order.by = index(portfolio$BOP.Weight))

chart.TimeSeries(turnover)
```

<img src="12-backtest_files/figure-html/unnamed-chunk-8-1.png" width="50%" style="display: block; margin: auto;" />

전일 종료시점의 비중인 EOP.Weight를 `lag()` 함수를 이용해 한 단계씩 내린 후, 시작시점의 비중인 BOP.Weight와의 차이의 절대값을 더해주면 해당 시점에서의 턴오버가 계산됩니다. 이를 `xts()` 함수를 이용해 시계열 형태로 만들어준 뒤, `chart.TimeSeries()` 함수를 이용해 그래프로 나타내줍니다.

리밸런싱 시점에 해당하는 매해 첫 영업일에 턴오버가 발생하며, 그렇지 않은 날은 매수 혹은 매도가 없으므로 턴오버 역시 0을 기록합니다. 2008년에는 주식과 채권의 등락폭이 심하였으므로 이듬해엔 2009년 리밸런싱으로 인한 턴오버가 심하지만, 이를 제외한 해는 턴오버가 그리 심하지 않습니다.

