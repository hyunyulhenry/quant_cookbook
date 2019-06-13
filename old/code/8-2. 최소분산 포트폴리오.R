setwd("C:/Users/Henry/Dropbox/R 프로그래밍 강의/R을 이용한 퀀트 포트폴리오 만들기")

ret = read.csv("ret_allocation.csv", row.names = 1)
covmat = cov(ret)

#--- Risk Parity: (1) Using slsqp ---#

get_RC = function(w, covmat){
  port_vol = t(w) %*% covmat %*% w
  port_std = sqrt(port_vol)
  MRC = (covmat %*% w) / as.numeric(port_std)
  
  rc = w * MRC
  rc = rc / sum(rc)
  return(rc)
}

objective = function(w) {
  rc = get_RC(w, covmat)
  rc_target = matrix(1/ncol(covmat) * port_std, nrow(covmat), 1)
  sum_risk_diff = sum( (rc - rc_target)^2 )
}
  
hin.objective = function(w) {
  return(w)
}
  
heq.objective = function(w) {
  sum_w = sum(w)
  return( sum_w - 1 )
}
  
library(nloptr)
result = slsqp( x0 = rep(0.1, 10),
                fn = objective,
                hin = hin.objective,
                heq = heq.objective)

w = result$par
w = round(w, 4)

get_RC(w, covmat)

#--- Risk Parity: (2) Using cccp ---#

opt = rp(x0 = target, P = covmat, mrc = target, optctrl = optctrl)