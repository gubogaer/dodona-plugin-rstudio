submit_reading_dialog <- function(exercise_url){
  ui <- miniUI::miniPage(
    miniContentPanel(
      titlePanel("Submitting reading exercise ..."),
      textOutput("text"),
      actionButton("test", "test")
    )
  )

  server <- function(input, output, session) {
    observeEvent(input$test, {
        print("testtttt")
        stopApp()
    })

    response <- read_activity(exercise_url)
    print("respoooooooonnnnnnnnsssssssseeeeeee")
    print(response)
    #submission_json <<- wait_for_feedback(submission_url)
    stopApp()

  }
  return(c(ui, server))
}

read_activity <- function(exercise_url){
    exercise_identification <- identify_exercise(exercise_url)
    body_obj <- list(
        submission = list(
            course_id=unbox(exercise_identification$course),
            series_id=unbox(exercise_identification$series),
            activity_id=unbox(exercise_identification$activity)
        )
    )
    body = jsonlite::toJSON(body_obj)
    print(exercise_url)
    print(body)

    resp <- httr::POST(
        paste0("https://dodona.ugent.be/nl/activities/", exercise_identification$activity, "/activity_read_states/"),
        config = httr::add_headers(
            'Authorization' = Sys.getenv("dodona_api_token"),
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

submit_dialog <- function(lines, exercise_url){
  ui <- miniUI::miniPage(
    miniContentPanel(
      titlePanel("Submitting ..."),
      textOutput("text"),
      actionButton("test", "test")
    )
  )

  server <- function(input, output, session) {
    observeEvent(input$test, {
        print("testtttt")
        stopApp()
    })

    submission_url <- submit_code(lines, exercise_url)
    submission_json <<- wait_for_feedback(submission_url)
    stopApp()
    #tryCatch(
    #    {
    #    },
    #    error=function(cond) {
    #        output$text <- renderText({
    #            "something went wrong"
    #            #print(cond)
    #        })
    #    }
    #)
    ##get_index_content(exercise_url, submission_json$url)
    ##refresh_viewer()

    }
    return(c(ui, server))
}

# get_submission_lines <- function(){
#     exercise_path <- rstudioapi::getSourceEditorContext()$path
#     if(is.null(exercise_path)){
#         stop("no exercise opened")
#     }
#     con <- file(exercise_path,"r")
#     if(!isOpen(con, rw="read")){
#         stop(paste0("could not read file (", exercise_path, ")"))
#     }
#     lines <- readLines(con)
#     close(con)
#     return(lines)
# }


get_series <- function(url) as.integer(gsub("^.*https://.*/series/(\\d+).*$", "\\1", url))
get_course <- function(url) as.integer(gsub("^.*https://.*/courses/(\\d+).*$", "\\1", url))
get_activity_id <- function(url) as.integer(gsub("^.*https://.*/activities/(\\d+).*$", "\\1", url))
identify_exercise <- function(exercise_url){
    return(list(
        series = get_series(exercise_url),
        course = get_course(exercise_url),
        activity = get_activity_id(exercise_url)
    ))
}


submit_code <- function(code_lines, exercise_url){
    exercise_identification <- identify_exercise(exercise_url)
    body_obj <- list(
        submission = list(
            code=unbox(paste0(code_lines, collapse="\n")),
            course_id=unbox(exercise_identification$course),
            series_id=unbox(exercise_identification$series),
            exercise_id=unbox(exercise_identification$activity)
        )
    )
    body = jsonlite::toJSON(body_obj)
    print(exercise_url)
    print(body)

    resp <- httr::POST(
        "https://dodona.ugent.be/nl/submissions.json",
        config = httr::add_headers(
            'Authorization' = Sys.getenv("dodona_api_token"),
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
    return(parsed$url)
}


wait_for_feedback <- function(submission_url){
    print(submission_url)
    delay_grow_rate <- 1.5

    waiting_time <- 0
    maximal_waiting_time <- 60

    max_delay <- 6
    delay <- 0.5

    submission <- get_json(submission_url)
    while(submission$status %in% c("running", "queued")){
        Sys.sleep(delay)
        waiting_time <- waiting_time + delay
        delay <- min(delay * delay_grow_rate, max_delay)

        if(waiting_time > maximal_waiting_time){
            #something went wrong?
            stop("timout while waiting for solution")
        }

        submission <- get_json(submission_url)
    }
    return(submission)
}
