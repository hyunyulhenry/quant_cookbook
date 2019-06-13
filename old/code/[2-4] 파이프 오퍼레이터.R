# Pipe Operator (%>%)

# x %>% F is the same as F(x)
# x %>% G %>% F is the same as F(G(x))
# https://www.datacamp.com/community/tutorials/pipe-r-tutorial

x = c(0.3078, 0.2577, 0.5523, 0.0564, 0.4685,
      0.4838, 0.8124, 0.3703, 0.5466, 0.1703)

# (1) Line by Line
x1 = log(x)
x2 = diff(x1)
x3 = exp(x2)
round(x3, 2)

# (2) Using Bracket

round(exp(diff(log(x))), 2)

# (3) Using %>% Operator
library(magrittr)
x %>% log() %>% diff() %>% exp() %>% round(., 2)
