#--- Diversification Effect ---#

diver.effect = function(cor) {

  wt = c(0.5, 0.5)
  vol = c(0.09, 0.09)
  std = sqrt(vol)
  
  port.vol = wt[1]^2*std[1]^2 + wt[2]^2*std[2]^2 + 
    2*wt[1]*wt[2]*std[1]*std[2]*cor
  return(port.vol)

}

diver.effect(1.0)
diver.effect(0.5)
diver.effect(0.0)
diver.effect(-0.5)
diver.effect(-1.0)


#--- Import Data ---#

setwd("C:/Users/Henry/Dropbox/R 프로그래밍 강의/R을 이용한 퀀트 포트폴리오 만들기")

ret = read.csv("ret_allocation.csv", row.names = 1)
covmat = cov(ret)

#--- Min Vol: (1) Using slsqp with Transformation ---#

objective = function(w) {
  corr = cov2cor(covmat)
  obj = t(w) %*% corr %*% w
  return(obj)
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
w = w / sqrt(diag(covmat))
w = round(w, 4)

w = w / sum(w)
w = round(w, 4)


#--- Min Vol: (2) Using slsqp with Duality ---#

objective = function(w) {
  obj = t(w) %*% covmat %*% w
  return(obj)
}

hin.objective = function(w) {
  return(w)
}

heq.objective = function(w) {
  sum.prod = (w %*% sqrt(diag(covmat))) - 1
  return(sum.prod)
}

result = slsqp( x0 = rep(0.1, 10),
                fn = objective,
                hin = hin.objective,
                heq = heq.objective)

w = result$par
w = round(w, 4)

w = w / sum(w)
w = round(w, 4)


#--- Min Vol: (3) Using slsqp with Min (-)DR ---#

objective = function(w) {
  nom = w %*% sqrt(diag(covmat))
  denom = sqrt(t(w) %*% covmat %*% w)
  dr = nom / denom
  return(-dr)
}

hin.objective = function(w) {
  return(w)
}

heq.objective = function(w) {
  return( sum(w) - 1 )
}

result = slsqp( x0 = rep(0.1, 10),
                fn = objective,
                hin = hin.objective,
                heq = heq.objective)

w = result$par
w = round(w, 4)


#--- Min Vol: (4) Using solve.QP ---#

Dmat = covmat
dvec = rep(0, 10)
Amat = t(rbind(sqrt(diag(covmat)), diag(10)))
bvec = c(1, rep(0, 10))
meq = 1


library(quadprog)
result = solve.QP(Dmat, dvec, Amat, bvec, meq)
w = result$solution

w = w / sum(w)
w = round(w, 4)


#--- Min Vol: (5) Using optimalPortfolio---#

library(RiskPortfolios)
w = optimalPortfolio(covmat, control = list(type = 'maxdiv', constraint = 'lo'))
w = round(w, 4)


#--- Min Vol: (6) Using slsqp with Transformation + Add Constraints---#

objective = function(w) {
  corr = cov2cor(covmat)
  obj = t(w) %*% corr %*% w
  return(obj)
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
                heq = heq.objective,
                lower = rep(0.05, 10), # Add Lower Constraint
                upper = rep(0.20, 10)) # Add Upper Constraint

w = result$par
w = w / sqrt(diag(covmat))
w = round(w, 4)

w = w / sum(w)
w = round(w, 4)


#--- Min Vol: (7) Using optimalPortfolio + Add Constraints---#

w = optimalPortfolio(covmat, control = list(type = 'maxdiv', constraint = 'user',
                                            LB = rep(0.05, 10), UB = rep(0.20, 10)))
w = round(w, 4)


#--- Min Vol: (8) Using solve.QP + Add Constraints ---#

Dmat = covmat
dvec = rep(0, 10)
Alb = -rep(0.05, 10) %*% matrix(1, 1, 10) + diag(10)
Aub = rep(0.20, 10) %*% matrix(1, 1, 10) - diag(10)

Amat = t(rbind(sqrt(diag(covmat)), Alb, Aub))
bvec = c(1, rep(0, 10), rep(0, 10))
meq = 1

result = solve.QP(Dmat, dvec, Amat, bvec, meq)
w = result$solution
w = w / sum(w)
w = round(w, 4)


#--- Min Vol: (9) Using solve.QP + Add Differents Constraints ---#

Dmat = covmat
dvec = rep(0, 10)
Alb = -c(0.10, 0.10, 0.05, 0.05, 0.10, 0.10, 0.05, 0.05, 0.03, 0.03) %*% matrix(1, 1, 10) + diag(10)
Aub = c(0.25, 0.25, 0.20, 0.20, 0.20, 0.20, 0.10, 0.10, 0.08, 0.08) %*% matrix(1, 1, 10) - diag(10)

Amat = t(rbind(sqrt(diag(covmat)), Alb, Aub))
bvec = c(1, rep(0, 10), rep(0, 10))
meq = 1

result = solve.QP(Dmat, dvec, Amat, bvec, meq)
w = result$solution
w = w / sum(w)
w = round(w, 4)


#--- Min Vol: (10) Using solve.QP + Group Constraints ---#

Dmat = covmat
dvec = rep(0, 10)
Alb = -rep(0.05, 10) %*% matrix(1, 1, 10) + diag(10)
Aub = rep(0.20, 10) %*% matrix(1, 1, 10) - diag(10)
Agroup = rbind(
  -0.3 %*% matrix(1, 1, 10) + c(1,1,1,1,0,0,0,0,0,0),
  -0.3 %*% matrix(1, 1, 10) + c(0,0,0,0,1,1,0,0,0,0),
  -0.0 %*% matrix(1, 1, 10) + c(0,0,0,0,0,0,1,1,1,1),
  0.7 %*% matrix(1, 1, 10) - c(1,1,1,1,0,0,0,0,0,0),
  0.5 %*% matrix(1, 1, 10) - c(1,1,1,1,0,0,0,0,0,0),
  0.4 %*% matrix(1, 1, 10) - c(1,1,1,1,0,0,0,0,0,0)
)

Amat = t(rbind(sqrt(diag(covmat)), Alb, Aub, Agroup))
bvec = c(1, rep(0, 10), rep(0, 10), rep(0, 6))
meq = 1

result = solve.QP(Dmat, dvec, Amat, bvec, meq)
w = result$solution
w = w / sum(w)
w = round(w, 4)
