# Estos scripts han sido desarrollados por Quino (espetro), durante mayo de 2018
# para un proyecto personal


# === Obteniendo datos de la API de Spotify ===
# Buscamos canciones que sean lo mas parecidas en (titulo,artista), y extraer
# las stats de cada una. El resultado es un data.frame con columnas
# (titulo, artista, [features]...)

# (DEV) como el scrapping es lento, guarda los datos y los carga
# load(file = "htmlData.obj")


#### 1. Autenticacion

# Crea permisos para app en Spotify, donde 'callback' apunta a localhost:1410
# (para autentificacion de Rspotify)
# {queda checkear si 'spotifyOAuth' ya ha creado un .httr-oauth}

if(!exists("keys")) {
  client_id <- readline(prompt = "client_id: ")
  secret_id <- readline(prompt = "secret_id: ")
  keys <- spotifyOAuth("danceability", client_id, secret_id)
}


#### 2. Verificacion de resultados de busqueda ##

# searchResults <- getSongFromHTML(htmlData[1:10, ], keys, limit = 1, verify = F)
closestSongs <- getSongFromHTML(htmlData)


# (DEV) para guardar resultados intermedios
# save(closestSongs, file = "spotify_songs.obj")
# load("spotify_songs.obj")


#### 3. Busqueda de atributos

songAtts <- getAttsMultiple(closestSongs$results, keys)
print("Error in if (json1$tracks$total != 0) { : argument is of length zero")


# (DEV) para guardar resultados intermedios
# save(songAtts, file = "spotify_features.obj")
# load("spotify_features.obj")


#### 4. Limpieza de columnas extras

songFinal <- songAtts[, c("id", "display_name", "artists", "artists_IDs",
                       "yr", "danceability", "energy", "key",
                       "loudness", "liveness", "tempo", "uri")]

# Adaptamos la URI de cada cancion a la URL de Spotify; asi se puede acceder
# a la cancion con un click
songFinal$url <- paste0("https://open.spotify.com/track/", songFinal$id)


# (DEV) almaceno datos intermedios
# save(songFinal, file = "spotify_final.obj")
