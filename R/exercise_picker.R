source("R/server_handler.R")


start_exercise_picker <- function(){

  courses <- get_home()$user$subscribed_courses
  courses <- lapply(courses %>% dplyr::select(year, name, series) %>% split(courses$year),
                    function(x){lapply(x %>% split(x$name), function(y){y$series})})
  courses <- courses[order(names(courses), decreasing=TRUE)]
  courses <- c("pick a course" = "", courses)


  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),
    gadgetTitleBar("Exercise picker", left = miniTitleBarCancelButton(), right = miniTitleBarButton("done", "Open", primary = TRUE)),
    miniContentPanel(
      tags$head(tags$style("
                       .double{
                         display: grid;
                         grid-template-columns: 1fr auto;
                         grid-gap: 0 10px;
                         align-items: center;
                       }
                       .triple{
                          display: grid;
                          grid-template-columns: 15px 15px 1fr;
                          grid-gap: 0 5px;
                          align-items: center;
                       }"),
                tags$link(href="https://fonts.googleapis.com/icon?family=Material+Icons", rel="stylesheet")),

      pickerInput("course", "Choose a course:", courses, width="100%", options = pickerOptions(container = "body")),
      pickerInput("series", "Choose a series:", list("serie" = ""), width="100%", options = pickerOptions(container = "body")),
      pickerInput("exercise", "Choose an exercise:", list("exercise" = ""), choicesOpt = list(), width="100%", options = pickerOptions(container = "body")),
    )
  )

  server <- function(input, output, session) {

    update_series <- function(){
      course_url <- input$course
      if(course_url != "" && !is.null(course_url)){
        series <- get_json(course_url)
        series <- series %>% dplyr::select(name, exercises, order, deadline)

        deadlines <- strptime(series$deadline, "%FT%X")
        formatted_deadlines <- format(deadlines, format="%d %B %Y %R")
        
        deadline_span <-case_when(
          is.na(formatted_deadlines)  ~ "<span></span>",
          deadlines < Sys.time() ~ sprintf("<span style='color: rgb(150, 150, 150); font-size:11px;'>%s</span>", formatted_deadlines), 
          TRUE ~                   sprintf("<span style='font-size:11px;'>%s</span>", formatted_deadlines)
        )

        dropdown_options <- sprintf("<div class='double'><span>%s</span>%s</div>", series$name, deadline_span)
        updatePickerInput(session, "series", choices = series$exercises, choicesOpt=list(content = dropdown_options))
      } else { #course url is null
        updatePickerInput(session, "series", choices = list("serie" = ""))
      }
    }

    update_exercises <- function(){
      course_url <- input$course
      serie_url <- input$series
      if((course_url != "" && !is.null(course_url)) && (serie_url != "" && !is.null(serie_url))){
        exercises <- get_json(serie_url)
        print(exercises)

        names <- exercises$name

        type_icons <-case_when(
          exercises$type == "ContentPage"  ~ "<span class='material-icons' style='font-size:13px;'>menu_book</span>",
          exercises$type == "Exercise"     ~ "<span class='material-icons' style='font-size:13px;'>terminal</span>",
          TRUE ~ "<span></span>"
        )
        
        attempted <- ifelse(exercises$type == "ContentPage", exercises$has_read, exercises$has_solution)
        completed_before_deadline <- ifelse(exercises$type == "ContentPage", exercises$has_read, exercises$accepted_before_deadline)
        deadline_expired <- FALSE
        status_icons <- case_when(
          !attempted & !deadline_expired ~ "<span></span>",
          deadline_expired  & completed_before_deadline  ~ "<span class='material-icons' style='color:green; font-size:13px;'>alarm_on</span>",
          deadline_expired  & !completed_before_deadline ~ "<span class='material-icons' style='color:red; font-size:13px;'>alarm_off</span>",
          !deadline_expired & completed_before_deadline  ~ "<span class='material-icons' style='color:green; font-size:13px;'>check</span>",
          !deadline_expired & !completed_before_deadline ~ "<span class='material-icons' style='color:red; font-size:13px;'>close</span>"
        )

        dropdown_options <- sprintf("<div class='triple'>%s<div>%s</div><div>%s</div></div>", status_icons, type_icons, names)
        updatePickerInput(session, "exercise", choices = exercises$url, choicesOpt=list(content = dropdown_options))
      } else {
        updatePickerInput(session, "exercise", choices = list("exercise" = ""))
      }
    }

    
    observeEvent(input$course, {
      update_series()
    })
    observeEvent(input$series, {
      update_exercises()
    })
    observeEvent(input$exercise, {
      if(input$exercise == ""){
        shinyjs::disable("done")
      } else {
        shinyjs::enable("done")
      }
    })

    observeEvent(input$done, {
      activity <- get_json(input$exercise)
      if(activity$type == "ContentPage"){
        activity_data <- load_reading_activity(activity$url)
        options("dodona_reading_url" = activity$url)
      } else if (activity$type == "Exercise"){
        activity_data <- load_exercise_activity(activity$url)
        open_r_script(activity)
        options("dodona_reading_url" = NULL)
      } else {
        stop(sprintf("Activity type (%s) not recognised.", activity$type))
      }
      refresh_viewer(generate_html(activity_data))
      stopApp()
    })
  }

  return(c(ui, server))
}
