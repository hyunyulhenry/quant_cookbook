library(dplyr)
library(stringr)

data_value_krx = read.csv('data_value_krx.csv', row.names = 1, stringsAsFactors = FALSE)
data_sector_krx = read.csv('data_sector_krx.csv', row.names = 1, stringsAsFactors = FALSE)

# 행 갯수를 확인해보면 데이터의 종목수가 다름
nrow(data_value_krx)
nrow(data_sector_krx)

# 한국거래소에서 다운로드 받은 두개 데이터를 비교 및 통합
intersect(data_sector_krx$종목명, data_value_krx$종목명) %>% length()
setdiff(data_sector_krx$종목명, data_value_krx$종목명) %>% length()

# 차이나는 종목 확인
# 해외종목, 상장펀드 등이 차이
setdiff(data_sector_krx$종목명, data_value_krx$종목명) 

data.left = left_join(data_value_krx, data_sector_krx, by = c('종목코드', '종목명'))
data.right = right_join(data_value_krx, data_sector_krx, by = c('종목코드', '종목명'))
data.inner = inner_join(data_value_krx, data_sector_krx, by = c('종목코드', '종목명'))
data.full = full_join(data_value_krx, data_sector_krx, by = c('종목코드', '종목명'))

nrow(data.left)
nrow(data.right)
nrow(data.inner)
nrow(data.full)

# 시가총액 순으로 정렬
data.inner = data.inner[order(desc(data.inner$시가총액.원.)), ]

# 첫번째 열 삭제 
data.inner = data.inner[, -1]

# 스팩 종목 확인 및 삭제
data.inner[grepl('스팩', data.inner[, '종목명']), '종목명']
data.inner = data.inner[!grepl('스팩', data.inner[, '종목명']), ]

# 우선주 확인 및 삭제
# 우선주의 경우 끝이 '우', '우B', '우C'로 끝남

data.inner[str_sub(data.inner[, '종목명'], -1, -1) == '호', '종목명']
data.inner[str_sub(data.inner[, '종목명'], -2, -1) == '우B', '종목명']
data.inner[str_sub(data.inner[, '종목명'], -2, -1) == '우C', '종목명']  
data.inner[str_sub(data.inner[, '종목명'], -1, -1) == '우C', '종목명'] 

data.inner = data.inner[str_sub(data.inner[, '종목명'], -1, -1) != '우', ]
data.inner = data.inner[str_sub(data.inner[, '종목명'], -2, -1) != '우B', ]
data.inner = data.inner[str_sub(data.inner[, '종목명'], -2, -1) != '우C', ]      

rownames(data.inner) = NULL
write.csv(data.inner, 'KOR_ticker.csv')
