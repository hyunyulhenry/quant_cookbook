set.seed(123)

knitr::opts_chunk$set(
  out.width = "100%",
  fig.align = 'center',
  fig.width = 6,
  fig.asp = 0.618,  # 1 / phi
  fig.show = 'hold',
  warning = FALSE,
  message = FALSE
)

if(!knitr:::is_html_output()) {
  options("width"=56)
  knitr::opts_chunk$set(
    warning = FALSE,
    message = FALSE
    )
  knitr::opts_chunk$set(fig.pos = 'h')
}

pdf.options(family = "Korea1deb")
options(scipen = 5)
options(digits = 4)

setHook(packageEvent("grDevices", "onLoad"),
        function(...){
          if(capabilities("aqua"))
            grDevices::quartzFonts(
              sans =grDevices::quartzFont(rep("AppleGothic",4)),
              serif=grDevices::quartzFont(rep("AppleMyungjo",4)))
          grDevices::pdf.options(family="Korea1")
          grDevices::ps.options(family="Korea1")
        }
)
attach(NULL, name = "KoreaEnv")
assign("familyset_hook",
       function() {
         macfontdevs=c("quartz","quartz_off_screen")
         devname=strsplit(names(dev.cur()),":")[[1L]][1]
         if (capabilities("aqua") &&
             devname %in% macfontdevs)
           par(family="sans")
       },
       pos="KoreaEnv")
setHook("plot.new", get("familyset_hook", pos="KoreaEnv"))
setHook("persp", get("familyset_hook", pos="KoreaEnv"))

library(showtext)
font_add(family = 'NanumGothic', regular = 'NanumFont/NanumGothic.ttf')
showtext_auto()

