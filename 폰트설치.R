system(command = "wget http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip")
system(command = "unzip NanumFont_TTF_ALL.zip -d NanumFont")
system(command = "rm -f NanumFont_TTF_ALL.zip")
system(command = "fc-list :lang=ko")

library(showtext)
font_add(family = 'NanumGothic', regular = 'NanumFont/NanumGothic.ttf')
showtext_auto()

