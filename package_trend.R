cran_pkg_trend = function() {
  
  extract_url = function() {
    url <- list(
      archive = "https://cran-archive.r-project.org/bin/windows/contrib/",
      active = "https://cran.r-project.org/bin/windows/contrib/"
    )
    
    get_urls <- function(url) {
      txt = readLines(url)
      idx = grep("\\d.\\d+/", txt)
      txt[idx]
      versions = gsub(".*?>(\\d.\\d+(/)).*", "\\1", txt[idx])
      versions
      paste0(url, versions)
    }
    
    z = lapply(url, get_urls)
    unname(unlist(z))
  }
  
  
  # Given a CRAN URL, extract the number of packages and date
  extract_pkg_info = function(url) {
    extract_date = function(txt, fun = max) {
      txt = txt[ - grep("[(STATUS)|(PACKAGES)](.gz)*", txt)]
      pkgs = grep(".zip", txt)
      txt = txt[pkgs]
      ptn = ".*?>(\\d{4}-\\d{2}-\\d{2}).*"
      idx = grep(ptn, txt)
      date = gsub(ptn, "\\1", txt[idx])
      date = as.Date(date, format = "%Y-%m-%d")
      match.fun(fun)(date)
    }
    
    message(url)
    txt = readLines(url)
    count = length(grep(".zip", txt))
    
    data.frame(
      version = basename(url),
      date = extract_date(txt),
      pkgs = count
    )
  }
  
  
  # Get the list of CRAN URLs
  CRAN_urls = extract_url()
  
  # Extract package information
  pkgs = lapply(CRAN_urls, extract_pkg_info)
  pkgs = do.call(rbind, pkgs)
  
  return(pkgs)
  
}

tbl = cran_pkg_trend()
write.csv(tbl, 'package_trend.csv')