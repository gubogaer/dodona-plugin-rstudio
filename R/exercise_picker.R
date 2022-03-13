source("R/server_handler.R")


start_exercise_picker <- function(){

  # print("exercise picker started")

  courses <- get_home()$user$subscribed_courses
  courses <- lapply(courses %>% select(year, name, series) %>% split(courses$year),
                    function(x){lapply(x %>% split(x$name), function(y){y$series})})
  courses <- courses[order(names(courses), decreasing=TRUE)]
  courses <- c("pick a course" = "", courses)


  images <- c(
    "<div class='tuple'><span class='material-icons' style='color:red; font-size:13px;'>close</span><div>%s</div></div>",
    "<div class='tuple'><span class='material-icons' style='color:green; font-size:13px;'>done</span><div>%s</div></div>",
    "<div class='tuple'><div></div><div>%s</div></div>"
  )


  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),
    gadgetTitleBar("My Gadget"),
    miniContentPanel(
      tags$head(tags$style("
                       .tuple{
                          display: grid;
                          grid-template-columns: 15px 1fr;
                          grid-gap: 0 5px;
                          align-items: center;
                       }"),
                tags$link(href="https://fonts.googleapis.com/icon?family=Material+Icons", rel="stylesheet")),

      pickerInput("course", "<b>Choose a course:</b>", courses),
      pickerInput("series", "Choose a series:", list()),
      pickerInput("exercise", "Choose an exercise:", list(), choicesOpt = list()),
    )
  )

  server <- function(input, output, session) {

    update_series <- function(){
      course_url <- input$course
      # print(course_url)
      if(course_url != "" && !is.null(course_url)){
        series <- get_json(course_url)

        # print(series)

        series <- series %>% select(name, exercises, order)
        # hacky way to make sure split doesn't change the order
        series$name <- factor(series$name, levels=unique(series$name))
        series <- series %>% split(series$name)
        series <- lapply(series, function(x){x$exercises})

        updatePickerInput(session, "series", choices = series)

      } else {
        updatePickerInput(session, "series",choices = list())
      }
    }

    update_exercises <- function(){
      serie_url <- input$series
      print("exercise update")
      # print(serie_url)
      if(serie_url != "" && !is.null(serie_url)){
        exercises <- get_json(serie_url)
        accepted_before_deadline <- exercises[["accepted_before_deadline"]]
        accepted_before_deadline <- accepted_before_deadline + 1
        accepted_before_deadline[is.na(accepted_before_deadline)] <- 3

        # print(accepted_before_deadline)
        exercises <- exercises %>% select(name, url)
        exercises$name <- factor(exercises$name, levels=unique(exercises$name))
        exercises <- exercises %>% split(exercises$name)
        exercises <- exercises %>% lapply(function(x) x$url)


        updatePickerInput(session, "exercise", choices = exercises, choicesOpt=list(content = sprintf(images[accepted_before_deadline], names(exercises))))
      } else {
        updatePickerInput(session, "exercise", choices = list())
      }
    }

    update_button_enabled <- function(){
      print(input$exercise)
      if(is.null(input$exercise)){
        shinyjs::disable("done")
        print("dissabled")
      } else {
        shinyjs::enable("done")
        print("enabled")
      }
    }

    shinyjs::disable("done")
    observeEvent(input$exercise, {
      update_button_enabled()
    })

    observeEvent(input$course, {
      update_series()
      update_exercises()
      update_button_enabled()
    })
    observeEvent(input$series, {
      update_exercises()
      update_button_enabled()
    })
    observeEvent(input$done, stopApp(input$exercise))
  }

  viewer <- shiny::dialogViewer("lalalal")
  shiny::runGadget(ui, server, viewer = viewer)
}

