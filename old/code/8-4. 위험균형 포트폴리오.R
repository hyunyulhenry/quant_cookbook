#--- Risk Contribution ---#
get_RC = function(w, covmat) {
  port_vol = t(w) %*% covmat %*% w
  port_std = sqrt(port_vol)
  
  MRC = (covmat %*% w) / as.numeric(port_std)
  RC = MRC * w
  RC = c(RC / sum(RC))
  
  return(RC)
}

#--- Import Data ---#
setwd("C:/Users/Henry/Dropbox/R 프로그래밍 강의/R을 이용한 퀀트 포트폴리오 만들기")

ret = read.csv("ret_allocation.csv", row.names = 1)
covmat = cov(ret)

#--- Tradional Allocation---#
ret_stock_bond = ret[, c(1,5)]
cov_stock_bond = cov(ret_stock_bond)
RC_stock_bond = get_RC(c(0.6, 0.4), cov_stock_bond)



#--- Risk Parity: (1) Equal Risk Contribtion ---#

objective = function(w) {
  RC = get_RC(w, covmat)
  Target = rep(0.1, 10)
  
  diff = sum((RC - Target)^2)
  return(diff)
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
get_RC(w, covmat)


#--- Risk Parity: (2) Risk Budget ---#

objective = function(w) {
  RC = get_RC(w, covmat)
  Target = c(0.15, 0.15, 0.15, 0.15, 0.10, 0.10, 0.05, 0.05, 0.05, 0.05)
  
  diff = sum((RC - Target)^2)
  return(diff)
}

hin.objective = function(w) {
  return(w)
}

heq.objective = function(w) {
  sum_w = sum(w)
  return( sum_w - 1 )
}

result = slsqp( x0 = rep(0.1, 10),
                fn = objective,
                hin = hin.objective,
                heq = heq.objective)
w = result$par
get_RC(w, covmat)
