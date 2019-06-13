ticker = read.csv("US_ticker.csv", row.names = 1)
setwd("./value_us")

library(magrittr)

data_csv = list()
for (i in 1 : nrow(ticker)) {
  
  name = ticker[i, 'Symbol'] %>% as.character()
  data_csv[[i]] = read.csv(paste0(name, "_value.csv"), row.names = 1)
  
}

item = data_csv[[1]] %>% colnames()
value_list = list()

for (i in 1 : length(item)) {
  value_list[[i]] = lapply(data_value, function(x) {
    if ( item[i] %in% colnames(x) ) {
      x[which(colnames(x) == item[i])]
    } else {
      NA
    }
  })
}

value_list = lapply(value_list, function(x) {do.call(rbind, x)})
value_list = do.call(cbind, value_list) %>% data.frame()

rownames(value_list) = ticker[, 'Symbol']
colnames(value_list) = item

write.csv(value_list, "US_value.csv")

