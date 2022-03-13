
#user specified data
language <- "nl"
api_token <- "gkMKIpu3ZibTNU8nXsgTidQFp-ECG_XxkZWyvcsrpS8"

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
  httr::content(response, type="text", encoding = "UTF-8")
}

get_json <- function(url){
  home_json <- httr::GET(tools::file_path_sans_ext(url),
                         httr::add_headers(
                           "Content-type" = "application/json",
                           'Accept' = 'application/json',
                           'Authorization' = api_token
                         ))
  jsonlite::fromJSON(httr::content(home_json, type="text", encoding = "UTF-8"))
}

get_home <- function(){
  get_json(paste0(base_url, language))
}

post_json <- function(url, body){
  resp <- httr::POST(
     url,
     config = httr::add_headers(
         'Authorization' = api_token,
         'content-type'= 'application/json',
         'Accept' = 'application/json'
     ),
     body = body
  )

  parsed <- jsonlite::fromJSON(httr::content(resp, type="text", encoding = "UTF-8"))

  if (httr::status_code(resp) != 200) {
    stop(
      sprintf(
        "API request failed [%s]\n%s\n<>",
        httr::status_code(resp),
        parsed
      ),
      call. = FALSE
    )
  }

  return(parsed)
}
