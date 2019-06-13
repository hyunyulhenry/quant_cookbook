library(dplyr)
library(stringr)

# 앞장에서 정리한 거래소 데이터 및 WICS 섹터 데이터를 불러옴

ticker = read.csv('KOR_ticker.csv', row.names = 1, stringsAsFactors = FALSE)
sector = read.csv('data_sector_wics.csv', row.names = 1, stringsAsFactors = FALSE)

ticker$종목코드 = str_pad(ticker$종목코드, width = 6, 'left', 0)
sector$종목코드 = str_pad(sector$종목코드, width = 6, 'left', 0)

intersect(names(ticker), names(sector)) # 겹치는 열이름 확인
setdiff(ticker$종목명, sector$종목명)
data_market = inner_join(ticker, sector, by = c('종목코드', '종목명'))
head(data_market)

data_market = as_tibble(data_market) # 보기 편한 티블 형태로 변경
head(data_market)

# glimpse - 데이터의 요약 정보 확인
glimpse(data_market)

# rename - 열 이름 변경일
names(data_market)
data_market = data_market %>%
  rename(시가총액 = 시가총액.원.)
# 앞의 변수가 변경될 이름, 뒤의 변수가 기존 이름
names(data_market)

# distinct - 고유 항목 선택
data_market %>%
  distinct(섹터)

# select - 원하는 열만 선택
data_market %>%
  select(종목명) %>% head()

data_market %>%
  select(종목명, PER, PBR) %>% head()

# -를 통해 제외 후 선택도 가능
data_market = data_market %>%
  select(-관리여부, -주당배당금, -게시물..일련번호, -총카운트,
         - 산업분류, - 현재가.종가., -전일대비)
names(data_market)


# select 응용, 시작, 끝, 가운데 포함되는 문자에 따라 선택 가능
data_market %>%
  select(starts_with('시')) %>% head()

data_market %>%
  select(ends_with('R')) %>% head()

data_market %>%
  select(contains('P')) %>% head()

# mutate - 열에 대한 편집
data_market = data_market %>%
  mutate(PBR = as.numeric(PBR),
         PER = as.numeric(PER),
         ROE = PBR / PER, # (Price / BPS) / (Price / EPS) = EPS / BPS = E / B 
         ROE = round(ROE, 4),
         style = ifelse(PBR < median(PBR, na.rm = TRUE),
               'value', 'growth'))

# mutate와 기능은 동일하지만, 편집한 데이터 만을 반환
data_market_ROE = data_market %>%
  transmute(ROE = PBR / PER)   
data_market_ROE %>% head()


# filter - 조건에 충족하는 행을 선택
data_market %>%
  select(종목명, PBR) %>%
  filter(PBR < 1) 

data_market %>%
  select(종목명, PER, PBR, ROE) %>%
  filter(PBR < 1 & PER < 20 & ROE > 0.1 )

# summarize - 요약 통계값 출력
data_market %>%
  summarize(PBR.med = median(PBR, na.rm = TRUE)) 

data_market %>%
  summarize(
    PBR.min = min(PBR, na.rm = TRUE),
    PBR.max = max(PBR, na.rm = TRUE),
    PBR.med = median(PBR, na.rm = TRUE)) 

# arrange - 정렬하기 (디폴트는 오름차순)
data_market %>%
  arrange(PBR) %>%
  select(종목명, PBR) %>%
  head(5)

# 내림차순의 경우 desc() 함수를 추가해주면 도
data_market %>%
  arrange(desc(ROE)) %>%
  select(종목명, ROE) %>%
  head(5)

data_market = data_market %>%
  mutate(시총비중 = 시가총액 / sum(시가총액)) %>%
  arrange(desc(시가총액))

data_market %>%
  select(종목명, 시총비중) %>% head(10)
  
# group_by - 그룹별로 데이터를 묶음

# 섹터별 종목 개수 출력
data_market %>%
  group_by(섹터) %>%
  summarize(n = n())

# 섹터별 PBR median 출력
data_market %>%
  group_by(섹터) %>%
  summarize(PBR.sector = median(PBR, na.rm = TRUE)) %>%
  arrange(PBR.sector)

# 섹터별 시총비중 합계 및 내림차순
data_market %>%
  group_by(섹터) %>%
  summarize(시총 = sum(시총비중)) %>%
  arrange(desc(시총))

write.csv(data_market, 'data_market.csv')
