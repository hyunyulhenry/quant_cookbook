library(dplyr)
library(stringr)
library(ggplot2)
library(tidyr)

data_market = read.csv('data_market.csv', row.names = 1, stringsAsFactors = FALSE)
data_market$종목코드 = str_pad(data_market$종목코드, width = 6, 'left', 0)
data_market = as_tibble(data_market)

# ggplot(data, aes(x축, y축, 그룹화, 색상)) +
#   geom_그림형태 +
#   기타_속성

# 산점도 그리기
ggplot(data_market, aes(x = ROE, y = PBR)) +
  geom_point()

# x축과 y축을 원하는 범위로 제한
ggplot(data_market, aes(x = ROE, y = PBR)) +
  geom_point() +
  coord_cartesian(xlim = c(0, 0.30), ylim = c(0, 3))


# 섹터별 ROE, PBR의 median 값 구하기
data_market %>%
  group_by(섹터) %>%
    summarise(ROE = median(ROE, na.rm = TRUE),
              PBR = median(PBR, na.rm = TRUE)) %>%
    ggplot(aes(x = ROE, y = PBR,
               color = 섹터)) +
    geom_point(size = 4)

# 포인트 위에 텍스트 추가하기
data_market %>%
  group_by(섹터) %>%
  summarise(ROE = median(ROE, na.rm = TRUE),
            PBR = median(PBR, na.rm = TRUE)) %>%
  ggplot(aes(x = ROE, y = PBR,
             color = 섹터)) +
  geom_point(size = 3) +
  geom_text(aes(label=섹터), hjust= 0.5, vjust = 2, size = 3)

# PBR 히스토그램
ggplot(data_market, aes(x = PBR)) +
  geom_histogram(binwidth = 0.1) + 
  coord_cartesian(xlim = c(0, 10))

# Median 값을 선으로 추가해주기
ggplot(data_market, aes(x = PBR)) +
  geom_histogram(binwidth = 0.1,
                 color = 'blue', fill = 'blue') + 
  coord_cartesian(xlim = c(0, 10)) +
  geom_vline(xintercept = median(data_market$PBR, na.rm = TRUE),
             color = 'red') +
  annotate(geom = 'text',
           x = median(data_market$PBR, na.rm = TRUE) + 0.1,
           y = 20,
           label = 'Median PBR',
           angle = 90,
           vjust = 1,
           color = 'white')

data_market_gather = data_market %>%
  group_by(섹터) %>%
  summarize(PBR = median(PBR, na.rm = TRUE),
            ROE = median(ROE, na.rm = TRUE)) %>%
  gather(index, value, -섹터)

data_market_gather

data_market_gather %>%
  ggplot(aes(fill = 섹터, x = index, y = value)) +
  geom_bar(position = "dodge", stat = "identity") +
  xlab('섹터') +
  ylab('데이터')

