
#user specified data
language <- "nl"

#constants
base_url <- "https://dodona.ugent.be/"




#url fetch
get_html <- function(url){
  print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
  print(url)
  print("stap2.0.1")
  dark <- if(rstudioapi::getThemeInfo()$dark) "true" else "false"
  print("stap2.0.3")
  response <- GET(tools::file_path_sans_ext(url),
           query = list(dark = dark),
           add_headers(
             'Accept' = 'text/html',
             'Authorization' = Sys.getenv("dodona_api_token")
           ))
  print(response)
  print("stap2.0.3")
  content(response, type="text", encoding = "UTF-8")
}

get_json <- function(url, query = list()){
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    print(url)
    #print("stapje 1")
    #con <-url(tools::file_path_sans_ext(url), open = "r", blocking = TRUE,
    #  headers = c(
    #    "Content-type" = "application/json",
    #    'Accept' = 'application/json',
    #    'Authorization' = Sys.getenv("dodona_api_token")
    #  ))
    #print("stapje 2")
    #test_handle <- new_handle()
    #print("stapje 3")
    ##con <- url(tools::file_path_sans_ext(url), method = "libcurl", handle=test_handle)
    ##open(con, blocking = TRUE)
    #print("stapje 4")
    #test <- readLines(con, warn=FALSE)
    #print("stapje 5")
    ##close(con)
    #print(test)
    #return(jsonlite::fromJSON(test))

    #

    #op <- options(curl_interrupt=FALSE)
    #on.exit(options(op))
    #print(getOption("curl_interrupt"))
    #print('hier werkt het ook nog')

    tryCatch(
        {
          print(paste0("httr::GET('", url, "', httr::add_headers('Accept' = 'application/json','Authorization' = '", Sys.getenv("dodona_api_token"),"'))"))
          home_json <- httr::GET(url, #timeout(5),
              httr::add_headers(
                'Accept' = 'application/json',
                'Authorization' = Sys.getenv("dodona_api_token")
              ),
              query = query,
              fail = print,
              done = print)
          # handle_reset(url)
          print('hier heel misschien')
          print(home_json)
          print(jsonlite::fromJSON(httr::content(home_json, type="text", encoding = "UTF-8")))
          return(jsonlite::fromJSON(httr::content(home_json, type="text", encoding = "UTF-8")))
        },
        error=function(cond) {
            print("helaba")
            print(cond)
            message(cond)
        }
    )


}

get_home <- function(){
  get_json(paste0(base_url, language))
}

post_json <- function(url, body){
  resp <- POST(
     url,
     config = add_headers(
         'Authorization' = Sys.getenv("dodona_api_token"),
         'content-type'= 'application/json',
         'Accept' = 'application/json'
     ),
     body = body
  )

  parsed <- jsonlite::fromJSON(content(resp, type="text", encoding = "UTF-8"))

  if (status_code(resp) != 200) {
    stop(
      sprintf(
        "API request failed [%s]\n%s\n<>",
        status_code(resp),
        parsed
      ),
      call. = FALSE
    )
  }

  return(parsed)
}
