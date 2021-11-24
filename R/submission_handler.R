get_series <- function(url) as.integer(gsub("^https://.*/series/(\\d+).*$", "\\1", url))
get_course <- function(url) as.integer(gsub("^https://.*/courses/(\\d+).*$", "\\1", url))
get_activity <- function(url) as.integer(gsub("^https://.*/activities/(\\d+).*$", "\\1", url))


submit_code <- function(code, url){
    print(url)
    print("***************************************************************************************")
    print("***************************************************************************************")
    print("***************************************************************************************")
    body <- paste0('{
                "submission":{
                    "code": "',      code, '",
                    "course_id":',   get_course(url), ',
                    "series_id":',   get_series(url), ',
                    "exercise_id":', get_activity(url), '
                }
            }')

    body_obj <- list(submission = list(code=unbox(code),
                            course_id=unbox(get_course(url)),
                            series_id=unbox(get_series(url)),
                            exercise_id=unbox(get_activity(url))
                        )
    )
    body_test <- jsonlite::toJSON(body_obj)
    body <- sprintf('
        {
            "submission":{
                "code": "%s",
                "course_id": %s,
                "series_id": %s,
                "exercise_id": %s
            }
        }', code, get_course(url), get_series(url), get_activity(url))

    print(body_test)
    result <- post_json("https://dodona.ugent.be/submissions.json", body_test)
    print(result)
    return(result$url)
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
        }

        submission <- get_json(submission_url)
    }
    return(submission)
}