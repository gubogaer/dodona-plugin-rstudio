#https://dodona.ugent.be/nl/courses/804/series/9206/activities/945901930.json

a <- function(){
  stop("something is wrong")
}

b <- function(){
  a()
}

tryCatch({

}, )

tryCatch(
  {
    b()
  },
  error=function(cond) {
    print("yaaaay")
  }
)
