url = 'https://images.aqr.com/-/media/AQR/Documents/Insights/Data-Sets/Quality-Minus-Junk-Factors-Monthly.xlsx'
tf = tempfile(fileext = '.xlsx')
download.file(url, tf, mode = 'wb') # wb: binary

library(readxl)
excel_sheets(tf)

df_QMJ = read_xlsx(tf, sheet = 'QMJ Factors', skip = 18) %>% select(DATE, Global)
df_MKT = read_xlsx(tf, sheet = 'MKT', skip = 18) %>% select(DATE, Global)
df_SMB = read_xlsx(tf, sheet = 'SMB', skip = 18) %>% select(DATE, Global)
df_HML_Devil = read_xlsx(tf, sheet = 'HML Devil', skip = 18) %>% select(DATE, Global)
df_UMD = read_xlsx(tf, sheet = 'UMD', skip = 18) %>% select(DATE, Global)
df_RF = read_xlsx(tf, sheet = 'RF', skip = 18) 

df= Reduce(function(x, y) inner_join(x, y, by = 'DATE'),
       list(df_QMJ, df_MKT, df_SMB, df_HML_Devil, df_UMD, df_RF)) %>%
  set_names(c('DATE','QMJ', 'MKT', 'SMB', 'HML', 'UMD', 'RF')) %>% na.omit() %>%
  mutate(R_excess = QMJ - RF,
         Mkt_excess = MKT - RF)
  
reg = lm(R_excess ~ Mkt_excess + SMB + HML + UMD, data = df)
summary(reg)

library(stargazer)

stargazer(reg, type = 'text', out = 'data/reg_table.html')
