source("R/server_handler.R")
source("R/index_generator.R")

open_exercise <- function(url) {
  url <- tools::file_path_sans_ext(url)
  # print("#######")
  # print(url)

  exercise <- get_json(url)
  open_r_script(exercise)
  index_path <- get_last_submission(exercise)


  # print("yay html_content captured")
  # print(class(html_content))
  # print(html_content)
  refresh_viewer()

}

loading_screen <- function(){
  index_path <- generate_index(
    "loading_screen",
    list()
  )
  print("++++++++++++++++++++++++++++++++++++++++++++++++\n")
  refresh_viewer()
}

refresh_viewer <- function(){
  server <- servr::browse_last(open=FALSE)
  if(is.null(server)){
    port <- servr::random_port()
    servr::httd("./dont_look_inside", port = port)
    server <- paste0("http://localhost:", port)
  }

  print(paste("the used server :", server))
  rstudioapi::viewer(server)
}


get_activity <- function(url){
  resp <- httr::GET(
    tools::file_path_sans_ext(url),
    httr::add_headers(
      "Content-type" = "application/json",
      'Accept' = 'application/json',
      'Authorization' = api_token
    )
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

load_activity <- function(url, submission_url = NULL){
  activity <- get_activity(url)

  if(activity$type == "Exercise"){
    load_reading_activity(activity)
  } else if (activity$type == "ContentPage"){
    load_exercise_activity(activity, submission_url)
  } else {
    stop(sprintf("Activity type (%s) not recognised.", activity$type))
  }
}

load_reading_activity <- function(contentPage){
  generate_index(
    list(
      "tabFocus" =
      "type" =
      "description" = get_description()
    )
  )
}

load_exercise_activity <- function(exercise, submission_url = NULL){
  #open_r_script() with last submitted code
  if (is.null(submission_url)){
    submissions_url <- file.path(tools::file_path_sans_ext(exercise$url), "submissions")
    submissions <- get_json(submissions_url)
    last_submission_url <- submissions[["url"]][1]
  }

  generate_index(
    list(
      "tabFocus" =
      "type" =
      "submission" = list(
        "code" =
        "status" =
        "feedback" = list(

        )
      )
      "description" = get_description()
    )
  )
}

get_description <- function(url){
  tryCatch(
    {
      get_html(exercise$description_url)
    },
    error=function(cond){
      stop("failed to fetch description")
    }
  )
}

get_submission <- function(url){
  tryCatch(
    {
      submission_json <- get_json(url)
      submission_code <- submission_json[["code"]]
      feedback_names <- jsonlite::fromJSON(submission_json[["result"]])[["groups"]][["description"]]

      submission_html <- get_html(url)
      parsed_DOM <- read_html(submission_html)
      feedback_content <- parsed_DOM %>% html_nodes(".feedback-tab-pane")
      feedback_content <- sprintf("%s", feedback_content)

    },
    error=function(cond){
      stop("failed to fetch submission")
    }
  )

}







#get_index_content <- function(exercise_url, submission_url = NULL){
#  exercise <- get_json(exercise_url)
#  get_last_submission(exercise, submission_url)
#}
#get_last_submission <- function(exercise, last_submission_url=NULL){
#  exercise_tab = 1
#  if(is.null(last_submission_url)){
#    submissions_url <- file.path(tools::file_path_sans_ext(exercise$url), "submissions")
#    submissions <- get_json(submissions_url)
#    last_submission_url <- submissions[["url"]][1]
#    exercise_tab=0
#  }
#
#  description <- get_html(exercise$description_url)
#
#  submission_json <- get_json(last_submission_url)
#  submission_code <- submission_json[["code"]]
#  feedback_names <- jsonlite::fromJSON(submission_json[["result"]])[["groups"]][["description"]]
#
#  submission_html <- get_html(last_submission_url)
#  parsed_DOM <- read_html(submission_html)
#  feedback_content <- parsed_DOM %>% html_nodes(".feedback-tab-pane")
#  feedback_content <- sprintf("%s", feedback_content)
#
#  index_path <- generate_index(
#    "dodona_lite",
#    list(
#          "description" = description,
#          "code" = submission_code,
#          "feedback_names" = as.list(feedback_names),
#          "feedback_content" = as.list(feedback_content)
#        ),
#    exercise_tab=exercise_tab
#  )
#
#  return(index_path)
#}

open_r_script <- function(exercise){
  filename <- paste0(gsub('^_|_$', '', gsub("[\\.]+", "_", make.names(exercise$name))), "(", exercise$id, ").R")
  if(!file.exists(filename)){
    fileConn<-file(filename)
    writeLines(c(paste0("#", exercise$url), "", exercise$boilerplate), fileConn)
    close(fileConn)
  }

  rstudioapi::navigateToFile(filename)
}




