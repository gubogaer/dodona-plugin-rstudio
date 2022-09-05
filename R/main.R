#source("R/exercise_picker.R")
#source("R/exercise_viewer.R")
#source("R/submission_handler.R")
#source("R/index_generator.R")
#source("R/settings.R")

settings <- function(){
  #TODO implement settings
}

exercise_picker <- function(){
  uiServer <- start_exercise_picker()
  activity0 <- shiny::runGadget(
    shinyApp(
      uiServer[[1]],
      uiServer[[2]],
      onStart = function() {
        cat("Doing application setup\n")
        onStop(function() {
          print("ààààààààààààààààààààààààààààààààààààààààà")
          #print(test)
          print("na het testje testje")
        })
      }
    ),
    viewer = shiny::dialogViewer("lalalal"),

  )
  #activity0 <- start_exercise_picker()
  # print("**********************************************************************************")
  #activity <- list(type="ContentPage", url="https://dodona.ugent.be/nl/courses/705/series/7671/activities/1781721204.json")
  handle_reset("https://dodona.ugent.be")

  #print(activity0)
  #print(activity0$url)
  #activity <- get_json(activity0$url)
  #activity_data <- NULL
  #
  #print(activity)
  #if(activity$type == "ContentPage"){
  #  print("test1")
  #  activity_data <- load_reading_activity(activity$url)
  #  print("test2")
  #} else if (activity$type == "Exercise"){
  #  activity_data <- load_exercise_activity(activity$url)
  #  open_r_script(activity)
  #} else {
  #  stop(sprintf("Activity type (%s) not recognised.", activity$type))
  #}
  #print("/////////////////////////////////////////////////////")
  #print(activity_data)
  #html <- generate_html(activity_data)
  #refresh_viewer(html)
  #tryCatch(
  #  {
  #
  #  },
  #  error=function(cond) {
  #      # TODO error popup
  #      print("an error occured")
  #  }
  #)
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
  server <- servr::browse_last(open=FALSE)
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
      code_lines <- get_submission_lines()
      exercise_url <- get_exercise_url(code_lines)

      serverUi <- submit_reading_dialog(exercise_url)

      viewer <- shiny::dialogViewer("Loading", width=400, height=100)
      print(serverUi[2])
      submission_url <- NULL
      submission_url <- shiny::runGadget(
        shinyApp(
          serverUi[[1]],
          serverUi[[2]],
          onStart = function() {
            cat("Doing application setup\n")
            onStop(function() {
              print("testje")
              activity_data <- load_exercise_activity(exercise_url, submission_url)
              print("na het testje testje")
              html <- generate_html(activity_data)
              refresh_viewer(html)
            })
          }
        ),
        viewer = viewer
      )


    },
    error=function(cond) {
      message(cond)
        print("window closedd")
    }
  )
}


submit_exercise <- function(){
  tryCatch(
    {

      #options(dodona_user_id = json$id)
      Sys.getenv("dodona_api_token")


      code_lines <- get_submission_lines()
      exercise_url <- get_exercise_url(code_lines)

      #submission_url <- submit_code(code_lines, exercise_url)
      #submission_json <- wait_for_feedback(submission_url)
      serverUi <- submit_dialog(code_lines, exercise_url)

      viewer <- shiny::dialogViewer("Loading", width=400, height=100)
      print(serverUi[2])
      submission_url <- NULL
      submission_url <- shiny::runGadget(
        shinyApp(
          serverUi[[1]],
          serverUi[[2]],
          onStart = function() {
            cat("Doing application setup\n")
            onStop(function() {
              print("testje")
              activity_data <- load_exercise_activity(exercise_url, submission_url)
              print("na het testje testje")
              html <- generate_html(activity_data)
              refresh_viewer(html)
            })
          }
        ),
        viewer = viewer
      )


    },
    error=function(cond) {
      message(cond)
        print("window closedd")
    }
  )


  #loading_screen()

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


validate_url <- function(text) grepl("^.*#.*https://[^ ]*/courses/\\d+/series/\\d+/activities/\\d+.*$", text)
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



test <- function(){
  ui <- miniUI::miniPage(
    miniContentPanel(
      titlePanel("Submitting ..."),
      actionButton("cancel", "cancel")
    )
  )
  #  url = "https://dodona.ugent.be/nl/submissions.json",

  server <- function(input, output, session) {
    exercise_path <- rstudioapi::getSourceEditorContext()$path

    con <- file(exercise_path,"r")
    lines <- readLines(con)
    close(con)
    exercise_url <- gsub("^.*#.*(https://dodona.ugent.be[^ ]*).*$", "\\1", lines[1])

    submission_url <- submit_code(paste0(lines, collapse="\n"), exercise_url)
    submission_json <- wait_for_feedback(submission_url)
    get_index_content(exercise_url, submission_json$url)
    #refresh_viewer()
    stopApp()

  }

  viewer <- shiny::dialogViewer("Loading", width=400, height=100)
  shiny::runGadget(ui, server, viewer = viewer)


}


