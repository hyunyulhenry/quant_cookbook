result = tryCatch({
  expr
}, warning = function(w) {
  warning-handler-code
}, error = function(e) {
  error-handler-code
}, finally = {
  cleanup-code
})

# expr : 실행하고자 하는 코드
# warning-handler-code : 경고 발생시 실행할 구문
# error : 오류 발생시 실행할 구문
# finally : 여부에 관계없이 실행할 구문

number = data.frame(1,2,3,"4",5, stringsAsFactors = FALSE)
str(number)

for (i in number) {
  print(i + 1)
}

for (i in number) {
  tryCatch({
    print(i + 1)
  }, error = function(e) {
    print(paste('Error:', i))
    })
}

