library(shiny)

ui <- fluidPage(
  titlePanel("Avancerad Bioinformatik Web"),
  
  tabsetPanel(
    id = "main_tabs",
    
    tabPanel("Plot Viewer",
             sidebarLayout(
               sidebarPanel(
                 selectInput("plot_choice", "Choose a plot to display:",
                             choices = c("RndForestClass" = "Rplot.png",
                                         "RndForestReg" = "Rplot01.png"))
               ),
               mainPanel(
                 imageOutput("plot_image")
               )
             )
    ),
    
    tabPanel("Data Tools",
             sidebarLayout(
               sidebarPanel(
                 textInput("user_name", "Enter your name:"),
                 actionButton("submit", "Submit")
               ),
               mainPanel(
                 textOutput("greeting")
               )
             )
    )
  )
)
server <- function(input, output, session) {
  
  tabs_added <- reactiveVal(FALSE)  # Track if secret tabs are already added
  
  Valid_users <- c("dennis", "moa")
  
  observeEvent(input$submit, {
    if (tolower(input$user_name) == "dennis") {
      
      # Only add tabs if not already added
      if (!tabs_added()) {
        insertTab(inputId = "main_tabs",
                  tabPanel("Welcome",
                           sidebarLayout(
                             sidebarPanel(
                               h3("Welcome, admin!"),
                               actionButton("lock", "Lock")
                             ),
                             mainPanel(
                               textOutput("hello")
                             )
                           )
                           
                  ),  
                  target = "Data Tools",
                  position = "after",
                  select = TRUE
        )
        
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
  
  observeEvent(input$lock, {
    removeTab(inputId= "main_tabs",
              target= "Welcome"
    )
    tabs_added(FALSE)
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



shinyApp(ui, server)
