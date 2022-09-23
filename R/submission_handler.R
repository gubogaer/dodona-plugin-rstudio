read_activity <- function(exercise_url){
    exercise_identification <- identify_exercise(exercise_url)
    body_obj <- list(
        course_id=unbox(exercise_identification$course),
        series_id=unbox(exercise_identification$series),
        activity_id=unbox(exercise_identification$activity)
    )
    body = jsonlite::toJSON(body_obj)

    post_json(paste0("https://dodona.ugent.be/nl/activities/", exercise_identification$activity, "/activity_read_states/"),body)
}


loading_dialog <- function(title, callback_function, width=400, height=100){
    ui <- miniUI::miniPage(miniContentPanel(titlePanel(title)))
    server <- function(input, output, session) {
        tryCatch({
            result <- callback_function()
            stopApp(result)
        },
        error=function(err){
            message(err$message)
            stopApp()
        })
    }

    shiny::runGadget(shinyApp(ui,server), viewer = shiny::dialogViewer("Dodona lite", width=width, height=height))
}


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
