
# 크롤링 이해하기

API를 이용할 경우 데이터를 매우 쉽게 수집할 수 있지만, 국내 주식 데이터를 다운로드 받기에는 한계가 있으며, 원하는 데이터가 API의 형태로 제공된다는 보장도 없습니다. 따라서 우리는 필요한 데이터를 얻기 위해 직접 찾아나서야 합니다.

각종 금융 사이트들에는 주가, 재무정보 등 우리가 원하는 대부분의 주식 정보가 제공되고 있으며, API를 활용할 수 없는 경우에도 크롤링을 통해 이러한 데이터를 수집할 수 있습니다.

크롤링 혹은 스크래핑이란 웹사이트에서 원하는 정보를 수집하는 기술입니다. 대부분의 금융 사이트들이 간단한 형태로 작성되어 있어, 몇 가지 기술만 익히면 어렵지 않게 데이터를 크롤링 할 수 있습니다. 해당 장에서는 크롤링에 대한 간단한 설명과 예제를 살펴보도록 하겠습니다.

크롤링을 할 때는 주의해야 할 점이 있습니다. 특정 사이트의 페이지를 쉬지 않고 크롤링을 하는 행위를 무한 크롤링이라 합니다. 이러한 경우 해당 사이트의 자원을 독점하게 되어 타인의 사용을 막게 되며, 사이트에 부하를 주게 됩니다. 일부 사이트에서는 동일한 IP로 쉬지 않고 크롤링을 할 경우 접속을 막아버리는 경우도 있습니다. 따라서 하나의 페이지를 크롤링 한 후, 1~2초 가량 정지한 후 다시 다음 페이지를 크롤링 할 필요가 있습니다.

## GET과 POST 방식 이해하기

우리가 인터넷에 접속하여 서버에 파일을 요청하면, 서버는 이에 해당하는 파일을 우리에게 보내줍니다. 이러한 과정을 사람이 수행하기 편하고 시각적으로 보기 편하도록 만들어 진 것이 크롬과 같은 웹브라우저 이며, 서버의 주소를 기억하기 쉽게하기 위해 만든 것이 인터넷 주소 입니다. 우리가 서버에 데이터를 요청하는 형태는 다양하지만 크롤링에서는 주로 GET과 POST 방식을 사용합니다.

\begin{figure}[h]

{\centering \includegraphics[width=0.7\linewidth]{images/crawl_flow} 

}

\caption{클라이언트와 서버 간의 요청/응답 과정}(\#fig:unnamed-chunk-2)
\end{figure}

### GET 방식

GET 방식은 인터넷 주소를 기준으로, 이에 해당하는 데이터나 파일을 요청하는 것입니다. 주로 클라이언트가 요청하는 쿼리를 앰퍼샌드(&) 혹은 물음표(?) 형식으로 결합하여 서버에 전달됩니다.

한경컨센서스^[http://hkconsensus.hankyung.com/]에 접속한 후 상단의 탭에서 기업을 선택하면, 주소의 끝부분에 **?skinType=business**가 추가되며 이에 해당하는 페이지의 내용을 보여줍니다. 즉, 해당 페이지는 GET 방식을 사용하고 있으며 입력종류는 skinType, 이에 해당하는 기업 탭의 입력값은 business 임을 알 수 있습니다.

\begin{figure}[h]

{\centering \includegraphics[width=1\linewidth]{images/crawl_hk} 

}

\caption{한경 컨센서스 기업 REPORT 페이지}(\#fig:unnamed-chunk-3)
\end{figure}

이번에는 파생 탭을 선택하여 봅니다. 역시나 홈페이지 주소가 변경되며 해당 주소에 맞는 내용이 나타납니다. 주소의 끝부분이 **?skinType=derivative** 로 변경되며, 입력 값이 변경됨에 따라 페이지의 내용이 이에 맞게 변하는 모습이 확인됩니다. 여러 다른 탭들을 눌러보면 **?skinType=** 뒷부분의 입력값이 변함에 따라 이에 해당하는 페이지로 내용이 변경됨이 확인됩니다.

다시 기업 탭을 선택한 후, 다음 페이지를 확인하기 위해 하단의 2를 클릭합니다. 기존 주소인 **?skinType=business** 뒤에 추가로 **sdate**와 **edate**, 그리고 **now_page** 쿼리가 추가됩니다. sdate에 검색 기간의 시작시점, edate에 검색 기간의 종료시점, now_page에 원하는 페이지를 수기로 입력해도 이에 해당하는 페이지의 데이터를 보여줍니다. 이처럼 GET 방식으로 데이터를 요청할 경우, 웹 페이지 주소를 수정하여 원하는 종류의 데이터를 받아올 수 있습니다.

\begin{figure}[h]

{\centering \includegraphics[width=1\linewidth]{images/crawl_hk2} 

}

\caption{쿼리 추가로 인한 url의 변경}(\#fig:unnamed-chunk-4)
\end{figure}

### POST 방식

POST 방식은 사용자가 필요한 값을 추가해서 요청하는 방법입니다. GET 방식과의 차이는 클라이언트가 요청하는 쿼리를 body에 넣어서 전송하므로, 요청 내역을 직접적으로 볼 수 없습니다.

한국거래소 상장공시시스템^[http://kind.krx.co.kr/]에 접속하여 전체메뉴보기를 누른 후, 상장법인상세정보 중 상장종목현황을 선택합니다. 웹 페이지 주소가 바뀌며, 상장종목현황이 보여집니다. 

\begin{figure}[h]

{\centering \includegraphics[width=0.7\linewidth]{images/crawl_corp_list} 

}

\caption{상장공시시스템의 상장종목현황 메뉴}(\#fig:unnamed-chunk-5)
\end{figure}

이번엔 조회일자를 2017-12-28로 선택한 후, 검색을 눌러보도록 합니다. 페이지의 내용은 선택일 기준으로 변경되었지만, 주소는 변경되지 않고 그대로 남아있습니다. GET 방식에서는 선택항목에 따라 웹 페이지 주소가 변경되었지만, POST 방식을 사용하여 서버에 데이터를 요청하는 해당 사이트는 그렇지 않음이 확인됩니다.

POST 방식의 데이터 요청과정을 살펴보기 위해서는 개발자도구를 이용해야 하며, 크롬 브라우저에서 F12 키를 눌러 해당 화면을 열 수 있습니다. 개발자도구 화면을 연 상태에서 다시 한번 **검색**을 클릭해 봅니다. Network 탭을 클릭하면, **검색**을 클릭함과 함게 브라우저와 서버간의 통신 과정을 살펴볼 수 있습니다. 이 중 **listedIssueStatus.do** 라는 항목이 POST 형태임을 알 수 있습니다.

\begin{figure}[h]

{\centering \includegraphics[width=1\linewidth]{images/crawl_corp_list_2} 

}

\caption{크롬 개발자도구의 Network 화면}(\#fig:unnamed-chunk-6)
\end{figure}

해당 메뉴를 클릭하면 통신 과정을 좀 더 자세히 알 수 있습니다. 가장 하단의 Form Data에는 서버에 데이터를 요청하는 내역이 있습니다. method에는 readListIssueStatus, selDate에는 2017-12-28라는 값이 있습니다.

\begin{figure}[h]

{\centering \includegraphics[width=0.7\linewidth]{images/crawl_corp_list_3} 

}

\caption{POST 방식의 서버 요청 내역}(\#fig:unnamed-chunk-7)
\end{figure}

이처럼 POST 방식은 요청하는 데이터에 대한 쿼리가 GET 방식처럼 url을 통해 전송되는 것이 아닌 body를 통해 전송되므로, 이에 대한 정보는 웹브라우저를 통해 확인할 수 없습니다.

## 크롤링 예제

크롤링의 일반적인 과정은 `httr` 패키지의 `GET()` 혹은 `POST()` 함수를 이용하여 데이터를 다운로드 받은 후, `rvest` 패키지의 함수들을 이용하여 원하는 데이터를 찾아내는 과정으로 이루어집니다. 해당 장에서는 GET 방식의 예제로 금융 실시간 속보의 제목을 추출하는 방법을, POST 방식의 예제로 기업공시채널에서 오늘의 공시를 추출하는 방법을, 마지막으로 태그와 속성, 페이지 네비게이션 값을 결합하여 국내 상장 주식의 종목명 및 티커를 추출하는 방법에 대해 알아보도록 하겠습니다.

### 금융 속보 크롤링

크롤링의 간단한 예제로 금융 속보의 제목을 추출해 보도록 하겠습니다. 먼저 네이버 금융에 접속한 후 뉴스 → 실시간 속보^[https://finance.naver.com/news/news_list.nhn?mode=LSS2D&section_id=101&section_id2=258]를 선택해 줍니다. 이 중 뉴스의 제목에 해당하는 텍스트만 추출하고자 합니다. 

뉴스 제목 부분에 마우스를 올려둔 후 우클릭 → 검사를 선택할 경우 개발자도구 화면이 열리며, 해당 글자가 html 내에서 어떤 부분에 위치하는지 확인할 수 있습니다. 해당 제목은 dl 태그 → dd 태그의 articleSubject 클래스 → a 태그 중 title 속성에 위치하고 있습니다. 태그와 속성의 차이가 이해되지 않으시는 분은 해당 장을 다시 살펴보시기 바랍니다.

\begin{figure}[h]

{\centering \includegraphics[width=1\linewidth]{images/crawl_naver_news} 

}

\caption{실시간 속보의 제목 부분 html}(\#fig:unnamed-chunk-8)
\end{figure}

먼저 해당 페이지의 내용을 R로 불러오도록 하겠습니다.


```r
library(rvest)
library(httr)

url = paste0('https://finance.naver.com/news/news_list.nhn?',
             'mode=LSS2D&section_id=101&section_id2=258')
data = GET(url)

print(data)
```

먼저 url 변수에 해당 주소를 입력한 후, `GET()` 함수를 이용하여 해당 페이지의 내용을 받아 data 변수에 저장합니다. data 변수를 확인해보면 Status가 200, 즉 데이터가 이상없이 받아졌으며, 인코딩(charset)은 EUC-KR 타입으로 되어 있습니다. 

우리는 개발자도구 화면을 통해 제목에 해당하는 부분이 dl 태그 → dd 태그의 articleSubject 클래스 → a 태그 중 title 속성에 위치하고 있음을 살펴보았습니다. 이를 활용해 제목 부분만을 추출하는 방법은 다음과 같습니다.


```r
data_title = data %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes('dl') %>%
  html_nodes('.articleSubject') %>%
  html_nodes('a') %>%
  html_attr('title')
```

1. 먼저 `read_html()` 함수를 이용하여 해당 페이지의 html 내용을 읽어오며, 인코딩은 **EUC-KR**로 셋팅해주도록 합니다. 
2. `html_nodes()` 함수는 해당 태그를 추출하는 함수로써, `dl` 태그에 해당하는 부분을 추출합니다.
3. `html_nodes()` 함수를 이용하여 articleSubject 클래스에 해당하는 부분을 추출할 수 있으며, 클래스 속성의 경우 이름 앞에 콤마(.)를 붙여주어야 합니다.
4. `html_nodes()` 함수를 이용하여 a 태그를 추출합니다.
5. `html_attr()` 함수는 속성을 추출하는 함수로써, title에 해당하는 부분만을 추출합니다.

해당 과정을 거쳐 data_title에는 실시간 속보의 제목만이 저장됩니다. 이처럼 개발자도구 화면을 통해 내가 추출하고자 하는 데이터가 html 중 어디에 위치하고 있는지 먼저 확인을 하면, 어렵지 않게 해당 데이터를 읽어올 수 있습니다.

```r
print(data_title)
```


```
##  [1] "“스미모토 부동산, 도쿄 임대 업황 "   
##  [2] "\"아직도 은행에서 환전하세요?\"…외화"
##  [3] "[부고]양홍제(대신증권 컴플라이언스부" 
##  [4] "'상저' 지나 '하고' 기대하는 IT"       
##  [5] "韓증시는 부진했지만… 해외주식, 금 "  
##  [6] "올스웰, 中3위 수도강철과 기술협약"    
##  [7] "[주간증시전망] \"국내 주식시장 디커"  
##  [8] "미국 대형은행, 배당 매력 증가 기대"   
##  [9] "에듀윌, 국제무역사 및 무역영어 시험"  
## [10] "7월증시 서머랠리는? "                 
## [11] "한화투자증권 \"화장품업종, 실적 차별" 
## [12] "[영화로 경제 보기]BIFAN 폐막…"       
## [13] "반일 감정 몰아..이번엔 `애국테마株"   
## [14] "[주목!e해외주식]테슬라, 2분기 사"     
## [15] "[한주 증시 돌아보기]매수 3주체 매"    
## [16] "초등학교 여름방학 준비, 천재교육 밀"  
## [17] "[주간추천주]유안타증권"               
## [18] "[주간추천주]KB증권"                   
## [19] "[주간추천주]SK증권"                   
## [20] "[주목! e스몰캡]미스터블루, 웹툰 "
```

### 기업공시채널에서 오늘의 공시 불러오기

한국거래소 상장공시시스템에 접속한 후 오늘의 공시 → 전체 → 더보기를 선택하여 전체 공시내용을 확인할 수 있습니다. 

\begin{figure}[h]

{\centering \includegraphics[width=0.7\linewidth]{images/crawl_kind} 

}

\caption{오늘의공시 확인하기}(\#fig:unnamed-chunk-13)
\end{figure}

해당 페이지에서 날짜를 변경할 경우, 페이지의 내용은 해당일의 공시로 변경되지만 url은 변경되지 않습니다. 이처럼 POST 방식의 경우 요청하는 데이터에 대한 쿼리가 body의 형태를 통해 전송되므로, 개발자도구 화면을 통해 해당 쿼리에 대한 내용을 확인해야 합니다.

개발자도구 화면을 연 상태에서 조회일자를 2018-12-28로 선택한 후 Network 탭의 **todaydisclosure.do** 항목을 살펴보면 Form Data를 통해 서버에 데이터를 요청하는 내역을 확인할 수 있습니다. 여러 항목 중 selDate 부분이 우리가 선택한 일자로 설정되어 있습니다. 

\begin{figure}[h]

{\centering \includegraphics[width=1\linewidth]{images/crawl_kind_post} 

}

\caption{POST 방식의 데이터 요청}(\#fig:unnamed-chunk-14)
\end{figure}

POST 방식으로 쿼리를 요청하는 방법을 코드로 나타내면 다음과 같습니다. 


```r
library(httr)
library(rvest)

Sys.setlocale("LC_ALL", "English")

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
##      NA           NA
## 1 18:32     화신테크
## 2 18:26 에스제이케이
## 3 18:11     아이엠텍
## 4 18:10 시그넷이브이
## 5 18:09             
## 6 18:09             
##                                            NA
## 1                                최대주주변경
## 2 증권 발행결과(자율공시)(제3자배정 유상증자)
## 3               [정정]유상증자결정(제3자배정)
## 4                          유형자산 양수 결정
## 5            자기주식매매신청내역(코스닥시장)
## 6                    대량매매내역(코스닥시장)
##               NA                             NA
## 1       화신테크 공시차트\r\n\t\t\t\t\t주가차트
## 2   에스제이케이 공시차트\r\n\t\t\t\t\t주가차트
## 3       아이엠텍 공시차트\r\n\t\t\t\t\t주가차트
## 4   시그넷이브이 공시차트\r\n\t\t\t\t\t주가차트
## 5 코스닥시장본부                               
## 6 코스닥시장본부
```

POST 형식의 경우 body에 들어가는 쿼리 내용을 바꾸어 원하는 데이터를 받을수 있습니다. 만일 2019년 1월 8일 공시를 확인하고자 할 경우, 위의 코드에서 selDate만 **2019-01-08**로 변경해주면 됩니다. 아래 코드의 출력 결과물을 2019년 1월 4일 공시와 확인하면 동일한 결과임을 확인할 수 있습니다.


```r
Sys.setlocale("LC_ALL", "English")

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
                selDate = '2019-01-08'
                ))

data = read_html(data) %>%
  html_table(fill = TRUE) %>%
  .[[1]]

Sys.setlocale("LC_ALL", "Korean")
```

```r
print(head(data))
```

```
##      NA             NA
## 1 18:58   해덕파워웨이
## 2 18:57   해덕파워웨이
## 3 18:57     퓨전데이타
## 4 18:56   해덕파워웨이
## 5 18:52 한국테크놀로지
## 6 18:52 한국테크놀로지
##                                                        NA
## 1                                              소속부변경
## 2 주권매매거래정지기간변경(상장적격성 실질심사 대상 결정)
## 3                                            최대주주변경
## 4            관리종목지정(상장적격성 실질심사 대상 결정 )
## 5                            전환사채권발행결정(제18회차)
## 6                            전환사채권발행결정(제17회차)
##               NA                             NA
## 1 코스닥시장본부 공시차트\r\n\t\t\t\t\t주가차트
## 2 코스닥시장본부 공시차트\r\n\t\t\t\t\t주가차트
## 3     퓨전데이타 공시차트\r\n\t\t\t\t\t주가차트
## 4 코스닥시장본부 공시차트\r\n\t\t\t\t\t주가차트
## 5 한국테크놀로지 공시차트\r\n\t\t\t\t\t주가차트
## 6 한국테크놀로지 공시차트\r\n\t\t\t\t\t주가차트
```

### 네이버 금융에서 주식티커 크롤링

태그와 속성, 페이지 네비게이션 값을 결합하여 국내 상장 주식의 종목명 및 티커를 추출하는 방법에 대해 알아보도록 하겠습니다. 네이버 금융에서 국내증시 → 시가총액 페이지에는 코스피와 코스닥의 시가총액별 정보가 나타나 있습니다.

- 코스피: https://finance.naver.com/sise/sise_market_sum.nhn?sosok=0&page=1
- 코스닥: https://finance.naver.com/sise/sise_market_sum.nhn?sosok=1&page=1

또한 종목명을 클릭하여 이동하는 페이지의 url을 확인해보면, 끝 6자리가 각 종목의 거래소 티커임도 확인이 됩니다. 

티커 정리를 위해 html에서 확인해야 할 부분은 총 2가지 입니다. 먼저 하단의 페이지 네비게이션을 통해 코스피와 코스닥 시가총액에 해당하는 페이지가 각각 몇번째 페이지까지 존재하는지를 알아야 합니다. 아래와 같은 항목 중 **맨뒤**에 해당하는 페이지가 가장 마지막 페이지입니다.

\begin{figure}[h]

{\centering \includegraphics[width=0.7\linewidth]{images/crawl_page_navi} 

}

\caption{페이지 네비게이션}(\#fig:unnamed-chunk-19)
\end{figure}

**맨뒤** 글자에 마우스를 올려둔 후 우클릭 → 검사를 선택할 경우 개발자도구 화면이 열리며, 해당 글자가 html 내에서 어떤 부분에 위치하는지 확인할 수 있습니다. 해당 링크는 pgRR 클래스 → a 태그 중 href 속성에 위치하며, page= 뒷부분의 숫자에 위치하는 페이지로 링크가 걸려있습니다. 

\begin{figure}[h]

{\centering \includegraphics[width=1\linewidth]{images/crawl_page_navi2} 

}

\caption{HTML 내 페이지 네비게이션 부분}(\#fig:unnamed-chunk-20)
\end{figure}

종목명 링크에 해당하는 주소 중 끝 6자리는 티커에 해당합니다. 따라서 각 링크들의 주소를 알아야 할 필요도 있습니다.

\begin{figure}[h]

{\centering \includegraphics[width=1\linewidth]{images/crawl_naver_corp} 

}

\caption{네이버 금융 시가총액 페이지}(\#fig:unnamed-chunk-21)
\end{figure}

삼성전자에 마우스를 올려둔 후 우클릭 → 검사를 통해 개발자도구 화면을 살펴보면, 해당 링크가 tbody → td → a 태그에서 href 속성에 위치하고 있음을 알수 있습니다. 

위의 정보들을 이용하여 데이터를 다운로드 받도록 하겠습니다. 아래 코드에서 i = 0 일 경우 코스피에 해당하는 url이, i = 1 일 경우 코스닥에 해당하는 url이 생성되며, 먼저 코스피에 해당하는 데이터를 다운로드 받도록 하겠습니다.


```r
library(httr)
library(rvest)

i = 0
ticker = list()
url = paste0('https://finance.naver.com/sise/',
             'sise_market_sum.nhn?sosok=',i,'&page=1')
down_table = GET(url)
```

1. 빈 리스트인 ticker 변수를 만들어 줍니다. 
2. `paste0()` 함수를 이용하여 코스피 시가총액 페이지의 url을 만듭니다.
3. `GET()` 함수를 통해 해당 페이지 내용을 받아 down_table 변수에 저장합니다.

가장 먼저 해야할 작업은 가장 마지막 페이지가 몇번째 페이지인지 찾아내는 작업입니다. 우리는 이미 개발자도구 화면을 통해 해당 정보가 pgRR 클래스의 a태그 중 href 속성에 위치하고 있음을 알고 있습니다.


```r
navi.final = read_html(down_table, encoding = 'EUC-KR') %>%
      html_nodes(., '.pgRR') %>%
      html_nodes(., 'a') %>%
      html_attr(., 'href')
```

1. `read_html()` 함수를 이용하여 해당 페이지의 html 내용을 읽어오며, 인코딩은 **EUC-KR**로 셋팅해주도록 합니다. 
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

1. `strsplit()` 함수는 전체 문장을 특정 글자 기준으로 나누는 것입니다. page= 뒷부분만의 데이터가 필요하므로 **=**를 기준으로 문장을 나눠주도록 합니다.
2. `unlist()` 함수를 통해 결과를 벡터 형태로 변환합니다. 
3. `tail()` 함수를 통해 뒤에서 첫번째 데이터만 선택합니다.
4. `as.numeric()` 함수를 통해 해당 값을 숫자 형태로 바꾸어 주도록 합니다.


```r
print(navi.final)
```

```
## [1] 31
```

코스피 시가총액 페이지는 31번째 페이지까지 존재하며, for loop 구문을 이용할 경우 1 페이지 부터 navi.final, 즉 31 페이지까지 모든 내용을 읽어올 수 있습니다. 먼저 코스피의 첫번째 페이지에서 우리가 원하는 데이터를 추출하는 방법을 살펴보도록 하겠습니다.


```r
i = 0 # 코스피
j = 1 # 첫번째 페이지
url = paste0('https://finance.naver.com/sise/',
             'sise_market_sum.nhn?sosok=',i,"&page=",j)
down_table = GET(url)
```

1. i와 j에 각각 0과 1을 입력하여 코스피 첫번째 페이지에 해당하는 url을 생성해 줍니다.
2. `GET()` 함수를 이용하여 해당 페이지의 데이터를 다운로드 받습니다.


```r
Sys.setlocale("LC_ALL", "English")

table = read_html(down_table, encoding = "EUC-KR") %>%
  html_table(fill = TRUE)
table = table[[2]]

Sys.setlocale("LC_ALL", "Korean")
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
##    N     종목명  현재가 전일비 등락률 액면가  시가총액
## 1 NA                                                  
## 2  1   삼성전자  45,650    350 -0.76%    100 2,725,206
## 3  2 SK하이닉스  68,400  1,800 -2.56%  5,000   497,954
## 4  3 삼성전자우  37,350    650 -1.71%    100   307,348
## 5  4     현대차 141,500  2,500 +1.80%  5,000   302,340
## 6  5   셀트리온 208,000  4,500 +2.21%  1,000   266,924
##   상장주식수 외국인비율    거래량    PER   ROE 토론실
## 1                    NA             <NA>  <NA>     NA
## 2  5,969,783      57.38 7,222,188   7.58 19.63     NA
## 3    728,002      50.70 2,037,255   3.20 38.53     NA
## 4    822,887      92.73   599,446   6.20   N/A     NA
## 5    213,668      44.37   338,120  26.44  2.20     NA
## 6    128,329      21.39   259,974 101.51 10.84     NA
```

이 중 마지막 열인 토론실은 필요가 없는 열이며, 첫번째 행과 같이 아무런 정보가 없는 행이 존재하기도 합니다. 이를 다음과 같이 정리해주도록 합니다.


```r
table[, ncol(table)] = NULL
table = na.omit(table)
print(head(table))
```

```
##    N     종목명  현재가 전일비 등락률 액면가  시가총액
## 2  1   삼성전자  45,650    350 -0.76%    100 2,725,206
## 3  2 SK하이닉스  68,400  1,800 -2.56%  5,000   497,954
## 4  3 삼성전자우  37,350    650 -1.71%    100   307,348
## 5  4     현대차 141,500  2,500 +1.80%  5,000   302,340
## 6  5   셀트리온 208,000  4,500 +2.21%  1,000   266,924
## 10 6     LG화학 354,500  4,000 -1.12%  5,000   250,250
##    상장주식수 외국인비율    거래량    PER   ROE
## 2   5,969,783      57.38 7,222,188   7.58 19.63
## 3     728,002      50.70 2,037,255   3.20 38.53
## 4     822,887      92.73   599,446   6.20   N/A
## 5     213,668      44.37   338,120  26.44  2.20
## 6     128,329      21.39   259,974 101.51 10.84
## 10     70,592      38.90    99,907  18.84  8.86
```

이제 필요한 정보는 6자리 티커입니다. 티커 역시 개발자도구 화면을 통해 tbody → td → a 태그에서 href 속성에 위치하고 있음을 알고 있으며, 이를 추출하는 코드는 다음과 같습니다.


```r
symbol = read_html(down_table, encoding = 'EUC-KR') %>%
  html_nodes(., 'tbody') %>%
  html_nodes(., 'td') %>%
  html_nodes(., 'a') %>%
  html_attr(., 'href')

print(head(symbol, 10))
```

```
##  [1] "/item/main.nhn?code=005930" 
##  [2] "/item/board.nhn?code=005930"
##  [3] "/item/main.nhn?code=000660" 
##  [4] "/item/board.nhn?code=000660"
##  [5] "/item/main.nhn?code=005935" 
##  [6] "/item/board.nhn?code=005935"
##  [7] "/item/main.nhn?code=005380" 
##  [8] "/item/board.nhn?code=005380"
##  [9] "/item/main.nhn?code=068270" 
## [10] "/item/board.nhn?code=068270"
```

1. `read_html()`함수를 통해 html 정보를 읽어오며, 인코딩은 **EUC-KR**로 설정합니다.
2. `html_nodes()` 함수를 통해 tbody 태그 정보를 불러옵니다.
3. 다시 `html_nodes()` 함수를 통해 td와 a 태그 정보를 불러옵니다.
4. `html_attr()` 함수를 이용하여 href 속성을 불러옵니다.

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
##  /item/main.nhn?code=005935 /item/board.nhn?code=005935 
##                    "005935"                    "005935" 
##  /item/main.nhn?code=005380 /item/board.nhn?code=005380 
##                    "005380"                    "005380" 
##  /item/main.nhn?code=068270 /item/board.nhn?code=068270 
##                    "068270"                    "068270"
```

`sapply()` 함수를 통해 symbol 변수의 내용들에 `function()`을 적용하며, `substr()` 함수 내에 `nchar()` 함수를 적용하여 마지막 6자리 글자만을 추출하도록 합니다.

결과를 살펴보면 티커에 해당하는 마지막 6글자만 추출되지만, 동일한 내용이 두번 연속하여 추출됩니다. 이는 main.nhn?code= 에 해당하는 부분은 종목명에 설정된 링크, board.nhn?code= 에 해당하는 부분은 토론실에 설정된 링크이기 때문입니다. 


```r
symbol = unique(symbol)
print(head(symbol, 10))
```

```
##  [1] "005930" "000660" "005935" "005380" "068270"
##  [6] "051910" "012330" "005490" "017670" "055550"
```

`unique()` 함수를 이용하여 중복되는 티커를 제거하면 우리가 원하는 티커 부분만 깔끔하게 정리가 됩니다. 해당 내용을 위에서 구한 table에 입력한 후 데이터를 다듬는 과정은 다음과 같습니다.


```r
table$N = symbol
colnames(table)[1] = '종목코드'
 
rownames(table) = NULL
ticker[[j]] = table
```

1. 위에서 구한 티커를 N열에 입력해 줍니다.
2. 해당 열 이름을 **종목코드**로 변경합니다.
3. `na.omit()`을 통해 특정 행을 삭제하였으므로, 행 이름을 초기화 해주도록 합니다.
4. ticker의 j번째 리스트에 정리된 데이터를 입력해 줍니다.

위의 코드에서 i와 j값을 for loop를 이용하면 코스피와 코스닥 전 종목의 티커가 정리된 테이블을 만들 수 있습니다. 이를 전체 코드로 나타내면 다음과 같습니다.


```r
data = list()

# i = 0 은 코스피, i = 1 은 코스닥 종목
for (i in 0:1) {

  ticker = list()
  url =
    paste0('https://finance.naver.com/sise/',
             'sise_market_sum.nhn?sosok=',i,'&page=1')
  
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
    url = paste0(
      'https://finance.naver.com/sise/',
      'sise_market_sum.nhn?sosok=',i,"&page=",j)
    down_table = GET(url)
 
    Sys.setlocale("LC_ALL", "English")
    # 한글 오류 방지를 위해 영어로 로케일 언어 변경
 
    table = read_html(down_table, encoding = "EUC-KR") %>%
      html_table(fill = TRUE)
    table = table[[2]] # 원하는 테이블 추출
 
    Sys.setlocale("LC_ALL", "Korean")
    # 한글을 읽기위해 로케일 언어 재변경
 
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
