
#user specified data
language <- "nl"

#constants
base_url <- "https://dodona.ugent.be/"


#url fetch
get_html <- function(url){
  dark <- if(rstudioapi::getThemeInfo()$dark) "true" else "false"
  resp <- GET(tools::file_path_sans_ext(url),
           query = list(dark = dark),
           add_headers(
             'Accept' = 'text/html',
             'Authorization' = Sys.getenv("dodona_api_token")
           ))
  print(resp)
  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "API POST request failed [%s]\n%s\n<>",
        status_code(resp)
      ),
      call. = FALSE
    )
  }
  return(httr::content(resp, type="text"))# type="text", as = "text", encoding = "UTF-8"
}

get_json <- function(url, query = list()){
  resp <- httr::GET(
      url, #timeout(5),
      httr::add_headers(
        'Accept' = 'application/json',
        'Authorization' = Sys.getenv("dodona_api_token")
      ),
      query = query
  )
  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "API GET request failed [%s]\n%s\n<>",
        status_code(resp)
      ),
      call. = FALSE
    )
  }
  return(jsonlite::fromJSON(httr::content(resp, type="text", encoding = "UTF-8")))
}

get_home <- function(){
  return(get_json(paste0(base_url, language)))
}

post_json <- function(url, body){
  resp <- httr::POST(
     url,
     config = add_headers(
         'Authorization' = Sys.getenv("dodona_api_token"),
         'content-type'= 'application/json',
         'Accept' = 'application/json'
     ),
     body = body
  )

  #parsed <- jsonlite::fromJSON(content(resp, type="text", encoding = "UTF-8"))
  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "API POST request failed [%s]\n%s\n<>",
        status_code(resp)
      ),
      call. = FALSE
    )
  }
  return()
}
