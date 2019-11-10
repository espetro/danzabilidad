# (Actualizado: Noviembre de 2019)
# Estos scripts han sido desarrollados por Quino (espetro), durante mayo de 2018
# para un proyecto personal

# ' Este script sirve para jugar con la visualizacion que se muestra
# ' Primero ejecuta setwd('$PROYECTO/src')

origin <- read.csv("../results_all_songs_spotify.csv")
origin$id <- as.character(origin$id)
origin$url <- as.character(origin$url)
origin$important <- ifelse(origin$id=="4SEGzN4NXrsTKjXZcOhUOH",1,0)


# ' create a hoverable scatterplot of (song,artist,year)
# ' highlight 'ocho lineas' as a black? point
data <- origin[origin$yr %in% 1980:2000, ]
data <- rbind(
  data,
  subset(origin, origin$important == 1)
)

ttl <- paste0("Danzabilidad respecto al tempo en los hits en España", "(2000-2010)")

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
