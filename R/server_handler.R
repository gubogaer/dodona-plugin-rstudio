
#user specified data
language <- "nl"
api_token <- "wtFi6Xvj2zby-jdnIco4XajTcsb8g02zSzLbzyaKTqg"

#constants
base_url <- "https://dodona.ugent.be/"




#url fetch
get_html <- function(url){
  dark <- if(rstudioapi::getThemeInfo()$dark) "true" else "false"
  response <- httr::GET(tools::file_path_sans_ext(url),
           query = list(dark = dark),
           httr::add_headers(
             "Content-type" = "text/html",
             'Accept' = 'text/html',
             'Authorization' = api_token
           ))
  httr::content(response, type="text")
}

get_json <- function(url){
  home_json <- httr::GET(tools::file_path_sans_ext(url),
                         httr::add_headers(
                           "Content-type" = "application/json",
                           'Accept' = 'application/json',
                           'Authorization' = api_token
                         ))
  jsonlite::fromJSON(httr::content(home_json, type="text"))
}

get_home <- function(){
  get_json(paste0(base_url, language))
}

post_json <- function(url, body){
  post_reply <- httr::POST(
     url,
     config = httr::add_headers(
         'Authorization' = api_token,
         'content-type'= 'application/json',
         'Accept' = 'application/json'
     ),
     body = body
  )
  jsonlite::fromJSON(httr::content(post_reply, type="text"))
}
