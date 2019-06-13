# wise index에서 섹터별 구성종목 크롤링
# http://www.wiseindex.com/Index/Index#/G10 
# 각 섹터별 클릭 후 Components 항목을 통해 종목 확인 가능

library(jsonlite)

sector.code = c(
  'G10', # 에너지
  'G15', # 소재
  'G20', # 산업재
  'G25', # 경기관소비재
  'G30', # 필수소비재
  'G35', # 건강관리
  'G40', # 금융
  'G45', # IT
  'G50', # 전기통신서비스
  'G55'  # 유틸리
)

date = '20181228'
data.full = list()

for (i in sector.code) {
  
  # first sector data 
  # i = 'G10'
  url = paste0(
    'http://www.wiseindex.com/Index/GetIndexComponets?ceil_yn=0&dt=',
    date,'&sec_cd=',i)
  
  # json 형태의 데이터 다운로드
  data = fromJSON(url)
  data = data$list
  
  # 원하는 열만 선택 후 열이름 변경
  data.sector = data[c('SEC_NM_KOR', 'CMP_CD', 'CMP_KOR')]
  colnames(data.sector) = c('섹터', '종목코드', '종목명')  
  
  data.full[[i]] = data.sector
  
  Sys.sleep(2)
}

data.full = do.call(rbind, data.full)
rownames(data.full) = NULL

write.csv(data.full, 'data_sector_wics.csv')