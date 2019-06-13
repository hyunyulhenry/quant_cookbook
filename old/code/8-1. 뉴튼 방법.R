f = function(x) {
  return(x^2 + 2*x - 4)
}
plot(f, xlim = c(-5, 5), ylim = c(-5, 5))
grid()
abline(a = 0, b = 0, col = 'red')

uniroot(f, c(-2, -4))
uniroot(f, c(0, 2))

#---#

f_exp = expression(x^2 + 2*x - 4)
eval(f_exp, list(x = 1))
D(f_exp, "x")

newton = function(f_exp, tol = 1E-12, x0=1, N = 100) {
  
  i = 1
  x1 = x0
  df_dx = D(f_exp, "x")
  result = list()
  
  while (i <= N) {
    
    x1 = x0 - (eval(f_exp, list(x = x0)) / eval(df_dx, list(x = x0)))
    
    result[[i]] = x1
    i = i+1
    if (abs(x1-x0) < tol) {
      break
    }
    x0 = x1
  }
  return(do.call(cbind,result))
}

newton(f_exp, x0 = -4)
newton(f_exp, x0 = 2)