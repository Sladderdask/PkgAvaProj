server <- function(input, output, session) {
  
  access_granted <- reactiveVal(FALSE)
  tabs_added <- reactiveVal(FALSE)  # Track if secret tabs are already added
  
  observeEvent(input$submit, {
    if (tolower(input$user_name) == "dennis") {
      
      access_granted(TRUE)
      
      # Only add tabs if not already added
      if (!tabs_added()) {
        insertTab(inputId = "main_tabs",
                  tabPanel("Welcome", h3("Welcome, admin!")),
                  target = "Data Tools",
                  position = "after",
                  select = TRUE)
        
        insertTab(inputId = "main_tabs",
                  tabPanel("Secret Tab", h4("You unlocked this tab, wooo hidden info!")),
                  target = "Welcome",
                  position = "after")
        
        tabs_added(TRUE)
      }
      
    } else {
      showModal(modalDialog(
        title = "Access Denied",
        "Incorrect name. Try again",
        easyClose = TRUE
      ))
    }
    
    output$greeting <- renderText({
      paste("Hello,", input$user_name, "!")
    })
  })
  
  output$plot_image <- renderImage({
    list(
      src = file.path("www", input$plot_choice),
      contentType = "image/png",
      width = "100%",
      alt = paste("Plot:", input$plot_choice)
    )
  }, deleteFile = FALSE)
}