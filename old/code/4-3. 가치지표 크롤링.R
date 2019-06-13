ticker = read.csv("KOR_ticker.csv", row.names = 1)
setwd("./value")

library(rvest)
library(httr)
library(jsonlite)

# Fama French Style
for (i in 1:nrow(ticker)) {
  
  name = ticker[i, '종목코드'] %>% as.character()
  data_value = c()
  
  tryCatch({
    
    url = paste0("https://companyinfo.stock.naver.com/company/cF4002.aspx?cmp_cd=",
                 name,"frq=0&rpt=5&finGubun=MAIN&frqTyp=0&cn=")
    Sys.setlocale("LC_ALL", "English")
    data  = fromJSON(url)
    data = data[[2]] %>% data.frame()
    Sys.setlocale("LC_ALL", "Korean")
    
    data_table = cbind(data$DATA5)
    rownames(data_table) = data$ACC_NM
    
    type = c("PER", "PBR", "PCR", "PSR")
    data_value = data_table[sapply(type, function(x) {which(rownames(data_table) == x)}), ] 
    
  }, error = function(e) {
    data_value <<- NA
    print(paste0("Error in Ticker: ", name))}
  )
  write.csv(data_value, paste0(name, "_value.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(3)
  
}


# Devil's in HML
for (i in 1:nrow(ticker)) {
  
  name = ticker[i, '종목코드'] %>% as.character()
  data_value = c()
  
  tryCatch({
    
    url = paste0("https://companyinfo.stock.naver.com/company/cF4002.aspx?cmp_cd=",
                 name,"frq=0&rpt=5&finGubun=MAIN&frqTyp=0&cn=")
    Sys.setlocale("LC_ALL", "English")
    data = fromJSON(url)
    data = data[[2]] %>% data.frame()
    Sys.setlocale("LC_ALL", "Korean")
    
    data_table = cbind(data$DATA5)
    rownames(data_table) = data$ACC_NM
    
    type = c("EPS", "BPS", "CPS", "SPS")
    data_value = data_table[sapply(type, function(x) {which(rownames(data_table) == x)}), ]
    
    url = paste0("https://finance.naver.com/item/sise.nhn?code=",name)
    price = GET(url) %>%
      read_html(encoding = "euc-kr") %>%
      html_nodes(xpath = '//*[@id="content"]/div[2]/div[1]/table/tbody/tr[3]/td[2]/span') %>%
      html_text()
    
    price = gsub(",", "", price) %>% as.numeric()
    data_value = price / data_value
    names(data_value) = c("PER", "PBR", "PCR", "PSR")
    
    data_value[is.infinite(data_value)] = NA
    
  }, error = function(e) {
    data_value <<- NA
    print(paste0("Error in Ticker: ", name))}
  )
  
  write.csv(data_value, paste0(name, "_value.csv"))
  print(c(name, i / nrow(ticker)))
  Sys.sleep(3)
  
}
