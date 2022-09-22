source("R/server_handler.R")

test_settings <- function(){

  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),
    gadgetTitleBar("My Gadget"),
    miniContentPanel(
        textInput("text", label = h3("API Token"))
    )
  )

  server <- function(input, output, session) {

    observeEvent(input$cancel, {
      stopApp()
    })

    observeEvent(input$done, {
      oldKey <- Sys.getenv("dodona_api_token")
      key <- trimws(input$text)


      Sys.setenv(dodona_api_token = key)

      # test key + update user id
      tryCatch(
        {
          json <- get_json("https://dodona.ugent.be/nl/profile")
          #options(dodona_user_id = json$id)
          Sys.setenv(dodona_user_id = json$id)
        },
        error=function(cond) {
            #options(dodona_api_token = oldKey)
            Sys.setenv(dodona_api_token = oldKey)
            message(cond)
        }
      )
      stopApp()
    })
  }

  viewer <- shiny::dialogViewer("lalalal")
  shiny::runGadget(ui, server, viewer = viewer)
}