source("R/exercise_picker.R")
source("R/exercise_viewer.R")
source("R/submission_handler.R")

exercise_picker <- function(){

  #testje()
  a <- start_exercise_picker()
  open_exercise(a)
  # print(a)
}

submit_exercise <- function(){
  tryCatch(
    {
      a <- submit_dialog()
      print(a)
    },
    error=function(cond) {
        print("window closed")
    }
  )


  #loading_screen()

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
    refresh_viewer()
    stopApp()

  }

  viewer <- shiny::dialogViewer("Loading", width=400, height=100)
  shiny::runGadget(ui, server, viewer = viewer)


}


