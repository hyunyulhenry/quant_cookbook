ticker = read.csv("KOR_ticker.csv", row.names = 1)
setwd("./value")

library(magrittr)

data_csv = list()
for (i in 1 : nrow(ticker)) {
  
  name = ticker[i, '종목코드'] %>% as.character()
  data_csv[[i]] = read.csv(paste0(name, "_value.csv"), row.names = 1) 
  
}

item = data_csv[[1]] %>% rownames()
value_list = list()

for (i in 1 : length(item)) {
  value_list[[i]] = lapply(data_csv, function(x) {
    if ( item[i] %in% rownames(x) ) {
      x[which(rownames(x) == item[i]),]
    } else {
      NA
    }
  })
}    

value_list = lapply(value_list, function(x) {do.call(rbind, x)})
value_list = do.call(cbind, value_list) %>% data.frame()

rownames(value_list) = ticker[, '종목코드']
colnames(value_list) = item

write.csv(value_list, "KOR_value.csv")

