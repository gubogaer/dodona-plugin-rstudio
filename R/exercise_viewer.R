source("R/server_handler.R")


# get_activity <- function(url){
# 
#       print("stap1.1")
#       test <- get_json(url)
#       print("stap1.2")
#       return(test)
# 
# }
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
  contentPage <- get_json(activity_url)
  description <- get_description(contentPage$description_url)

  list(
    type = unbox("ContentPage"),
    exercise = list(
      name = unbox(contentPage$name),
      url = unbox(contentPage$url),
      description = unbox(description),
      completed = unbox(contentPage$has_read)
    )
  )
}

load_exercise_activity <- function(exercise_url, submission_url = NULL){
  exercise <- get_json(exercise_url)
  tabFocus <- "Feedback"

  if (Sys.getenv("dodona_user_id") == ""){
    json <- get_json("https://dodona.ugent.be/nl/profile")
    Sys.setenv(dodona_user_id = json$id)
  }
  if (is.null(submission_url)){
    # find last submission TODO if there is one
    tabFocus <- "Description"
    submissions_url <- file.path(tools::file_path_sans_ext(exercise$url), "submissions")
    submissions <- get_json(submissions_url, query = list(user_id = Sys.getenv("dodona_user_id")))
    submission_url <- submissions[["url"]][1]
  }

  submission <- NULL
  # if still null this exercise has no solution yet
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
      description = unbox(description),
      completed = unbox(exercise$accepted)
    )
  )
}

get_description <- function(url){
  tryCatch(
    {
      get_html(url)
    },
    error=function(err){
      err$message <- paste("While fetching description", err, sep = " ")
      stop(err)
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
    error=function(err){
      err$message <- paste("While fetching a submission", err, sep = " ")
      stop(err)
    }
  )
}
