

testAddin <- function() {
  library(jsonlite)
  library(miniUI)
  library(dplyr)
  library(shiny)
  library(rvest)
  library(xml2)
  a <<- a+1
  print(a)


  body = jsonlite::toJSON(list(
    code = "solution",
    course_id = "",
    series_id = "",
    exercise_id = ""
  ))

  #httr::POST(
  #  url = "https://dodona.ugent.be/nl/submissions.json",
  #  config = httr::add_headers('Authorization' = 'wtFi6Xvj2zby-jdnIco4XajTcsb8g02zSzLbzyaKTqg'),
  #  body = body,
  #  encode = c("json"),
  #  handle = NULL
  #)


  dark <- if(rstudioapi::getThemeInfo()$dark) "true" else "false"
  submission <- httr::GET('https://dodona.ugent.be/nl/submissions/5577625/',
                             httr::add_headers('Authorization' = 'wtFi6Xvj2zby-jdnIco4XajTcsb8g02zSzLbzyaKTqg', 'Accept' = 'text/html'))

  submission_raw <- httr::content(submission, type="text")
  print("submission succeeded")

  home_json <- httr::GET('https://dodona.ugent.be/nl/',
                         httr::add_headers("Content-type" = "application/json", 'Accept' = 'application/json', 'Authorization' = 'wtFi6Xvj2zby-jdnIco4XajTcsb8g02zSzLbzyaKTqg'))
  print(httr::content(home_json, type="text"))
  #subscribed_courses

  exercise_json <- httr::GET('https://dodona.ugent.be/nl/courses/376/series/4006/activities/1393749650/',
                             httr::add_headers("Content-type" = "application/json", 'Accept' = 'application/json', 'Authorization' = 'wtFi6Xvj2zby-jdnIco4XajTcsb8g02zSzLbzyaKTqg'))
  print(httr::content(exercise_json, type="text"))
  exercise <- httr::GET('https://medusa.ugent.be/nl/activities/1393749650/description/vI_NqImU5meG3IPW/',
                        query = list(dark = dark),
                        httr::add_headers('Accept' = 'text/html'))
  exercise_raw <- httr::content(exercise, type="text")
  print("exercise succeeded")


  tempDir <- tempfile()
  dir.create(tempDir)
  print("stap1 succeeded")
  htmlFile <- file.path(tempDir, "test.html")


  parsed_DOM <- read_html(submission_raw)
  print("stap1.5 succeeded")
  submission_div <- parsed_DOM %>% html_nodes("[class='card-supporting-text']")
  print("midden")
  submission_head <- parsed_DOM %>% html_nodes("head")
  print("stap2 succeeded")
  #exercise_div <- httr::read_html(exercise_raw)
  print("testjee")

  submission_body <- generate_exercise_header(submission_div, exercise_raw)

  submission_html <- paste0("<html>", submission_head, "<body>", submission_body, "</body></html>")

  writeBin(charToRaw(submission_html), htmlFile)
  rstudioapi::viewer(htmlFile)

}






start_exercising <- function(){
  if(!exists("inittt")) {
    inittt <<- TRUE
    a <<- TRUE
    print("a made")
  }
  print("next")

  testAddin()
}


addin <- function(){
  library(jsonlite)
  library(miniUI)
  library(dplyr)
  library(shiny)

  courses <- get_json("https://dodona.ugent.be/nl/")$user$subscribed_courses
  courses <- lapply(courses %>% select(year, name, series) %>% group_by(year) %>% split(courses$year), function(x){lapply(x %>% group_by(name) %>% split(x$name), function(y){y$series})})
  courses <- courses[order(names(courses), decreasing=TRUE)]
  courses <- c("pick a course" = "", courses)

  #print("////////////////////////////////////////////////////////////////////////////////")
  #print(courses)


  ui <- miniUI::miniPage(
    gadgetTitleBar("My Gadget"),
    miniContentPanel(
      selectInput("course", "Choose a course:", courses),
      selectInput("series", "Choose a series:", list()),
      selectInput("exercise", "Choose an exercise:", list())

      ## Your UI items go here.
    )
  )
  server <- function(input, output, session) {

    ## Your reactive logic goes here.

    # Listen for the 'done' event. This event will be fired when a user
    # is finished interacting with your application, and clicks the 'done'
    # button.

    update_series <- function(course_url){
      print("courses invalidated")
      if(course_url != "" & course_url != "a"){
        series <- get_json(course_url)
        #print(series)


        #code for selecting the best series
        selected_series_name <- ""
        if(nrow(series) > 0){
          for( i in 1:nrow(series)){
            deadline <- series[i, "deadline"]
            #print("===========raw deadline===============")
            #print(deadline)

            if(!is.na(deadline)){
              deadline <- sub(":([^:]*)$", "\\1", deadline)
              deadline <- strptime(deadline, "%FT%H:%M:%OS%z", tz = "Europe/Brussels")
              #print(deadline)
              if(deadline < Sys.time()){
                #print("yaaaaaaaaaaaaaaaaayyyyyyyyyyyyyyyyyyyyyyyyyyyy")
                selected_series_name <- series[i+1, "name"]
              }
            }
          }
        }
        print("selected_series_name>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print(selected_series_name)

        series <- series %>% select(name, exercises, order)
        # hacky way to make sure split doesn't change the order
        series$name <- factor(series$name, levels=unique(series$name))
        series <- series %>% split(series$name)
        series <- lapply(series, function(x){x$exercises})

        selected_series_value <- series[[selected_series_name]]
        if(is.null(selected_series_value)){
          series <- c("pick a series" = "", series)
          selected_series_value <- ""
        }


        #print("********************series updated*****************************************************************")
        #print(selected_series_value)
        #print(series)
        print("update series")
        updateSelectInput(session, "series",
                          choices = series,
                          selected = selected_series_value)
        update_exercises(selected_series_value)
      } else {
        updateSelectInput(session, "series",
                          choices = list())
      }

    }

    update_exercises <- function(session_url){
      print("series invalidated")
      #print("#######################exercises updated############################################################")
      #print(session_url)


      if(session_url != ""){
        print("   url empty")
        exercises <- get_json(session_url)
        selected_exercise_url <- NULL
        i <- 1



        if(!"has_correct_solution" %in% names(exercises)){
          exercises["has_correct_solution"] <- NA
        }


        exercises_test <- filter(exercises, type != "ContentPage")
        selected_exercise_url <- filter(exercises_test, !is.na(has_correct_solution) & !has_correct_solution)[1,]$url




        #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        #print(exercises)
        exercises <- exercises %>% select(name, url)
        exercises$name <- factor(exercises$name, levels=unique(exercises$name))
        exercises <- exercises %>% split(exercises$name)
        #print(exercises)
        exercises <- exercises %>% lapply(function(x) x$url)
        if (is.na(selected_exercise_url)){
          exercises <- c("v completed: pick one to remake" = "", exercises)
        }


        print("   exercises updated")
        print(exercises)
        print(selected_exercise_url)
        updateSelectInput(session, "exercise",
                          choices = exercises,
                          selected = selected_exercise_url)
      } else {
        print("   choices emptied")
        updateSelectInput(session, "exercise",
                          choices = list())
      }


    }
    observeEvent(input$course, {

      update_series(input$course)

    })
    observeEvent(input$series, {

      update_exercises(input$series)
    })
    observeEvent(input$done, stopApp())
  }
  viewer <- shiny::dialogViewer("lalalal")
  shiny::runGadget(ui, server, viewer = viewer)

}



get_json <- function(url){
  home_json <- httr::GET(url,
                         httr::add_headers(
                           "Content-type" = "application/json",
                           'Accept' = 'application/json',
                           'Authorization' = 'wtFi6Xvj2zby-jdnIco4XajTcsb8g02zSzLbzyaKTqg'))
  #print(fromJSON(httr::content(home_json, type="text")))
  fromJSON(httr::content(home_json, type="text"))
}











login <- function(callback = function(){}){

}


generate_exercise_header <- function(exercise, last_sumission){
  return(
    paste0("<style>
      .tab {
        overflow: hidden;
        background-color: #1976d2;
        height: 60px;
      }

      .tab button {
        background-color: inherit;
        border: none;
        outline: none;
        cursor: pointer;
        padding: 14px 16px;
        transition: 0.3s;
        font-size: 17px;
        color: white;
      }

      .tab button:hover {
        background-color: #1660a9;
      }

      .tab button.active {
        background-color: #1660a9;
      }

      .tabcontent {
        display: none;
      }
    </style>
    <script>
    function openTabi(evt, cityName) {
      var i, tabcontent, tablinks;
      tabcontent = document.getElementsByClassName('tabcontent');
      for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = 'none';
      }
      tablinks = document.getElementsByClassName('tablinks');
      for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(' active', '');
      }
      document.getElementById(cityName).style.display = 'block';
      evt.currentTarget.className += ' active';
    }
    </script>


    <div class='tab'>
      <button class='tablinks active' onclick=\"openTabi(event, 'last_submission')\">Last Submission</button>
      <button class='tablinks' onclick=\"openTabi(event, 'current_exercise')\">Exercise</button>
    </div>

    <div id='last_submission' class='tabcontent' style='display:block'>",
           exercise,
           "</div>

    <div id='current_exercise' class='tabcontent'>",
           last_sumission,
           "</div>

    ")
  )
}




