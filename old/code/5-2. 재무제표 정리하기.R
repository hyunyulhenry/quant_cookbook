ticker = read.csv("KOR_ticker.csv", row.names = 1)

library(magrittr)
library(data.table)

data_csv = list()
for (i in 1 : nrow(ticker)) {
  
  name = ticker[i, '종목코드'] %>% as.character()
  data_csv[[i]] = read.csv(paste0(name, "_fs_all.csv"), row.names = 1)
  # data_csv[[i]] = read.csv(paste0(name, "_fs_simple.csv"), row.names = 1)

}

item = data_csv[[1]] %>% rownames()
fs_list = list()

for (i in 1 : length(item)) {
  fs_list[[i]] = lapply(data_csv, function(x) {
    if ( item[i] %in% rownames(x) ) {
      x[which(rownames(x) == item[i]),]
    } else {
      matrix(NA, 1, 5) %>% data.frame()
    }
  })
}    

fs_list = lapply(fs_list, function(x) {rbindlist(x) %>% data.frame()})
fs_list = lapply(fs_list, function(x) {
  rownames(x) = ticker[,'종목코드'] %>% as.character()
  return(x)
  })
names(fs_list) = item

# write.csv(fs_list, "KOR_fs_list.csv") # Not Recommended
saveRDS(fs_list, "KOR_fs.Rds")
fs = readRDS("KOR_fs.Rds")
