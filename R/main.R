#source("R/exercise_picker.R")
#source("R/exercise_viewer.R")
#source("R/submission_handler.R")
#source("R/index_generator.R")
#source("R/settings.R")

settings <- function(){
  #TODO implement settings
}

exercise_picker <- function(){
  tryCatch(
    {
      uiServer <- start_exercise_picker()
      shiny::runGadget(
        shinyApp(
          uiServer[[1]],
          uiServer[[2]]#,
        ),
        viewer = shiny::dialogViewer("Dodona lite", width = 500, height = 400),
      )
    },
    error=function(cond) {
      error_popup(cond)
      message(cond)
    }
  )
}

open_r_script <- function(exercise){
  filename <- paste0(gsub('^_|_$', '', gsub("[\\.]+", "_", make.names(exercise$name))), "(", exercise$id, ").R")
  if(!file.exists(filename)){
    fileConn<-file(filename)
    writeLines(c(paste0("#", exercise$url), "", exercise$boilerplate), fileConn)
    close(fileConn)
  }
  rstudioapi::navigateToFile(filename)
}


refresh_viewer <- function(html){
  html_path <- file.path(getwd(), "dont_look_inside", "index.html")
  out <- file(html_path, 'w')
  write(html, file=out)
  close(out)

  # TODO use fixed port from settings file
  capture.output({server <- servr::browse_last(open=FALSE)}, type = "message")
  if(is.null(server)){
    port <- servr::random_port()
    servr::httd("./dont_look_inside", port = port)
    server <- paste0("http://localhost:", port)
  }
  print(paste("the used server :", server))
  rstudioapi::viewer(server)
}

mark_read <- function(){
  tryCatch(
    {
      exercise_url <- getOption("dodona_reading_url")
      if(is.null(exercise_url)){
        stop('your not even reading an exercise')
      }
      loading_dialog("Loading...", function(){
        read_activity(exercise_url)
        activity_data <- load_exercise_activity(exercise_url)
        html <- generate_html(activity_data)
        refresh_viewer(html)
      })
    },
    error = function(err) {
      message(err)
    },
    finally = options()
  )
}


submit_exercise <- function(){
  tryCatch(
    {
      code_lines <- get_submission_lines()
      exercise_url <- get_exercise_url(code_lines)

      loading_dialog("Submitting...", function(){
        submission_url <- submit_code(code_lines, exercise_url)
        wait_for_feedback(submission_url)
        activity_data <- load_exercise_activity(exercise_url, submission_url)
        html <- generate_html(activity_data, 1)
        refresh_viewer(html)
      })

    },
    error=function(cond) {
      message(cond)
    }
  )
}

get_submission_lines <- function(){
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


validate_url <- function(text) grepl("^.*#.*https://[^ ]*/courses/\\d+/series/\\d+/activities/\\d+[^\\d]*$", text)
get_url <- function(text) gsub("^.*(https://[^ ]*/courses/\\d+/series/\\d+/activities/\\d+).*$", "\\1", text)
get_exercise_url <- function(code_lines){
  first_line <- code_lines[1]
  if(!validate_url(first_line)){
    stop('invalid exercise url')
  }
  get_url(first_line)
}


settings <- function(){
  test_settings()
}


#test <- function(){
#  ui <- miniUI::miniPage(
#    miniContentPanel(
#      titlePanel("Submitting ..."),
#      actionButton("cancel", "cancel")
#    )
#  )
#  #  url = "https://dodona.ugent.be/nl/submissions.json",
#
#  server <- function(input, output, session) {
#    exercise_path <- rstudioapi::getSourceEditorContext()$path
#
#    con <- file(exercise_path,"r")
#    lines <- readLines(con)
#    close(con)
#    exercise_url <- gsub("^.*#.*(https://dodona.ugent.be[^ ]*).*$", "\\1", lines[1])
#
#    submission_url <- submit_code(paste0(lines, collapse="\n"), exercise_url)
#    submission_json <- wait_for_feedback(submission_url)
#    get_index_content(exercise_url, submission_json$url)
#    #refresh_viewer()
#    stopApp()
#
#  }
#
#  viewer <- shiny::dialogViewer("Loading", width=400, height=100)
#  shiny::runGadget(ui, server, viewer = viewer)
#}
