# Estos scripts han sido desarrollados por Quino (espetro), durante mayo de 2018
# para un proyecto personal

# === Este script organiza los pasos para obtener los datos del proyecto ===

# 1. Imports
sapply(c("rvest", "magrittr", "Rspotify", "httpuv", "tm", "jsonlite", "reshape2"),
       'require', character.only = T)

# (paquetes minimos a instalar)
cran <- c("curl", "httr", "devtools", "rvest", "magrittr", "httpuv", "tm", "jsonlite",
          "reshape2","shiny","shinythemes")
gith <- "tiagomendesdantas/Rspotify"
# install.packages(cran)
# install_github(gith)


# 2. Funciones complementarias a todos los scripts
source("./utils.R")

# 3. Web/Data Scrapping (Los40)
source("./run1.R")

# 4. Llamadas a la API de Spotify
source("./run2.R")

# 5. Exportar los datos
source("./run3.R")
