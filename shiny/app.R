library(shiny)
library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)

# Help shiny find the images
addResourcePath("imgs", "shiny/www")  # maps /imgs to the www folder

# Connect to the database
conn <- dbConnect(SQLite(), "src/DatabasLite.db")

ui <- fluidPage(
  titlePanel("Avancerad Bioinformatik Web"),

  tabsetPanel(
    id = "main_tabs",

    # First tab - plot viewer
    tabPanel("PNG Viewer",
      sidebarLayout(
        sidebarPanel(
          selectInput("selected_image", "Choose an image:", choices = list.files("shiny/www", pattern = "\\.png$"))
        ),
        mainPanel(
          uiOutput("image_display")
        )
      ),
    ),
    # Second tab - authentication
    tabPanel("Authentication",
             sidebarLayout(
               sidebarPanel(
                 textInput("user_name", "Enter your name:"),
                 actionButton("submit", "Submit")
               ),
               mainPanel(
                 textOutput("greeting")
               )
             )
    ),

    # NEW TAB - RNA Threshold Plot
    tabPanel("RNA Threshold Plot",
      sidebarLayout(
        sidebarPanel(
          sliderInput("th", "FPKM Threshold:", min = 0, max = 20, value = 3),
          sliderInput("alpha", "opacity", min = 0.005, max = 0.1, value = 0.05, step = 0.005)
        ),
        mainPanel(
          plotOutput("rna_plot")
         )
       )
    )
  )
)

server <- function(input, output, session) {

  tabs_added <- reactiveVal(FALSE)
  Valid_users <- c("dennis", "moa")

  observeEvent(input$submit, {
    if (tolower(input$user_name) %in% Valid_users) {
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
          target = "RNA Threshold Plot",
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
    removeTab(inputId = "main_tabs", target = "Welcome")
    tabs_added(FALSE)
  })

  # Plot viewer image output
  output$image_display <- renderUI({
    req(input$selected_image)
    tags$img(src = paste0("imgs/", input$selected_image), style = "max-width:100%; height:auto;")
  })

  # Reactive data read
  rna_data <- reactive({
    dbGetQuery(conn, "
      SELECT RNA_seq.gene_name, RNA_seq.fpkm_counted, sgRNA_data.LFC
      FROM GeCKO
      INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
      INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
    ")
  })

  # Filter and classify genes based on threshold
  rna_filtered <- reactive({
    req(rna_data())
    data <- rna_data()

    data <- data %>%
      mutate(
        fpkm_binary = ifelse(fpkm_counted > input$th, 1, 0),
        category = case_when(
          fpkm_binary == 1 ~ "Activated Genes",
          TRUE ~ "Not Activated Genes"
        )
      )

    # Add "All Genes" group
    all_genes <- data %>% mutate(category = "All Genes")
    bind_rows(all_genes, data)
  })

  # Plot
  output$rna_plot <- renderPlot({
    ggplot(rna_filtered(), aes(x = category, y = LFC, color = category)) +
      geom_jitter(width = 0.2, height = 0, size = 2, alpha = input$alpha) +
      theme_minimal() +
      labs(title = paste("LFC values grouped by RNA-seq threshold >", input$th),
           x = "Gene Category",
           y = "LFC") +
      scale_color_manual(values = c("All Genes" = "blue",
                                    "Not Activated Genes" = "red",
                                    "Activated Genes" = "green")) +
      theme(legend.position = "none")
  })
}

shinyApp(ui, server)
