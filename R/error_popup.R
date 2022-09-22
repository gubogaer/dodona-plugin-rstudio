error_dialog <- function(message){
  ui <- miniUI::miniPage(
    miniContentPanel(
      titlePanel("Following error occured:"),
      textOutput(message),
      actionButton("close", "Close")
    )
  )

  server <- function(input, output, session) {
    observeEvent(input$close, {
        stopApp()
    })
  }
  return(c(ui, server))
}

error_popup <- function(message){
    viewer <- shiny::dialogViewer("Error", width=400, height=100)
    serverUi <- error_dialog(message)
    shiny::runGadget(
        shinyApp(
          serverUi[[1]],
          serverUi[[2]],
        ),
        viewer = viewer
      )
}