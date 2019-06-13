ticker = read.csv("US_ticker.csv", row.names = 1)
setwd("./fs_US")

library(magrittr)
library(data.table)

data_csv = list()
for (i in 1 : nrow(ticker)) {
  
  name = ticker[i, 'Symbol'] %>% as.character()
  data_csv[[i]] = read.csv(paste0(name, "_fs.csv"), row.names = 1)
  
}

item = data_csv[[1]] %>% rownames()
fs_list = list()

for (i in 1 : length(item)) {
  fs_list[[i]] = lapply(data_fs, function(x) {
    if ( item[i] %in% rownames(x) ) {
      cbind(x[which(rownames(x) == item[i]),],
            matrix(NA, 1, 4 - ncol(x)) %>% data.frame())
    } else {
      matrix(NA, 1, 4) %>% data.frame()
    }
  })
}

fs_list = lapply(fs_list, function(x) {rbindlist(x) %>% data.frame()})
fs_list = lapply(fs_list, function(x) {
  rownames(x) = ticker[,'Symbol'] %>% as.character()
  return(x)
})
names(fs_list) = item

saveRDS(fs_list, "US_fs.Rds")
