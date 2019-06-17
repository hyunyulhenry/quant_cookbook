# 크롤링 이해하기

앞선 장에서 볼 수 있듯이 API를 이용할 경우 데이터를 매우 쉽게 수집할 수 있지만, 국내 주식 데이터를 다운로드 받기에는 한계가 있으며, 우리가 원하는 데이터가 API의 형태로 제공된다는 보장도 없습니다. 따라서 우리는 필요한 데이터를 얻기 위해 직접 찾아나서야 합니다.

다행히도 금융 사이트들에는 주가, 재무정보 등 우리가 원하는 대부분의 주식 정보가 제공되고 있으며, API를 활용할 수 없는 경우에도 크롤링을 통해 이러한 데이터를 수집할 수 있습니다.

크롤링 혹은 스크래핑이란 웹사이트에서 원하는 정보를 수집하는 기술입니다. 대부분의 금융 사이트들이 간단한 형태로 작성되어 있어, 몇 가지 기술만 익히면 어렵지 않게 데이터를 크롤링 할 수 있습니다. 그러나 크롤링에 대한 대부분의 강의나 설명이 파이썬을 이용한 방법으로써, 초보자가 R을 이용한 크롤링을 배우는데는 어려움이 있습니다. 

해당 장에서는 크롤링에 대한 간단한 설명과 예제를 살펴보도록 하겠습니다.

크롤링을 할 때는 주의해야 할 점이 있습니다. 특정 사이트의 페이지를 쉬지 않고 크롤링을 하는 행위를 무한 크롤링이라 합니다. 이러한 경우 해당 사이트의 자원을 독점하게 되어 타인의 사용을 막게 되며, 사이트에 부하를 주게 됩니다. 일부 사이트에서는 동일한 IP로 쉬지 않고 크롤링을 할 경우 접속을 막아버리는 경우도 있습니다. 따라서 하나의 페이지를 크롤링 한 후, 1~2초 가량 정지한 후 다시 다음 페이지를 크롤링 할 필요가 있습니다.

## GET과 POST 방식 이해하기

우리가 인터넷에 접속하여 서버에 파일을 요청하면, 서버는 이에 해당하는 파일을 우리에게 보내줍니다. 이러한 과정을 사람이 수행하기 편하고 시각적으로 보기 편하도록 만들어 진 것이 크롬과 같은 웹브라우저 이며, 서버의 주소를 기억하기 쉽게하기 위해 만든 것이 인터넷 주소 입니다. 우리가 서버에 데이터를 요청하는 형태는 다양하지만 크롤링에서는 주로 GET과 POST 방식을 사용합니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_flow.png" alt="클라이언트와 서버 간의 요청/응답 과정" width="502" />
<p class="caption">(\#fig:unnamed-chunk-1)클라이언트와 서버 간의 요청/응답 과정</p>
</div>

### GET 방식

GET 방식은 인터넷 주소를 기준으로, 이에 해당하는 데이터나 파일을 요청하는 것입니다. 주로 클라이언트가 요청하는 쿼리를 앰퍼샌드(&) 혹은 물음표(?) 형식으로 결합하여 서버에 전달됩니다.

한경컨센서스^[http://hkconsensus.hankyung.com/]에 접속한 후 전체 REPORT를 선택하면, 홈페이지의 주소 뒤에 **/apps.analysis/analysis.list**가 붙으며 이에 해당하는 페이지의 내용을 보여줍니다. 상단의 탭에서 기업을 선택하면, 주소의 끝부분에 **?skinType=business**가 추가되며 이에 해당하는 페이지의 내용을 보여줍니다. 즉, 해당 페이지는 GET 방식을 사용하고 있으며 입력종류는 skinType, 이에 해당하는 기업 탭의 입력값은 business 임을 알 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_hk.png" alt="한경 컨센서스 기업 REPORT 페이지" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-2)한경 컨센서스 기업 REPORT 페이지</p>
</div>

이번에는 파생 탭을 선택하여 봅니다. 역시나 홈페이지 주소가 변경되며 해당 주소에 맞는 내용이 나타납니다. 주소의 끝부분이 **?skinType=derivative** 로 변경되며, 입력 값이 변경됨에 따라 페이지의 내용이 이에 맞게 변하는 모습이 확인됩니다. 여러 다른 탭들을 눌러보면 **?skinType=** 뒷부분의 입력값이 변함에 따라 이에 해당하는 페이지로 내용이 변경됨이 확인됩니다.

다시 기업 탭을 선택한 후, 다음 페이지를 확인하기 위해 하단의 2를 클릭합니다. 기존 주소인 **?skinType=business** 뒤에 추가로 **sdate**와 **edate**, 그리고 **now_page** 쿼리가 추가됨이 확인됩니다. sdate에 검색 기간의 시작시점, edate에 검색 기간의 종료시점, now_page에 원하는 페이지를 수기로 입력해도 이에 해당하는 페이지의 데이터를 보여줍니다. 이처럼 GET 방식으로 데이터를 요청할 경우, 웹 페이지 주소를 수정하여 원하는 종류의 데이터를 받아올 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_hk2.png" alt="쿼리 추가로 인한 url의 변경" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-3)쿼리 추가로 인한 url의 변경</p>
</div>

### POST 방식

POST 방식은 사용자가 필요한 값을 추가해서 요청하는 방법입니다. GET 방식과의 차이는 클라이언트가 요청하는 쿼리를 body에 넣어서 전송하므로, 요청 내역을 직접적으로 볼 수 없습니다.

한국거래소 상장공시시스템^[http://kind.krx.co.kr/]에 접속하여 전체메뉴보기를 누른 후, 상장법인상세정보 중 상장종목현황을 선택합니다. 웹 페이지 주소가 바뀌며, 상장종목현황이 보여집니다. 

<div class="figure" style="text-align: center">
<img src="images/crawl_corp_list.png" alt="상장공시시스템의 상장종목현황 메뉴" width="412" />
<p class="caption">(\#fig:unnamed-chunk-4)상장공시시스템의 상장종목현황 메뉴</p>
</div>

이번엔 조회일자를 2017-12-28로 선택한 후, 검색을 눌러보도록 합니다. 페이지의 내용은 선택일 기준으로 변경되었지만, 주소는 변경되지 않고 그대로 남아있습니다. GET 방식에서는 선택항목에 따라 웹 페이지 주소가 변경되었지만, POST 방식을 사용하여 서버에 데이터를 요청하는 해당 사이트는 그렇지 않음이 확인됩니다.

POST 방식의 데이터 요청과정을 살펴보기 위해서는 개발자도구 이용해야 하며, 크롬 브라우저에서 F12 키를 눌러 해당 화면을 열 수 있습니다. 개발자도구 화면을 연 상태에서 다시 한번 '검색'을 클릭해 봅니다. Network 탭을 클릭하면, '검색'을 클릭함과 함게 브라우저와 서버간의 통신 과정을 살펴볼 수 있습니다. 이 중 **listedIssueStatus.do** 라는 항목이 POST 형태임을 알 수 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_corp_list_2.png" alt="크롬 개발자도구의 Network 화면" width="962" />
<p class="caption">(\#fig:unnamed-chunk-5)크롬 개발자도구의 Network 화면</p>
</div>

해당 메뉴를 클릭하면 통신 과정을 좀 더 자세히 알 수 있습니다. 가장 하단의 Form Data에 서버에 데이터를 요청하는 내역이 있습니다. method에는 readListIssueStatus, selDate에는 2017-12-28라는 값이 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_corp_list_3.png" alt="POST 방식의 서버 요청 내역" width="471" />
<p class="caption">(\#fig:unnamed-chunk-6)POST 방식의 서버 요청 내역</p>
</div>

이처럼 POST 방식은 요청하는 데이터에 대한 쿼리가 GET 방식처럼 url을 통해 전송되는 것이 아닌 body를 통해 전송되므로, 이에 대한 정보는 웹브라우저를 통해 확인할 수는 없습니다.

## 크롤링 예제

크롤링의 일반적인 과정은 `httr` 패키지의 `GET()` 혹은 `POST()` 함수를 이용하여 데이터를 다운로드 받은 후, `rvest` 패키지의 함수들을 이용하여 원하는 데이터를 찾아내는 과정으로 이루어집니다. 해당 장에서는 GET 방식의 예제로 금융 실시간 속보의 제목을 추출하는 방법을, POST 방식의 예제로 기업공시채널에서 오늘의 공시를 추출하는 방법을, 마지막으로 태그와 속성, 페이지 네비게이션 값을 결합하여 국내 상장 주식의 종목명 및 티커를 추출하는 방법에 대해 알아보도록 하겠습니다.

### 금융 속보 크롤링

크롤링의 간단한 예제로 금융 속보의 제목을 추출해 보도록 하겠습니다. 먼저 네이버 금융에 접속한 후 뉴스 → 실시간 속보^[https://finance.naver.com/news/news_list.nhn?mode=LSS2D&section_id=101&section_id2=258]를 선택해 줍니다. 이 중 뉴스의 제목에 해당하는 텍스트만 추출하고자 합니다. 

뉴스 제목 부분에 마우스를 올려둔 후 우클릭 → 검사를 선택할 경우 개발자도구 화면이 열리며, 해당 글자가 html 내에서 어떤 부분에 위치하는지 확인할 수 있습니다. 해당 제목은 dl 태그 → dd 태그의 articleSubject 클래스 → a 태그 중 title 속성에 위치하고 있습니다. 태그와 속성의 차이가 이해되지 않으시는 분은 [태그와 속성] 부분을 다시 살펴보시기 바랍니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_naver_news.png" alt="실시간 속보의 제목 부분 html" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-7)실시간 속보의 제목 부분 html</p>
</div>

먼저 해당 페이지의 내용을 R로 불러오도록 하겠습니다.


```r
library(rvest)
library(httr)

url = 'https://finance.naver.com/news/news_list.nhn?mode=LSS2D&section_id=101&section_id2=258'
data = GET(url)

print(data)
```

```
## Response [https://finance.naver.com/news/news_list.nhn?mode=LSS2D&section_id=101&section_id2=258]
##   Date: 2019-06-17 14:32
##   Status: 200
##   Content-Type: text/html;charset=EUC-KR
##   Size: 57 kB
## 
## 
## 
## 
## 
## 
## 
## 
## <!--  global include -->
## 
## ...
```

먼저 url 변수에 해당 주소를 입력한 후, `GET()` 함수를 이용하여 해당 페이지의 내용을 받아 data 변수에 저장합니다. data 변수를 확인해보면 Status가 200, 즉 데이터가 이상없이 받아졌으며, 인코딩은 EUC-KR 타입으로 되어 있습니다. 

우리는 개발자도구 화면을 통해 제목에 해당하는 부분이 dl 태그 → dd 태그의 articleSubject 클래스 → a 태그 중 title 속성에 위치하고 있음을 살펴보았습니다. 이를 활용해 제목 부분만을 추출하는 방법은 다음과 같습니다.


```r
data_title = data %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes('dl') %>%
  html_nodes('.articleSubject') %>%
  html_nodes('a') %>%
  html_attr('title')
```

1. 먼저 `read_html()` 함수를 이용하여 해당 페이지의 html 내용을 읽어오며, 인코딩은 'EUC-KR'로 셋팅해주도록 합니다. 
2. `html_nodes()` 함수는 해당 태그를 추출하는 함수로써, `dl` 태그에 해당하는 부분을 추출합니다.
3. `html_nodes()` 함수를 이용하여 articleSubject 클래스에 해당하는 부분을 추출할 수 있으며, 클래스 속성의 경우 이름 앞에 콤마(.)를 붙여주어야 합니다.
4. `html_nodes()` 함수를 이용하여 a 태그를 추출합니다.
5. `html_attr`은 속성을 추출하는 함수로써, title에 해당하는 부분만을 추출합니다.

해당 과정을 거쳐 data_title에는 실시간 속보의 제목만이 저장되게 됩니다. 이처럼 개발자도구 화면을 통해 내가 추출하고자 하는 데이터가 html 중 어디에 위치하고 있는지 먼저 확인을 하면, 어렵지 않게 원하는 데이터를 읽어올 수 있습니다.


```r
print(data_title)
```

```
##  [1] "YG엔터 '경찰 수사전담팀 구성' 방침에 하락 마감…YG플러스도"                
##  [2] "뉴욕증시, FOMC 결과 대기 혼조 출발"                                        
##  [3] "상하이-런던 주식 교차거래 '후룬퉁' 개시(종합)"                             
##  [4] "[뉴스8 단신] 필리핀, 보라카이 운항 허가 취소…에어부산 '날벼락'"           
##  [5] "[숫자뉴스] 56%"                                                            
##  [6] "계열사에 '회장님표' 김치·와인 강매한 태광 21억 과징금"                    
##  [7] "\"하는 일도 없는데\" 펀드 판매보수 꼬박꼬박"                               
##  [8] "17일 장 마감 후 주요 종목뉴스"                                             
##  [9] "삼정KPMG, 26일 산업통상자원부와 수입규제 대응전략 세미나 개최"             
## [10] "[표]유형별 펀드 자금 동향(6월 14일)"                                       
## [11] "한국거래소, 현대일렉트릭 등 공매도 과열 종목 지정"                         
## [12] "[분석] '검은 대행진' 홍콩發 ELS 주의보"                                    
## [13] "바이오로그디바이스, 해성옵틱스 주식 80억원에 취득 결정"                    
## [14] "메디톡스 \"주주 고발 관련 수사기관 연락 전혀 없었다\""                     
## [15] "골드퍼시픽, '다나은' 주식 105억원에 양수 결정"                             
## [16] "키움증권, 자기주식 50만주 취득 결정"                                       
## [17] "신한제5호기업인수목적, 19일 코스닥시장 신규상장"                           
## [18] "[표]아시아 주요 증시 동향(6월 17일)"                                       
## [19] "메디톡스 '주주들 정현호 대표 고발' 보도에 \"수사기관 연락 받은 사실 없다\""
## [20] "디지캡 \"다산일렉트론 인수로 시너지 기대\""
```

### 기업공시채널에서 오늘의 공시 불러오기

한국거래소 상장공시시스템에 접속한 후 오늘의 공시 → 전체 → 더보기를 선택하여 전체 공시내용을 확인할 수 있습니다. 

<div class="figure" style="text-align: center">
<img src="images/crawl_kind.png" alt="오늘의공시 확인하기" width="526" />
<p class="caption">(\#fig:unnamed-chunk-11)오늘의공시 확인하기</p>
</div>

해당 페이지에서 날짜를 변경할 경우, 페이지의 내용은 해당일의 공시로 변경되지만 url은 변경되지 않습니다. 이처럼 POST 방식의 경우 요청하는 데이터에 대한 쿼리가 body의 형태를 통해 전송되므로, 개발자도구 화면을 통해 해당 쿼리에 대한 내용을 확인할 수 있습니다. 

개발자도구 화면을 연 상태에서 조회일자를 2018-12-28로 선택한 후 Network 탭의 **todaydisclosure.do** 항목을 살펴보면 Form Data를 통해 서버에 데이터를 요청하는 내역을 확인할 수 있습니다. 여러 항목 중 selDate 부분이 우리가 선택한 일자로 설정되어 있습니다. 

<div class="figure" style="text-align: center">
<img src="images/crawl_kind_post.png" alt="POST 방식의 데이터 요청" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-12)POST 방식의 데이터 요청</p>
</div>

POST 방식으로 쿼리를 요청하는 방법을 코드로 나타내면 다음과 같습니다. 


```r
library(httr)
library(rvest)

Sys.setlocale("LC_ALL", "English")
```

```
## [1] "LC_COLLATE=English_United States.1252;LC_CTYPE=English_United States.1252;LC_MONETARY=English_United States.1252;LC_NUMERIC=C;LC_TIME=English_United States.1252"
```

```r
url = 'http://kind.krx.co.kr/disclosure/todaydisclosure.do'
data = POST(url, body = 
       list(
         method = 'searchTodayDisclosureSub',
         currentPageSize = '15',
         pageIndex = '1',
         orderMode = '0',
         orderStat = 'D',
         forward = 'todaydisclosure_sub',
         chose = 'S',
         todayFlag = 'Y',
         selDate = '2018-12-28'
       ))

data = read_html(data) %>%
  html_table(fill = TRUE) %>%
  .[[1]]

Sys.setlocale("LC_ALL", "Korean")
```

```
## [1] "LC_COLLATE=Korean_Korea.949;LC_CTYPE=Korean_Korea.949;LC_MONETARY=Korean_Korea.949;LC_NUMERIC=C;LC_TIME=Korean_Korea.949"
```

1. 한글로 작성된 페이지를 크롤링 할 경우 오류가 발생하는 경우가 종종 있으므로, `Sys.setlocale()` 함수를 통해 로케일 언어를 영어로 설정 해줍니다.
2. `POST()` 함수를 통해 해당 url에 원하는 쿼리를 요청해주며, 쿼리는 body 내에 list 형태로 입력해주도록 합니다. 해당 값은 개발자도구 화면의 Form Data와 동일하게 입력해주며, marketType과 같이 값이 존재하지 않는 항목은 입력하지 않아도 됩니다.
3. `read_html()` 함수를 이용하여 해당 페이지의 html 내용을 읽어옵니다.
4. `html_table()` 함수는 테이블 형태의 데이터를 읽어오는 함수입니다. 셀 간 병합이 된 열이 존재하므로 fill=TRUE 를 추가해주도록 합니다.
5. `.[[1]]`를 통해 첫번째 리스트를 선택해 줍니다.
6. 한글을 읽기 위해 `Sys.setlocale()` 함수를 통해 로케일 언어를 다시 Korean으로 변경해 줍니다.

저장된 데이터를 확인하면 화면과 동일한 내용이 출력됩니다.


```r
print(head(data))
```

```
##      NA           NA                                          NA
## 1 18:32     화신테크                                최대주주변경
## 2 18:26 에스제이케이 증권 발행결과(자율공시)(제3자배정 유상증자)
## 3 18:11     아이엠텍               [정정]유상증자결정(제3자배정)
## 4 18:10 시그넷이브이                          유형자산 양수 결정
## 5 18:09                         자기주식매매신청내역(코스닥시장)
## 6 18:09                                 대량매매내역(코스닥시장)
##               NA                             NA
## 1       화신테크 공시차트\r\n\t\t\t\t\t주가차트
## 2   에스제이케이 공시차트\r\n\t\t\t\t\t주가차트
## 3       아이엠텍 공시차트\r\n\t\t\t\t\t주가차트
## 4   시그넷이브이 공시차트\r\n\t\t\t\t\t주가차트
## 5 코스닥시장본부                               
## 6 코스닥시장본부
```

POST 형식의 경우 body에 들어가는 쿼리 내용을 바꾸어 원하는 데이터를 받을수 있습니다. 만일 2019년 1월 4일 공시를 확인하고자 할 경우, 위의 코드에서 selDate만 '2019-01-04'로 변경해주면 됩니다. 아래 코드의 출력 결과물을 2019년 1월 4일 공시와 확인하면 동일한 결과임을 확인할 수 있습니다.


```r
Sys.setlocale("LC_ALL", "English")
```

```
## [1] "LC_COLLATE=English_United States.1252;LC_CTYPE=English_United States.1252;LC_MONETARY=English_United States.1252;LC_NUMERIC=C;LC_TIME=English_United States.1252"
```

```r
url = 'http://kind.krx.co.kr/disclosure/todaydisclosure.do'
data = POST(url, body = 
       list(
         method = 'searchTodayDisclosureSub',
         currentPageSize = '15',
         pageIndex = '1',
         orderMode = '0',
         orderStat = 'D',
         forward = 'todaydisclosure_sub',
         chose = 'S',
         todayFlag = 'Y',
         selDate = '2019-01-04'
       ))

data = read_html(data) %>%
  html_table(fill = TRUE) %>%
  .[[1]]

Sys.setlocale("LC_ALL", "Korean")
```

```
## [1] "LC_COLLATE=Korean_Korea.949;LC_CTYPE=Korean_Korea.949;LC_MONETARY=Korean_Korea.949;LC_NUMERIC=C;LC_TIME=Korean_Korea.949"
```

```r
print(head(data))
```

```
##      NA           NA
## 1 18:18       휴벡셀
## 2 18:15 케이엠더블유
## 3 18:15 스튜디오썸머
## 4 18:14 스튜디오썸머
## 5 18:10   헬릭스미스
## 6 18:10     KJ프리텍
##                                                                NA
## 1                                             [정정]최대주주 변경
## 2                                불성실공시법인지정예고(공시변경)
## 3 [정정]최대주주 변경을 수반하는 주식 담보제공 계약 해제ㆍ취소 등
## 4          [정정]최대주주 변경을 수반하는 주식 담보제공 계약 체결
## 5                     공매도 과열종목 지정(공매도 거래 금지 적용)
## 6                     공매도 과열종목 지정(공매도 거래 금지 적용)
##               NA                             NA
## 1         휴벡셀 공시차트\r\n\t\t\t\t\t주가차트
## 2 코스닥시장본부 공시차트\r\n\t\t\t\t\t주가차트
## 3  스튜디오 썸머 공시차트\r\n\t\t\t\t\t주가차트
## 4  스튜디오 썸머 공시차트\r\n\t\t\t\t\t주가차트
## 5 코스닥시장본부 공시차트\r\n\t\t\t\t\t주가차트
## 6 코스닥시장본부 공시차트\r\n\t\t\t\t\t주가차트
```

### 네이버 금융에서 주식티커 크롤링

태그와 속성, 페이지 네비게이션 값을 결합하여 국내 상장 주식의 종목명 및 티커를 추출하는 방법에 대해 알아보도록 하겠습니다. 네이버 금융에서 국내증시 → 시가총액 페이지에는 코스피와 코스닥의 시가총액별 정보가 나타나 있습니다.

- 코스피: https://finance.naver.com/sise/sise_market_sum.nhn?sosok=0&page=1
- 코스닥: https://finance.naver.com/sise/sise_market_sum.nhn?sosok=1&page=1

또한 각 종목명을 클릭하여 이동하는 페이지의 url을 확인해보면, 끝 6자리가 각 종목의 거래소 티커임도 확인이 됩니다. 

티커 정리를 위해 우리가 html에서 확인해야 할 부분은 총 2가지 입니다. 먼저 하단의 페이지 네비게이션을 통해 코스피와 코스닥 시가총액에 해당하는 페이지가 각각 몇번째 페이지까지 존재하는지를 알아야 합니다. 아래와 같은 항목 중 **맨뒤**에 해당하는 페이지가 가장 마지막 페이지에 해당합니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_page_navi.png" alt="페이지 네비게이션" width="70%" />
<p class="caption">(\#fig:unnamed-chunk-16)페이지 네비게이션</p>
</div>

맨뒤 글자에 마우스를 올려둔 후 우클릭 → 검사를 선택할 경우 개발자도구 화면이 열리며, 해당 글자가 html 내에서 어떤 부분에 위치하는지 확인할 수 있습니다. '맨뒤' 에 해당하는 링크는 pgRR 클래스 → a 태그 중 href 속성에 위치하며, page= 뒷부분의 숫자에 위치하는 페이지로 링크가 걸려있습니다. 

<div class="figure" style="text-align: center">
<img src="images/crawl_page_navi2.png" alt="HTML 내 페이지 네비게이션 부분" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-17)HTML 내 페이지 네비게이션 부분</p>
</div>

종목명 링크에 해당하는 주소 중 끝 6자리는 티커에 해당합니다. 따라서 각 링크들의 주소를 알아야 할 필요도 있습니다.

<div class="figure" style="text-align: center">
<img src="images/crawl_naver_corp.png" alt="네이버 금융 시가총액 페이지" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-18)네이버 금융 시가총액 페이지</p>
</div>

삼성전자에 마우스를 올려둔 후 우클릭 → 검사를 통해 개발자도구 화면을 살펴보면, 해당 링크가 tbody → td → a 태그에서 href 속성에 위치하고 있음을 알수 있습니다. 

위의 정보들을 이용하여 데이터를 다운로드 받도록 하겠습니다. 아래 코드에서 i = 0 일 경우 코스피에 해당하는 url이, i = 1 일 경우 코스닥에 해당하는 url이 생성되며, 먼저 코스피에 해당하는 데이터를 다운로드 받도록 하겠습니다.


```r
library(httr)
library(rvest)

i = 0
ticker = list()
url = paste0('https://finance.naver.com/sise/sise_market_sum.nhn?sosok=',i,'&page=1')
print(url)
```

```
## [1] "https://finance.naver.com/sise/sise_market_sum.nhn?sosok=0&page=1"
```

```r
down_table = GET(url)
print(down_table)
```

```
## Response [https://finance.naver.com/sise/sise_market_sum.nhn?sosok=0&page=1]
##   Date: 2019-06-17 14:32
##   Status: 200
##   Content-Type: text/html;charset=EUC-KR
##   Size: 95.1 kB
## 
## 
## 
## 
## 
## 
## 
## <!--  global include -->
## 
## 	
## ...
```

1. 빈 리스트인 ticker 변수를 만들어 줍니다. 
2. `paste0()` 함수를 이용하여 코스피 시가총액 페이지의 url을 만듭니다.
3. `GET()` 함수를 통해 해당 페이지 내용을 받아 down_table 변수에 저장합니다.

down_table 변수를 확인해보면 Status가 200, 즉 데이터가 이상없이 받아졌으며, 인코딩은 EUC-KR 타입으로 되어 있습니다. 가장 먼저 해야할 작업은 가장 마지막 페이지가 몇번째 페이지인지 찾아내는 작업입니다. 우리는 이미 개발자도구 화면을 통해 해당 정보가 pgRR 클래스의 a태그 중 href 속성에 위치하고 있음을 알고 있습니다.


```r
navi.final = read_html(down_table, encoding = 'EUC-KR') %>%
      html_nodes(., '.pgRR') %>%
      html_nodes(., 'a') %>%
      html_attr(., 'href')
```

1. `read_html()` 함수를 이용하여 해당 페이지의 html 내용을 읽어오며, 인코딩은 'EUC-KR'로 셋팅해주도록 합니다. 
2. `html_nodes()` 함수를 이용하여 pgRR 클래스 정보만을 불러오도록 하며, 클래스 속성이므로 앞에 콤마(.)를 붙여 주도록 합니다.
3. `html_nodes()` 함수를 통해 a 태그 정보만을 불러오도록 합니다.
4. `html_attr()` 함수를 통해 href 속성을 불러오도록 합니다.

이를 통해 navi.final에는 해당 부분에 해당하는 내용이 저장됩니다.


```r
print(navi.final)
```

```
## [1] "/sise/sise_market_sum.nhn?sosok=0&page=31"
```

이 중 우리가 알고싶은 내용은 page= 뒤에 존재하는 숫자입니다. 해당 내용을 추출하는 코드는 다음과 같습니다.


```r
navi.final = navi.final %>%
  strsplit(., '=') %>%
  unlist() %>%
  tail(., 1) %>%
  as.numeric()
```

1. `strsplit()` 함수는 전체 문장을 특정 글자 기준으로 나누는 것입니다. page= 뒷부분만의 데이터가 필요하므로 '='를 기준으로 문장을 나눠주도록 합니다.
2. `unlist()` 함수를 통해 결과를 벡터 형태로 변환합니다. 
3. `tail()` 함수를 통해 마지막 첫번째 데이터만 선택합니다.
4. `as.numeric()` 함수를 통해 해당 값을 숫자 형태로 바꾸어 주도록 합니다.


```r
print(navi.final)
```

```
## [1] 31
```

for loop 구문을 이용할 경우 1 페이지 부터 navi.final, 즉 마지막 페이지까지 모든 페이지의 내용을 읽어올 수 있습니다. 먼저 코스피의 첫번째 페이지에서 우리가 원하는 데이터를 추출하는 방법을 살펴보도록 하겠습니다.


```r
i = 0 # 코스피
j = 1 # 첫번째 페이지
url = paste0("https://finance.naver.com/sise/sise_market_sum.nhn?sosok=",i,"&page=",j)
down_table = GET(url)
```

1. i와 j에 각각 0과 1을 입력하여 코스피 첫번째 페이지에 해당하는 url을 생성해 줍니다.
2. `GET()` 함수를 이용하여 해당 페이지의 데이터를 다운로드 받습니다.


```r
Sys.setlocale("LC_ALL", "English")
```

```
## [1] "LC_COLLATE=English_United States.1252;LC_CTYPE=English_United States.1252;LC_MONETARY=English_United States.1252;LC_NUMERIC=C;LC_TIME=English_United States.1252"
```

```r
table = read_html(down_table, encoding = "EUC-KR") %>% html_table(fill = TRUE)
table = table[[2]]

Sys.setlocale("LC_ALL", "Korean")
```

```
## [1] "LC_COLLATE=Korean_Korea.949;LC_CTYPE=Korean_Korea.949;LC_MONETARY=Korean_Korea.949;LC_NUMERIC=C;LC_TIME=Korean_Korea.949"
```

1. `Sys.setlocale()` 함수를 통해 로케일 언어를 영어로 설정 해줍니다.
2. `read_html()` 함수를 통해 html 정보를 읽어옵니다.
3. `html_table()` 함수를 통해 테이블 정보를 읽어오며, fill=TRUE 를 추가해줍니다.
4. table 변수에는 리스트 형태로 총 3가지 테이블이 저장되어 있습니다. 첫번째 리스트에는 거래량, 시가, 고가 등 적용 항목, 세번째 리스트에는 페이지 네비게이션 테이블이 저장되어 있으므로, 우리에게 필요한 두번째 리스트만을 table 변수에 다시 저장하도록 합니다. 
5. 한글을 읽기 위해 `Sys.setlocale()` 함수를 통해 로케일 언어를 다시 Korean으로 변경해 줍니다.

저장된 table 내용을 확인하면 다음과 같습니다.


```r
print(head(table))
```

```
##    N     종목명  현재가 전일비 등락률 액면가  시가총액 상장주식수
## 1 NA                                                             
## 2  1   삼성전자  43,900    100 -0.23%    100 2,620,735  5,969,783
## 3  2 SK하이닉스  63,700    600 +0.95%  5,000   463,738    728,002
## 4  3     현대차 140,000    500 -0.36%  5,000   299,135    213,668
## 5  4 삼성전자우  35,650    650 -1.79%    100   293,359    822,887
## 6  5   셀트리온 205,000  4,000 +1.99%  1,000   263,075    128,329
##   외국인비율    거래량    PER   ROE 토론실
## 1         NA             <NA>  <NA>     NA
## 2      57.11 7,359,657   7.29 19.63     NA
## 3      50.00 2,426,252   2.98 38.53     NA
## 4      44.61   228,445  26.16  2.20     NA
## 5      92.55 1,156,576   5.92   N/A     NA
## 6      20.57   323,697 100.05 10.84     NA
```

이 중 마지막 열인 토론실은 필요가 없는 열이며, 첫번째 행과 같이 아무런 정보가 없는 행이 존재하기도 합니다. 이를 정리하면 다음과 같습니다.


```r
table[, ncol(table)] = NULL
table = na.omit(table)
print(head(table))
```

```
##    N     종목명  현재가 전일비 등락률 액면가  시가총액 상장주식수
## 2  1   삼성전자  43,900    100 -0.23%    100 2,620,735  5,969,783
## 3  2 SK하이닉스  63,700    600 +0.95%  5,000   463,738    728,002
## 4  3     현대차 140,000    500 -0.36%  5,000   299,135    213,668
## 5  4 삼성전자우  35,650    650 -1.79%    100   293,359    822,887
## 6  5   셀트리온 205,000  4,000 +1.99%  1,000   263,075    128,329
## 10 6     LG화학 348,500  4,000 +1.16%  5,000   246,014     70,592
##    외국인비율    거래량    PER   ROE
## 2       57.11 7,359,657   7.29 19.63
## 3       50.00 2,426,252   2.98 38.53
## 4       44.61   228,445  26.16  2.20
## 5       92.55 1,156,576   5.92   N/A
## 6       20.57   323,697 100.05 10.84
## 10      38.59   147,415  18.53  8.86
```

이제 우리가 필요한 정보는 6자리 티커입니다. 티커 역시 개발자도구 화면을 통해 tbody → td → a 태그에서 href 속성에 위치하고 있음을 알고 있으며, 이를 추출하는 코드는 다음과 같습니다.


```r
symbol = read_html(down_table, encoding = 'EUC-KR') %>%
  html_nodes(., 'tbody') %>%
  html_nodes(., 'td') %>%
  html_nodes(., 'a') %>%
  html_attr(., 'href')
print(head(symbol, 10))
```

```
##  [1] "/item/main.nhn?code=005930"  "/item/board.nhn?code=005930"
##  [3] "/item/main.nhn?code=000660"  "/item/board.nhn?code=000660"
##  [5] "/item/main.nhn?code=005380"  "/item/board.nhn?code=005380"
##  [7] "/item/main.nhn?code=005935"  "/item/board.nhn?code=005935"
##  [9] "/item/main.nhn?code=068270"  "/item/board.nhn?code=068270"
```

1. `read_html()`함수를 통해 html 정보를 읽어오며, 인코딩은 'EUC-KR'로 설정합니다.
2. `html_nodes()` 함수를 통해 'tbody' 태그 정보를 불러옵니다.
3. 다시 `html_nodes()` 함수를 통해 'td'와 'a' 태그 정보를 불러옵니다.
4. `html_attr()` 함수를 이용하여 'href' 속성을 불러옵니다.

이를 통해 symbol에는 href 속성에 해당하는 링크 주소들이 저장되게 됩니다. 이 중 마지막 6자리 글자만 추출하는 코드는 다음과 같습니다.


```r
symbol = sapply(symbol, function(x) {
        substr(x, nchar(x) - 5, nchar(x)) 
      })
print(head(symbol, 10))
```

```
##  /item/main.nhn?code=005930 /item/board.nhn?code=005930 
##                    "005930"                    "005930" 
##  /item/main.nhn?code=000660 /item/board.nhn?code=000660 
##                    "000660"                    "000660" 
##  /item/main.nhn?code=005380 /item/board.nhn?code=005380 
##                    "005380"                    "005380" 
##  /item/main.nhn?code=005935 /item/board.nhn?code=005935 
##                    "005935"                    "005935" 
##  /item/main.nhn?code=068270 /item/board.nhn?code=068270 
##                    "068270"                    "068270"
```

`sapply()` 함수를 통해 symbol 변수의 내용들에 `function()`을 적용하며, `substr()` 함수 내에 `nchar()` 함수를 적용하여 마지막 6자리 글자만을 추출하도록 합니다.

결과를 살펴보면 티커에 해당하는 마지막 6글자만 추출된 것이 확인됩니다. 그러나 결과를 살펴보면 동일한 내용이 두번 연속하여 추출됩니다. 이는 main.nhn?code= 에 해당하는 부분은 종목명에 설정된 링크, board.nhn?code= 에 해당하는 부분은 토론실에 설정된 링크이기 때문입니다. 


```r
symbol = unique(symbol)
print(head(symbol, 10))
```

```
##  [1] "005930" "000660" "005380" "005935" "068270" "051910" "055550"
##  [8] "017670" "012330" "051900"
```

`unique()` 함수를 이용하여 중복되는 티커를 제거하면 우리가 원하는 티커 부분만 깔끔하게 정리가 됩니다. 해당 내용을 위에서 구한 table에 입력한 후 데이터를 다듬는 과정은 다음과 같습니다.


```r
table$N = symbol
colnames(table)[1] = '종목코드'
 
rownames(table) = NULL
ticker[[j]] = table
```

1. 'N'열에 위에서 구한 티커를 입력해 줍니다.
2. 해당 열 이름을 '종목코드'로 변경합니다.
3. `na.omit()`을 통해 특정 행을 삭제하였으므로, 행 이름을 초기화 해주도록 합니다.
4. ticker의 j번째 리스트에 정리된 데이터를 입력해 줍니다.

위의 코드에서 i와 j값을 for loop를 이용하면 코스피와 코스닥 전 종목의 티커가 정리된 테이블을 만들 수 있습니다. 이를 전체 코드로 나타내면 다음과 같습니다.


```r
data = list()

# i = 0 은 코스피, i = 1 은 코스닥 종목
for (i in 0:1) {

  ticker = list()
  url = paste0("https://finance.naver.com/sise/sise_market_sum.nhn?sosok=",i,"&page=1")
  
  down_table = GET(url)
  
  # 최종 페이지 번호 찾아주기
  navi.final = read_html(down_table, encoding = "EUC-KR") %>%
      html_nodes(., ".pgRR") %>%
      html_nodes(., "a") %>%
      html_attr(.,"href") %>%
      strsplit(., "=") %>%
      unlist() %>%
      tail(., 1) %>%
      as.numeric()
  
  # 첫번째 부터 마지막 페이지까지 for loop를 이용하여 테이블 추출하기
  for (j in 1:navi.final) {
    
    # 각 페이지에 해당하는 url 생성
    url = paste0("https://finance.naver.com/sise/sise_market_sum.nhn?sosok=",i,"&page=",j)
    down_table = GET(url)
 
    Sys.setlocale("LC_ALL", "English") # 한글 오류 방지를 위해 영어로 로케일 언어 변경
 
    table = read_html(down_table, encoding = "EUC-KR") %>% html_table(fill = TRUE)
    table = table[[2]] # 원하는 테이블 추출
 
    Sys.setlocale("LC_ALL", "Korean") # 한글을 읽기위해 로케일 언어 재변경
 
    table[, ncol(table)] = NULL # 토론식 부분 삭제
    table = na.omit(table) # 빈 행 삭제
    
    # 6자리 티커만 추출
    symbol = read_html(down_table, encoding = "EUC-KR") %>%
      html_nodes(., "tbody") %>%
      html_nodes(., "td") %>%
      html_nodes(., "a") %>%
      html_attr(., "href")
 
    symbol = sapply(symbol, function(x) {
      substr(x, nchar(x) - 5, nchar(x)) 
      }) %>% unique()
    
    # 테이블에 티커 넣어준 후, 테이블 정리
    table$N = symbol
    colnames(table)[1] = "종목코드"

    rownames(table) = NULL
    ticker[[j]] = table
 
    Sys.sleep(0.5) # 페이지 당 0.5초의 슬립 적용
  }
  
  # do.call을 통해 리스트를 데이터 프레임으로 묶기
  ticker = do.call(rbind, ticker)
  data[[i + 1]] = ticker
}

# 코스피와 코스닥 테이블 묶기
data = do.call(rbind, data)
```
