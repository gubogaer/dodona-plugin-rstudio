api_token <- "gkMKIpu3ZibTNU8nXsgTidQFp-ECG_XxkZWyvcsrpS8"

submit_dialog <- function(){
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


    tryCatch(
        {
            lines <- get_submission()
            exercise_identification <- identify_exercise(lines)

            submission_url <- submit_code(lines, exercise_identification)
            submission_json <- wait_for_feedback(submission_url)
            stopApp(c(exercise_identification$exercise_url, submission_json))
        },
        error=function(cond) {
            output$text <- renderText({
                "something went wrong"
                #print(cond)
            })
        }
    )
    #get_index_content(exercise_url, submission_json$url)
    #refresh_viewer()
  }

  viewer <- shiny::dialogViewer("Loading", width=400, height=100)
  shiny::runGadget(ui, server, viewer = viewer)
}

get_submission <- function(){
    exercise_path <- rstudioapi::getSourceEditorContext()$path
    if(is.null(exercise_path)){
        stop("no exercise opened")
    }
    con <- file(exercise_path,"r")
    if(!isOpen(con, rw="read")){
        stop(paste0("could not read file (", exercise_path, ")"))
    }
    lines <- readLines(con)
    close(con)
    return(lines)
}


validate_url <- function(text) grepl("^.*#.*https://[^ ]*/courses/\\d+/series/\\d+/activities/\\d+.*$", text)
get_url <- function(text) gsub("^.*(https://[^ ]*/courses/\\d+/series/\\d+/activities/\\d+).*$", "\\1", text)
get_series <- function(url) as.integer(gsub("^.*https://.*/series/(\\d+).*$", "\\1", url))
get_course <- function(url) as.integer(gsub("^.*https://.*/courses/(\\d+).*$", "\\1", url))
get_activity <- function(url) as.integer(gsub("^.*https://.*/activities/(\\d+).*$", "\\1", url))

identify_exercise <- function(code_lines){
    first_line <- code_lines[1]
    if(!validate_url(first_line)){
        stop('invalid exercise url')
    }
    url <- get_url(first_line)
    return(list(
        url = url,
        series = get_series(url),
        course = get_course(url),
        activity = get_activity(url)
    ))
}


submit_code <- function(code_lines, exercise_identification){
    body_obj <- list(
        submission = list(
            code=unbox(paste0(code_lines, collapse="\n")),
            course_id=unbox(exercise_identification$course),
            series_id=unbox(exercise_identification$series),
            exercise_id=unbox(exercise_identification$activity)
        )
    )
    body = jsonlite::toJSON(body_obj)
    print(exercise_identification$url)
    print(body)

    resp <- httr::POST(
        "https://dodona.ugent.be/nl/submissions.json",
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
    return(parsed$url)
}


wait_for_feedback <- function(submission_url){
    print(submission_url)
    delay_grow_rate <- 1.5

    waiting_time <- 0
    maximal_waiting_time <- 60

    max_delay <- 5
    delay <- 0.1

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