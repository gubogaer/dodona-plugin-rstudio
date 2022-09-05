source("R/server_handler.R")


# open_exercise <- function(url) {
#   url <- tools::file_path_sans_ext(url)
#   # print("#######")
#   # print(url)
#
#   exercise <- get_json(url)
#   open_r_script(exercise)
#   index_path <- get_last_submission(exercise)
#
#
#   # print("yay html_content captured")
#   # print(class(html_content))
#   # print(html_content)
#   refresh_viewer()
#
# }

# loading_screen <- function(){
#   index_path <- generate_index(
#     "loading_screen",
#     list()
#   )
#   print("++++++++++++++++++++++++++++++++++++++++++++++++\n")
#   refresh_viewer()
# }




get_activity <- function(url){

      print("stap1.1")
      test <- get_json(url)
      print("stap1.2")
      return(test)

}

# load_activity <- function(url, submission_url = NULL){
#   activity <- get_activity(url)
#
#   if(activity$type == "ContentPage"){
#     load_reading_activity(activity)
#   } else if (activity$type == "Exercise"){
#     load_exercise_activity(activity, submission_url)
#   } else {
#     stop(sprintf("Activity type (%s) not recognised.", activity$type))
#   }
# }

load_reading_activity <- function(activity_url){
  print("stap1")
  contentPage <- get_json(activity_url)
  print("stap2")
  description <- get_description(contentPage$description_url)
  print("stap3")



  list(
    type = unbox("ContentPage"),
    exercise = list(
      name = unbox(contentPage$name),
      url = unbox(contentPage$url),
      description = unbox(description)
    )
  )
}

load_exercise_activity <- function(exercise_url, submission_url = NULL){
  exercise <- get_json(exercise_url)
  tabFocus <- "Feedback"
  if (is.null(submission_url)){
    # find last submission TODO if there is one
    tabFocus <- "Description"
    submissions_url <- file.path(tools::file_path_sans_ext(exercise$url), "submissions")
    submissions <- get_json(submissions_url, query = list(user_id = Sys.getenv("dodona_user_id")))
    submission_url <- submissions[["url"]][1]
  }

  submission <- NULL
  # if still null this exercise has no solution yet
  print("555555555555555555555555555555555555555555555555555")
  print(submission_url)
  if (!is.null(submission_url)){
    submission <- get_submission(submission_url)
  }

  description <- get_description(exercise$description_url)

  list(
    type = unbox("Exercise"),
    submission = submission,
    exercise = list(
      name = unbox(exercise$name),
      url = unbox(exercise$url),
      description = unbox(description)
    )
  )
}

get_description <- function(url){
  tryCatch(
    {
      print("stap 2.0")
      get_html(url)
    },
    error=function(cond){
      print(cond)
      stop("failed to fetch description")
    }
  )
}

get_submission <- function(url){
  tryCatch(
    {
      submission_json <- get_json(url)
      feedback_names <- jsonlite::fromJSON(submission_json[["result"]])[["groups"]][["description"]]

      submission_html <- get_html(url)
      parsed_DOM <- read_html(submission_html)
      feedback_content <- parsed_DOM %>% html_nodes(".feedback-tab-pane > .groups")
      feedback_content <- as.list(map(sprintf("%s", feedback_content), function(x){unbox(x)}))
      names(feedback_content) <- feedback_names

      list(
        created_at =  unbox(submission_json[["created_at"]]),
        user_url =    unbox(submission_json[["user"]]),
        code =        unbox(submission_json[["code"]]),
        status =      unbox(submission_json[["status"]]),
        feedback =    feedback_content
      )
    },
    error=function(cond){
      print(cond)
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






