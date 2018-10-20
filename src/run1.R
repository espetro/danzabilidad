# Estos scripts han sido desarrollados por Quino (espetro), durante mayo de 2018
# para un proyecto personal


# === Web Scrapping de tablas HTML ===
# @resultado data.frame con columnas ["titulo", "artista", "fecha de publicacion"]

# (DEV) como el scrapping es lento, guarda los datos y los carga
# load(file = "htmlData.obj")


#### Usando Los40 como referencia, recoge el historico desde 1966 hasta 2018
yr1 <- 1966:2015
base1 <- "https://es.wikipedia.org/wiki/Anexo:Los_n%C3%BAmeros_uno_de_Los_40_Principales_(Espa%C3%B1a)"
urls1 <- data.frame(url = sprintf("%s_%s", base1, yr1), yr = yr1, stringsAsFactors = F)

yr2 <- 2016:2018
base2 <- "https://es.wikipedia.org/wiki/Anexo:Los_n%C3%BAmeros_uno_de_LOS40_(Espa%C3%B1a)"
urls2 <- data.frame(url = sprintf("%s_%s", base2, yr2), yr = yr2, stringsAsFactors = F)

urls <- rbind(urls1, urls2)


#### Como hay canciones que pueden permanecer en el top 1 durante varias semanas
# consecutivas, hay filas (<tr>) donde hay 4 elementos hijos (<td>), en vez de 2

getTitleArtist <- function(rows) {
  # Para cada fila, recoge los datos si el numero de hijos es mayor que 4
  # y los devuelve dentro de un data.frame
  lapply(rows, function(r) {
    td <- html_children(r)
    
    if(length(td) == 4) {
      text <- td[2:3] %>% html_text
      return(data.frame(titulo = text[1], artista = text[2]))
    }
    return(data.frame())
  })
}


htmlData <- apply(urls[1:50, ], 1, function(url) {
# Recoge los datos de cada pagina y los ordena en un data.frame
  
  tags <- read_html(url[1])
  rows <- html_nodes(tags, "tr")
  
  # Se juntan todas las filas y se elimina la cabecera
  data <- getTitleArtist(rows) %>% do.call(rbind, .)
  data <- data[-1, ]
  
  # Se añade el año
  data$yr <- url[2]
  
  return(data)
})


# Agrega los datos anuales en un unico data.frame
htmlData <- do.call(rbind, htmlData)
rownames(htmlData) <- NULL


#### Agrega la cancion de "Ocho Lineas", de Violadores del Verso
htmlData <- rbind(htmlData,
                  data.frame(titulo = "Ocho Lineas", artista = "Violadores Del Verso", yr = "2006"))


# (DEV) como el scrapping es lento, guarda los datos y los carga
# save(htmlData, file = "htmlData.obj")
