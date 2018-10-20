# Estos scripts han sido desarrollados por Quino (espetro), durante mayo de 2018
# para un proyecto personal
# Los comentarios de funcion usan notacion del paquete "roxygen2"


# ' Extrae las canciones coincidentes dado el nombre de una cancion desde la API
# ' HTTP de Spotify. Si no existen coincidencias, devuelve un dataframe vacio
# ' (modificacion de Rspotify::searchTrack)
# ' @param  track el nombre de la cancion
# ' @param  token token de la API de Spotify
# ' @param  limit numero de canciones coincidentes a devolver
# ' @return dados canciones coincidentes con 'track' (0 si no hay)
searchTrack <- function (track, token, limit = 1) 
{

  req <- httr::GET(paste0("https://api.spotify.com/v1/search?q=",
                          track, "&type=track", "&limit=", limit),
                   httr::config(token = token))
  json1 <- httr::content(req)
  
  if(!is.atomic(json1)) {
    
    if(length(json1$tracks$total) > 0 && json1$tracks$total != 0) {
      x <- json1$tracks$items
      
      # get song features
      display_name = unlist(lapply(x, function(x) x$name))
      id = unlist(lapply(x, function(x) x$id))
      popularity <- unlist(lapply(x, function(x) x$popularity))
      artist.pre <- lapply(x, function(x) x$artists)
      artists_IDs <- plyr::ldply(artist.pre, data.frame)$id
      artists <- plyr::ldply(artist.pre, data.frame)$name
      type <- unlist(lapply(x, function(x) x$type))
      
      dados <- data.frame(display_name, id, popularity, artists, 
                          artists_IDs, type, stringsAsFactors = F)
      
      return(dados[order(-popularity), ])
    }
  }
  # returns empty data.frame (song not in Spotify)
  return(data.frame())
}


# Modificacion de la funcion para datos que no tienen valor (json1 es atomico)
# ' Dado el ID de una cancion en Spotify, obtiene todas las caracteristicas
# ' (modificacion de Rspotify::getFeatures)
# ' @param  spotify_ID el identificador de una cancion/album/artista en spotify
# ' @return dados todas las caracteristicas del identificador devuelto
getFeatures <- function (spotify_ID, token) 
{
  req <- httr::GET(paste0("https://api.spotify.com/v1/audio-features/", 
                          spotify_ID), httr::config(token = token))
  json1 <- httr::content(req)
  
  if(!is.atomic(json1)) {
    dados = data.frame(id = json1$id, danceability = json1$danceability, 
                       energy = json1$energy, key = json1$key, loudness = json1$loudness, 
                       mode = json1$mode, speechiness = json1$speechiness, 
                       acousticness = json1$acousticness, instrumentalness = json1$instrumentalness, 
                       liveness = json1$liveness, valence = json1$valence, 
                       tempo = json1$tempo, duration_ms = json1$duration_ms, 
                       time_signature = json1$time_signature, uri = json1$uri, 
                       analysis_url = json1$analysis_url, stringsAsFactors = F)
  }
  
  dados = data.frame()
  return(dados)
}


# ' Permite realizar multiples peticiones de caracteristicas de IDs a la API de
# ' Spotify
# ' @param  spotifyIDs una lista de IDs de canciones/albums/artistas
# ' @param  token      las credenciales de la API
# ' @return dados      tabla con las caracteristicas de los IDs
getMultipleFeatures <- function(spotify_IDs, token = keys)
{
  # La API tiene un limite de 100 tracks
  if(length(spotify_IDs) > 100) {
    stop(simpleError("Id vector is not right \n(check length < 101 and is a vector)"))
  }
  
  # Une todos los IDs en una sola linea
  ids <- paste(spotify_IDs, collapse = " ")
  ids <- gsub(" ", "%2C", ids)
  
  # Petcion HTTP a la API
  req <- httr::GET(paste0("https://api.spotify.com/v1/audio-features/?ids=", ids), httr::config(token = token))
  json1 <- httr::content(req)
  
  # Es posible que los datos esten corruptos para un cjto de queries;
  # devuelve un data.frame vacio para evitar posibles errores
  dados <- data.frame()
  
  if(!is.atomic(json1)) {
    feats <- lapply(json1$audio_features, function(hit) do.call(cbind.data.frame, as.list(hit)))
    dados <- do.call(rbind, feats)
  }
  
  if(nrow(dados) == 0) { 
    msg <- paste("Returning empty data frame. Block using ID", spotify_IDs[1], "is corrupt")
    message(msg)
  }
  return(dados)
}


# '
# ' @param
# ' @return
getAttsMultiple <- function(rows, token = keys)
{
  # particiona en subconjuntos de longitud <100 (limite API)
  sets <- split(rows, 1 : ceiling(nrow(rows) / 100))
  
  # para cada set, recoge las caracteristicas de cada cancion
  sets.data <- lapply(sets, function(set) {
    # de cada set, recoge la columna "id"
    fts <- getMultipleFeatures(set$id, token)
    
    # se hace una union de cada track con sus caracteristicas usando su ID
    # lo bueno es que se ignoran aquellos tracks sin caracteristicas (SQL)
    set.fts <- merge(x = set, y = fts, by = "id")
    return(set.fts)
  })
  
  # union de todos los subconjuntos
  sets.all <- do.call(rbind, sets.data)
  return(sets.all)
}


# ' Tokeniza cada (titulo + artista) que representa al hit. Elimina blancos, simbolos.
# ' @param  text una cadena que contiene informacion de la cancion
# ' @return ls   lista de tokens (titulo,artista)
process <- function(text)
{
  ls <- sapply(text, function(x) tolower(x) %>%
                 removePunctuation %>%
                 strsplit(., ' '))
  names(ls) <- names(text)
  return(ls)
}


# ' Compara el vector v1 con el set de vectores v2 y devuelve el v \in v2 mas
# ' similar a v1. Utiliza la similitud cosenoidal.
# ' @param  v1
# ' @param  v2
# ' @return v
getClosestSong <- function(v1, v2)
{
  # cada vector en v1 es una fila de data.frame
  # cada vector en v2 es una sublista cuyo indice corresponde con x \in v1
  cosine_dist_mat <- 1 - crossprod_simple_triplet_matrix(tdm)/(sqrt(col_sums(tdm^2) %*% t(col_sums(tdm^2))))
}


# ' Dada una tabla de (titulo,artista), busca coincidencias en la API de Spotify
# ' y obtiene las caracteristicas.
# ' @param  rows   una lista de pares (titulo,artista)
# ' @param  token  credenciales de la API
# ' @param  limit  coincidencias a devolver
# ' @param  verify compara las coincidencias y devuelve el resultado mas similar
# ' @return dados  lista/tupla con canciones (encontradas, no encontradas)
getSongFromHTML <- function(rows, token = keys, limit = 1, verify = F)
{
  
  string <- apply(rows, 1, function(r) paste(r[[1]], r[[2]]) %>% 
                    gsub(" ", "+", .) %>% 
                    gsub("\n","", .))
  
  # Como separa cada busqueda en una sublista, mantiene el orden dado por 'rows'
  tracks <- lapply(string, function(txt) searchTrack(txt, token, limit))
  
  if(verify) { 
    tracks <- getClosestSong(rows, tracks) 
  }
  
  data <- do.call(rbind, tracks)
  
  # Comprueba que canciones no estan en Spotify (solo el numero)
  nFound <- sapply(tracks, function(x) length(x) == 0) %>% which(. == TRUE)
  no_data <- data.frame()
  
  # { tambien se podria obtener la fecha de lanzamiento, enlazando el album}
  if(length(nFound) == 0) {
    no_data <- rows[nFound, ]
    data$yr <- rows$yr[-nFound] # yr column
  } else {
    data$yr <- rows$yr
  }
  
  # deberia devolver rows[nFound, ] en vez de solo el nº de fila donde esta la
  # cancion
  return(list(results = data, not_found = no_data))
}


# ' Dada una cancion, busca las caracteristicas musicales del hit
# ' @param  rows  data.frame con las canciones a buscar
# ' @param  token credenciales de la API
# ' @return dados lista/tupla con canciones (con resultado, sin resultado)
getAtts <- function(rows, token = keys)
{
  data <- apply(rows, 1, function(row) {
    ft <- getFeatures(row[2], token)
    
    # 'ft' esta vacio (no hay datos sobre las caracteristicas de la cancion)
    if(nrow(ft) != 0) {
      datarow <- data.frame(titulo = row[1], id = row[2], artista = row[4],
                 artistaId = row[5], yr = row[7],
                 dance = ft$danceability, energia = ft$energy,
                 clave = ft$key, tempo = ft$tempo, uri = ft$uri)
      
    } else { datarow <- data.frame() }
    
    return(datarow)
  })
  
  # Comprueba que canciones no tienen "features" en Spotify
  # (mas facil de comprobar si "data" es lista)
  nFound <- sapply(data, function(x) length(x) == 0) %>% which(. == TRUE)
  data <- do.call(rbind, data)
  
  return(list(results = data, not_found = nFound))
}
