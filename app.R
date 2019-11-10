library(shiny)
library(shinythemes)
library(plotly)
library(htmlwidgets)
library(jsonlite)

# Define UI
ui <- fluidPage(
  theme = shinytheme("lumen"),
  titlePanel(HTML("¿Es <i>'Ocho Lineas'</i> danzable?")),
  fluidRow(
    column(12,
      tags$p("Un proyecto de ", tags$a(href="https://espetro.github.io", "Quim Terrasa", target="_blank")),
      tags$br()
    )
  ),
  sidebarLayout(
    
    # Input: range slider
    sidebarPanel(
      
      sliderInput(inputId="range", "Rango:",
                  min=1966, max=2015,
                  value=c(2000,2015))
    ),
    
    # Output: description, plot and reference
    mainPanel(
      plotlyOutput(outputId="mainplot"),
      tags$a(href="https://developer.spotify.com/","Source: Spotify Platform",target="_blank")
    )
  )
)



# Define server function
server <- function(input, output) {
  
  origin <- read.csv("./results_all_songs_spotify.csv")
  origin$id <- as.character(origin$id)
  origin$url <- as.character(origin$url)
  origin$important <- ifelse(origin$id=="4SEGzN4NXrsTKjXZcOhUOH", 1,0)
  
  # data <- reactive(origin)
  
  
  # create a hoverable scatterplot of (song,artist,year)
  output$mainplot <- renderPlotly({
    
    data <- NULL
    data <- origin[origin$yr %in% input$range, ]
    
    data <- rbind(
      subset(origin, origin$important == 1),
      data
    )
    
    ttl <- paste0("Bailabilidad respecto al tempo en los hits en España",
             " (",input$range[1],"-",input$range[2],")")
    
   # colorPalette <- c("lightblue", "red")
   # if willing to use it, add 'color=~important, colors = colorPalette,' to plot_ly func
   
   p <- plot_ly(
     data, x = ~tempo, y = ~danceability, type = "scatter",
     mode = "markers", symbol = ~important, symbols = c("o", "x"),
     color = I("grey30"), marker = list(size=9),
     text=~paste(display_name,"<br>",artists)
   ) %>% 
     layout(title=ttl, showlegend = FALSE) %>%
     add_markers(customdata=data$url)
    
    p$x$data[[1]]$customdata <- data$url
    
    p <- onRender(
      p,
      "function(el, x) {
        el.on('plotly_click', function(d) {
          var url = d.points[0].customdata;
          window.open(url);
        });
      }"
    )
    
    p
  })
}

shinyApp(ui = ui, server = server)
